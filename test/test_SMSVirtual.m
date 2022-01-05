close all
clc
clear

% add src to path
[path, name, ext] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(path, '..', 'src')))

comm = euvtech.SMSVirtual();


comm.getBeamlineOpen()
comm.setBeamlineOpen(true);
comm.getBeamlineOpen()
comm.getBeamlineOpen()