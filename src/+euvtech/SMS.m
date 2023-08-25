classdef SMS < euvtech.SMSAbstract
    
    % Modbus communication with EUV Tech SMS
    
    properties (Constant)
        
        
    end
    
    properties
       % {modbus 1x1}
        comm 
        
    end
    
    
    properties (Access = private)
        
        
      
        % {char 1xm} IP/URL
        cHost = '192.168.10.31'
        
        % {double 1x1} timeout
        dTimeout = 5
        
        ticGetDOStatus
        ticGetDIStatus
        tocMin = 0.1;
        
        
        
        % {logical} storage for all DO status (coils)
        lDOStatus = false(1, 8);
        lDIStatus = false(1, 8);
        
        lBeamlineOpen = false;
        
        
        % Index of DIStatus for each property
        % See the DIx where x = 0-7 connections on hardware
        % Note COM0 must be connected to the +24V wire of their COM out
        % since the Moxa DI channels read the voltage between COM and 
        % each DIx connection
        
        u8IndexBeamlineOpen = 1
        u8IndexBeamlineBusy = 2
        u8IndexOnlineMode = 3
        u8IndexRemoteMode = 4
        u8IndexSourceOn = 5
        u8IndexSourceError = 6
        u8IndexVacuumOK = 7
        u8IndexRoughingPumpsOK =8 

        
        % {timer 1x1}
        t1
       
        
    end
    
    methods
        
        
        function this = SMS(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            try
                % modbus requires instrument control toolbox
                cTransport = 'tcpip';
                this.comm = modbus(...
                    cTransport, ...
                    this.cHost, ...
                    'Timeout', this.dTimeout ...
                );
                
            catch mE
                this.comm = [];
                % Will crash the app, but gives lovely stack trace.
                error(getReport(mE));
                
            end
            
        end
        
        
        function delete(this)
            delete(this.comm)
        end
        
        % @param {double 1x1} u8Idx - zero-indexed, accept values 0-7

        function l = getDOStatus(this, u8Index)
            lAll = this.getAllDOStatus();
            l = lAll(u8Index + 1);
        end
        
        function l = getDIStatus(this, u8Index)
            lAll = this.getAllDIStatus();
            l = lAll(u8Index);
        end
        % Returns {double 1xm} of each coil
        % Reads all 8 DO_status values and populates local cache
        % Per moxa documentation, these are "coil status"
        % point type, which in MATLAB is 'coils' target (2nd param)
        
        function l = getAllDOStatus(this)
            
            % tic
            
            if ~isempty(this.ticGetDOStatus)
                if (toc(this.ticGetDOStatus) < this.tocMin)
                    % Use storage
                    l = this.lDOStatus;
                    % toc
                    % fprintf('PowerPmac.getAllDOStatus() using cache\n');
                    return;
                end
            end
            
                        
            % Reset tic and update storate
            
            dAddress = 0000;
            dNum = 8;
            l = logical(read(this.comm, 'coils', dAddress, dNum));
            this.lDOStatus = l;
            this.ticGetDOStatus = tic();
            
        end   
        
        % Reads all 16 DI_status values and populates local cache
        % Per moxa documentation, these are "input status"
        % point type, which in MATLAB is 'inputs' target (2nd param)
        
        function l = getAllDIStatus(this)
            
            % tic
            
            if ~isempty(this.ticGetDIStatus)
                if (toc(this.ticGetDIStatus) < this.tocMin)
                    % Use storage
                    l = this.lDIStatus;
                    % toc
                    % fprintf('PowerPmac.getAllDOStatus() using cache\n');
                    return;
                end
            end
            
                        
            % Reset tic and update storate
            
            dAddress = 0;
            dNum = 8;
            l = logical(read(this.comm, 'inputs', dAddress, dNum));
            this.lDIStatus = l;
            this.ticGetDIStatus = tic();
            
        end   
        
        
        function l = getBeamlineOpen(this)
            
            % IMPORTANT - don't call to the DI registers since EUVtech
            % sets this to true whenever they have sent the open signal
            % to the slow shutter. But it takes about 1 second to
            % physically move in when the DI register would return true
            % after being instructed to turn on by the SMS rio board.
            
            %l = this.lBeamlineOpen; 
            %return;
            
            % IMPORTANT 2: turns out above doesnt compensate well for
            % network latency and in fact below works better
            
            % The hardware has no physical limit switch to know if the
            % glass plate is in/out.  Christian recommended a 1 second
            % delay between issuing the open command and reporting that it
            % is actually open.  Can handle this with a one-time use timer
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexBeamlineOpen);
        end
        
        function l = getBeamlineBusy(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexBeamlineBusy);
        end
        
        function l = getOnlineMode(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexOnlineMode);
        end
        
        function l = getRemoteMode(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexRemoteMode);
        end
        
        function l = getSourceOn(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexSourceOn);
        end
        
        function l = getSourceError(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexSourceError);
        end
        
        function l = getVacuumOK(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexVacuumOK);
        end
        
        function l = getRoughingPumpsOK(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexRoughingPumpsOK);
        end
        
        %{
        function l = getSystemWarning(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexSystemWarning);
        end
        
        function l = getSystemError(this)
            lAll = this.getAllDIStatus();
            l = lAll(this.u8IndexSystemError);
        end
        %}
        
        
        
        % Sets provided DOx channel on Moxa to on/off
        % @param {double 1x1} u8Idx - zero-indexed, accept values 0-7
        % @param {logical 1x1] lVal - true for on, false, for off
        % NOTES
        % - Need to configre the DIOx (input/output configurable)
        % channels on hardware to "Output" with internal switches.  See
        % Moxa manual
        
        % - moxa needs to power supplies.  1) to power the moxa internnals
        % it accepts 12V DC - 36V DC don't let this confuse you with how
        % the MOXA can supply 24V output.  The normal supply is not used
        % for this!
        % - The DOx channels are designed to send out whatever voltage you
        % want, but you need to provide that voltage supply, called the COM voltage
        % or "communication voltage"
        % - the DO channels of the moxa are 
        % an ethernet-controlled short between the DOx lead
        % and the GND (ground) lead in the middle of the DO block.
        % - the ground of our (separate) 24V COM DC supply must be connected to
        % the GND lead of the DO block
        % - the +24V lead of our DC supply must then go to the "24COM LBL supply wire"
        % which is solid green
        %
        % then by turning different DO status to "on", you're shorting
        % their pin to the GND pin, completing the circuit with our 24VCOM
        % supply
        
        function setDOStatus(this, dIdx, lVal)
            % The Moxa manual, "start address" and "start register" docs
            % are confusing.  If you scroll to the section "supported
            % function code" you'll see that registers that start with
            % 0xxxx are 'coil status' -> matlab 'coils'
            % 1xxxx are 'input status' -> matlab 'inputs'
            % 2xxxx are 'holding registers' -> matlab 'holdingregs'
            % 3xxxx are 'input registers' -> matlab 'inputregs'
            % if you then go to the ioLogik E1212 Modbus Address and Register Map
            % map for DO_status, you'll see the "start register" column is 
            % 00001, this means it is a type "coils" since the firt number
            % is 0 and the address is 0001, so we use a matlab command like
            % read(this.comm, 'coils', 0001) to get the value the DIO0
            % output is set to. Note that 0001 is the same as 1
            
            write(this.comm, 'coils', dIdx + 1, double(lVal))
            
        end
        
        
        function setBeamlineOpen(this, lVal)
            
           
            
            % The beamline open grou 
            % See manual for the coils addressing for the D
            this.setDOStatus(0,double(lVal))
            
            dSec = 1.5;
            this.t1 = timer(...
                'StartDelay', dSec, ...
                'TimerFcn', @this.onTimer1, ...
                'UserData', lVal ... % use this access info in the callback
            );
            start(this.t1);
            
        end
        
        
       
                    
        
    end
    
    methods (Access = private)
        
        function msg(~, cMsg)
            fprintf('bl12014.hardwareAssets.WagoSMS %s\n', cMsg);
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
        function onTimer1(this, src, evt)
            this.lBeamlineOpen = src.UserData; % Set to value of UserData
        end
        
    end
    
    
    
    
        
    
end

