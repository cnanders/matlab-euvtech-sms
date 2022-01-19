classdef SMSVirtual < euvtech.SMSAbstract
    
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
                       
        lBeamlineOpen = false;
        
        % {timer 1x1}
        t1
    end
    
    methods
        
        
        function this = SMSVirtual(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        function l = getBeamlineOpen(this)
            l = this.lBeamlineOpen;
        end
        
        function l = getBeamlineBusy(this)
            l = this.getRandomLogical();
        end
        
        function l = getOnlineMode(this)
            l = this.getRandomLogical();
        end
        
        function l = getRemoteMode(this)
           l = this.getRandomLogical();
        end
        
        function l = getSourceOn(this)
            l = this.getRandomLogical();
        end
        
        function l = getSourceError(this)
            l = this.getRandomLogical();
        end
        
        function l = getVacuumOK(this)
            l = this.getRandomLogical();
        end
        
        function l = getRoughingPumpsOK(this)
            l = this.getRandomLogical();
        end
        
        function l = getSystemWarning(this)
            l = this.getRandomLogical();
        end
        
        function l = getSystemError(this)
            l = this.getRandomLogical();
        end
        
        
        function setBeamlineOpen(this, lVal)
            %this.lBeamlineOpen = lVal;
            
            % Implement following the same pattern as the real hardware
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
        
        function l = getRandomLogical(this)
            l = randn(1) >= 0;
        end
        
        function onTimer1(this, src, evt)
            this.lBeamlineOpen = src.UserData; % Set to value of UserData
        end
        
    end
    
    
    
    
    
        
    
end

