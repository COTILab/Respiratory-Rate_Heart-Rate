function out_struct=buffer_main(buffer_struct,signalProcessing,finalSignal)
%% Written on 30NOV21 -- handles buffering
% Inputs:
% 1.buffer_struct:




%% copying parameters
HR_coh=finalSignal.HR_coherenceBased; % coherence based-- will append 
HR_pow=finalSignal.HR_powerBased; % power based- will append 

%% Relevant Parameters
refresh_frames=buffer_struct.refresh_frames; % number of new frames to take before we reanalyze
buffer_cycles=buffer_struct.buffer_cycles;

%% Trackers
pointTracker_Face=buffer_struct.pointTracker_Face;
pointTracker_Chest=buffer_struct.pointTracker_Chest;
faceDetector=buffer_struct.faceDetector;

end