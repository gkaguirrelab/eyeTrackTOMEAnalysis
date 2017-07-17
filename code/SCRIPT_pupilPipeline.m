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

% TOME_3002 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';

%for T1
pupilPipelineWrapper(pathParams, 'pupilRange', [30 90], 'pupilCircleThresh', 0.03, 'gammaCorrection', .5)

%for rfmri
pupilPipelineWrapper(pathParams, 'pupilRange', [30 200], 'pupilCircleThresh', 0.05, 'gammaCorrection', 1)


% TOME_3003 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '090216';

pupilPipelineWrapper(pathParams, 'pupilRange', [30 100], 'pupilCircleThresh', 0.05, 'gammaCorrection', .5)

% TOME_3004 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '091916';

pupilPipelineWrapper(pathParams, 'pupilRange', [30 100], 'pupilCircleThresh', 0.05, 'gammaCorrection', .75)


% TOME_3005 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '092316';

pupilPipelineWrapper(pathParams, 'pupilRange', [30 100], 'pupilCircleThresh', 0.04, 'gammaCorrection', .5)

% TOME_3007 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101116';

% TOME_3008 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '102116';

pupilPipelineWrapper(pathParams, 'pupilRange', [20 180], 'pupilCircleThresh', 0.06, 'gammaCorrection', .5)

% TOME_3009 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '100716';

pupilPipelineWrapper(pathParams, 'pupilRange', [10 90], 'pupilCircleThresh', 0.04, 'gammaCorrection', .75)

% TOME_3011 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '111116';

% TOME_3013 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3013';
pathParams.sessionDate = '121216';

%for calibration runs
pupilPipelineWrapper(pathParams, 'pupilRange', [10 120], 'pupilCircleThresh', 0.03, 'gammaCorrection', .5)

%for REST runs 
pupilPipelineWrapper(pathParams, 'pupilRange', [10 200], 'pupilCircleThresh', 0.03, 'gammaCorrection', .75)

% TOME_3014 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3014';
pathParams.sessionDate = '021517';

pupilPipelineWrapper(pathParams, 'pupilRange', [30 280], 'pupilCircleThresh', 0.03, 'gammaCorrection', .75)

% TOME_3015 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3015';
pathParams.sessionDate = '030117';

%for calibration runs
pupilPipelineWrapper(pathParams, 'pupilRange', [10 180], 'pupilCircleThresh', 0.05, 'gammaCorrection', .75)

%for T1 runs
pupilPipelineWrapper(pathParams, 'pupilRange', [30 200], 'pupilCircleThresh', 0.04, 'gammaCorrection', .75)

%for dmri runs
pupilPipelineWrapper(pathParams, 'pupilRange', [10 200], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1)

% TOME_3016 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '031017';

%for cal, T1. and dmri runs
pupilPipelineWrapper(pathParams, 'pupilRange', [5 180], 'pupilCircleThresh', 0.06, 'gammaCorrection', 1)

%for rmfri runs (could be better)
pupilPipelineWrapper(pathParams, 'pupilRange', [30 330], 'pupilCircleThresh', 0.06, 'gammaCorrection', 1)

% TOME_3017 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3017';
pathParams.sessionDate = '032917';

%for cal (very bad could be better)
pupilPipelineWrapper(pathParams, 'pupilRange', [5 120], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1)

%for T files
pupilPipelineWrapper(pathParams, 'pupilRange', [30 150], 'pupilCircleThresh', 0.03, 'gammaCorrection', .75)

%for rfmri
pupilPipelineWrapper(pathParams, 'pupilRange', [30 150], 'pupilCircleThresh', 0.03, 'gammaCorrection', .75)

% TOME_3018 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '040717';

%for cal and dmri
pupilPipelineWrapper(pathParams, 'pupilRange', [10 100], 'pupilCircleThresh', 0.03, 'gammaCorrection', .75)

%for rfmri
pupilPipelineWrapper(pathParams, 'pupilRange', [10 200], 'pupilCircleThresh', 0.05, 'gammaCorrection', .5)

% TOME_3018 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '041817';

%for cal and dmri
pupilPipelineWrapper(pathParams, 'pupilRange', [10 100], 'pupilCircleThresh', 0.03, 'gammaCorrection', .75)

%for rfmri
pupilPipelineWrapper(pathParams, 'pupilRange', [10 140], 'pupilCircleThresh', 0.04, 'gammaCorrection', .75)

% TOME_3019 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '042617';

% TOME_3020 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '042817';

%for cal and T1 and dmri
pupilPipelineWrapper(pathParams, 'pupilRange', [10 180], 'pupilCircleThresh', 0.05, 'gammaCorrection', .75)

%for rfmri(terrible results)
pupilPipelineWrapper(pathParams, 'pupilRange', [40 300], 'pupilCircleThresh', 0.04, 'gammaCorrection', .5)

% TOME_3021 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060717';

%for cal
pupilPipelineWrapper(pathParams, 'pupilRange', [10 180], 'pupilCircleThresh', 0.04, 'gammaCorrection', .75)

%for rfmri(terrible results)
pupilPipelineWrapper(pathParams, 'pupilRange', [10 180], 'pupilCircleThresh', 0.04, 'gammaCorrection', .75)


% TOME_3022 session1
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061417';

%for cal
pupilPipelineWrapper(pathParams, 'pupilRange', [10 180], 'pupilCircleThresh', 0.04, 'gammaCorrection', .75)

%for T1 and dmri
pupilPipelineWrapper(pathParams, 'pupilRange', [10 180], 'pupilCircleThresh', 0.03, 'gammaCorrection', .75)

%for rfmri(nothing better)
pupilPipelineWrapper(pathParams, 'pupilRange', [30 400], 'pupilCircleThresh', 0.04, 'gammaCorrection', 1)















%% STARTING SESSION 2 HERE

%TOME_3001 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';

%TOME_3002 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '051217';





%TOME_3017 session2
dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3017-';
pathParams.sessionDate = '033117';

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

pupilPipelineWrapper(pathParams, 'pupilRange', [30 60], 'pupilCircleThresh', 0.02, 'gammaCorrection', .3)

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
