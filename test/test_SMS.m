close all
clc
clear

% add src to path
[path, name, ext] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(path, '..', 'src')))


cHost = '192.168.10.31';
comm = euvtech.SMS('cHost', cHost);


comm.getBeamlineOpen()
