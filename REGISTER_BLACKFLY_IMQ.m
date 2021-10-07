%% This demo shows image acquisition with a Spinnaker supported camera. 
% Copyright 2018-2020 The MathWorks, Inc.
 
%% Execute ‘imaqregister’ to find the list of currently registered adaptors
imaqregister 
addpath(genpath('./R2021a'))
% Unregister existing spinnaker adaptors.
disp("CHECK THE FILE PATH BELOW")
imaqregister("C:\Users\rahul\OneDrive - Northeastern University\blackfly images\07JAN20--Preliminary SFDI Images\MAIN_BlackFlyMatlab Image Acquisition Scripts\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll", "unregister")

% For MATLAB R2019b, register the DLL file available in the R2019b folder.
imaqregister("C:\Users\rahul\OneDrive - Northeastern University\blackfly images\07JAN20--Preliminary SFDI Images\MAIN_BlackFlyMatlab Image Acquisition Scripts\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll")

%% Reload the adaptor libraries registered with the toolbox for the adaptor to appear.
imaqreset

%% View a list of installed adaptors in the 'InstalledAdaptors' field. The newly registered adaptor appears as 'mwspinnakerimaq'.
imaqhwinfo

%% The 'imaqhwinfo' returns a structure that contains adaptor-specific information.
out = imaqhwinfo('mwspinnakerimaq')
 
%% Create a video input object.
vid = videoinput('mwspinnakerimaq')
 
%% Initiate an acquisition and access the logged data.
start(vid);
data = getdata(vid);
 
%% Display each image frame acquired.
frame = imaqmontage(data);
 
%% Remove the video input object from memory.
delete(vid)