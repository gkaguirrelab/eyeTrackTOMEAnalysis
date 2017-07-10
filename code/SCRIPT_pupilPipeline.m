% SCRIPT performing processing of the entire pupil video.

%% USE THESE STEPS TO EXPLORE THE PARAMETER SETTINGS

% This first step just creates the gray files and then stops
pupilPipelineWrapper(pathParams, 'lastStage', 'raw2gray')

% Once you have a processing directory that has some gray files in it, copy
% and paste the path params for the subject / session to the command
% window, then issue this command:

testExtractParams(pathParams, 'nFrames', 100, 'displayMode', true, 'pupilRange', [30 90], 'pupilCircleThresh', 0.06, 'gammaCorrection', 1)

% Re-run the extractPupilPerimeter command with different parameter values
% for pupilRange, pupilCircleThresh, and gammaCorrection until you find
% values that do a good job segmenting the pupil for several of the gray
% videos. I would check at least one of the GazeCalibration files and then
% one of the Flash files for 1000 frames. Put down the best parameters you
% find in this next line, and then run it (which will then take about 24
% hours to complete):

pupilPipelineWrapper(pathParams, 'pupilRange', [20 90], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1.5)

%% **********************************************************
%%
%%   THE FINAL ANALYSIS PARAMETERS ARE BELOW HERE

%% STARTING SESSION 1 HERE

% TOME_3001 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';


pupilPipelineWrapper(pathParams, 'pupilRange', [20 90], 'pupilCircleThresh', 0.035, 'gammaCorrection', .50)


%% STARTING SESSION 2 HERE

%TOME_3018 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '051217';

%TOME_3019 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '050317';


% TOME_3020 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '050517';

% still working on these params as of afternoon July 7.
pupilPipelineWrapper(pathParams, 'pupilRange', [20 120], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1.5)

% TOME_3021 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060917';

pupilPipelineWrapper(pathParams, 'pupilRange', [20 90], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1.5)

% TOME_3022 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061617';

pupilPipelineWrapper(pathParams, 'pupilRange', [20 90], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1.5)
