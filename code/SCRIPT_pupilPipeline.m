% SCRIPT performing processing of the entire pupil video.

%% USE THESE STEPS TO EXPLORE THE PARAMETER SETTINGS

% This first step just creates the gray files and then stops
pupilPipelineWrapper(pathParams, 'lastStage', 'raw2gray')

% This step dumps the list of gray files to the console
pupilPipelineWrapper(pathParams,'grayFileNameOnly',true)

% Set the variable grayVideoName equal to the gray file you'd like to
% examine:

grayVideoName = 'copy_and_past_a_filename_here';

% then issue this command:
extractPupilPerimeter(grayVideoName, '', 'nFrames', 100, 'displayMode', true, 'pupilRange', [30 90], 'pupilCircleThresh', 0.06, 'gammaCorrection', 1)

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

%% TOME_3021 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060917';

pupilPipelineWrapper(pathParams, 'pupilRange', [20 90], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1.5)


%% TOME_3022 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061617';

pupilPipelineWrapper(pathParams)



