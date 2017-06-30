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


%% TOME_3015 session1

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
params.outputDir = 'TOME_processing';
params.projectFolder = 'TOME_processing';

params.projectSubfolder = 'session1_restAndStructure';
params.subjectName = 'TOME_3015';
params.sessionDate = '030117';

params.eyeTrackingDir = 'EyeTracking';

glintTrackingWrapper(dropboxDir,params)

%% TOME_3016

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
params.outputDir = 'TOME_processing';
params.projectFolder = 'TOME_processing';

params.projectSubfolder = 'session1_restAndStructure';
params.subjectName = 'TOME_3016';
params.sessionDate = '031017';

params.eyeTrackingDir = 'EyeTracking';

glintTrackingWrapper(dropboxDir,params)

%% TOME_3017

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
params.outputDir = 'TOME_processing';
params.projectFolder = 'TOME_processing';

params.projectSubfolder = 'session1_restAndStructure';
params.subjectName = 'TOME_3017';
params.sessionDate = '032917';

params.eyeTrackingDir = 'EyeTracking';

glintTrackingWrapper(dropboxDir,params)


%% TOME_3018

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
params.outputDir = 'TOME_processing';
params.projectFolder = 'TOME_processing';

params.projectSubfolder = 'session1_restAndStructure';
params.subjectName = 'TOME_3016';
params.sessionDate = '031017';

params.eyeTrackingDir = 'EyeTracking';

glintTrackingWrapper(dropboxDir,params)












