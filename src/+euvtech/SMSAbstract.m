classdef SMSAbstract < handle
        
    methods (Abstract)
        
        l = getBeamlineOpen(this)
        l = getBeamlineBusy(this)
        l = getOnlineMode(this)
        l = getRemoteMode(this)
        l = getSourceOn(this)
        l = getSourceError(this)
        l = getVacuumOK(this)
        l = getRoughingPumpsOK(this)
%         l = getSystemWarning(this)
%         l = getSystemError(this)
        setBeamlineOpen(this, lVal)  
        
    end
end

        

