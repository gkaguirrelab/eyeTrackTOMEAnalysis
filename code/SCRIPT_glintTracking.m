% SCRIPT FOR GLINT TRACKING and perimeter extraction.

% in this script we extract glint tracking information. Each cell
% will analize all videos in a single session for every TOME session.
%
% at a later point in the analysis this script will be integrated in a
% larger one.


%% TEMPLATE
% use this as a model for each session

% dropboxDir = '';
% params.outputDir = 'TOME_processing';
% params.projectFolder = 'TOME_processing';

% params.projectSubfolder = 'sessionX_XXXXXX';
% params.subjectName = 'TOME_30XX';
% params.sessionDate = 'mmddyy';

% params.eyeTrackingDir = 'EyeTracking';

% glintTrackingWrapper(dropboxDir,params)


%% TOME_3001 session1

dropboxDir = '';
params.outputDir = 'TOME_processing';
params.projectFolder = 'TOME_processing';

params.projectSubfolder = 'session2_spatialStimuli';
params.subjectName = 'TOME_30XX';
params.sessionDate = 'mmddyy';

params.eyeTrackingDir = 'EyeTracking';

glintTrackingWrapper(dropboxDir,params)