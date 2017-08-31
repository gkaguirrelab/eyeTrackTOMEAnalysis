function DEMO_gazeCalibration
% DEMO_eyeTracking
%
% Demonstrate the sizeCalibration function.
%
% This function will work in the same sandbox folder as the one created by
% DEMO_eyetracking.
%
% Make sure your machine is configured to work with ToolboxToolbox.
%

%% set paths and make directories
% create test sandbox on desktop
sandboxDir = '~/Desktop/eyeTrackingDEMO';
if ~exist(sandboxDir,'dir')
    mkdir(sandboxDir)
end


%% hard coded parameters
verbosity = 'full'; % Set to none to make the demo silent
TbTbProjectName = 'eyeTOMEAnalysis';

% define path parameters
pathParams.dataSourceDirRoot = fullfile(sandboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(sandboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(sandboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '050517';
pathParams.runName = 'tfMRI_RETINO_PA_run01'; % run to be calibrated
pathParams.gazeCalName = 'GazeCal01'; % calibraton to use
%% TbTb configuration
% We will suppress the verbose output, but detect if there are deploy
% errors and if so stop execution
tbConfigResult=tbUseProject(TbTbProjectName,'reset','full','verbose',false);
if sum(cellfun(@sum,extractfield(tbConfigResult, 'isOk')))~=length(tbConfigResult)
    error('There was a tb deploy error. Check the contents of tbConfigResult');
end
tbSnapshot=tbDeploymentSnapshot(tbConfigResult,'verbose',false);
clear tbConfigResult

% identify the base for the project code directory
%  This would normally be used as the location to save the controlFiles
codeBaseDir = tbLocateProject(TbTbProjectName,'verbose',false);

%% Prepare paths and directories

% define full paths for input and output
pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);
pathParams.controlFileDirFull = fullfile(pathParams.controlFileDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);

% Since we are operating in a sandbox, create the data directory
if ~exist(pathParams.dataOutputDirFull,'dir')
    mkdir(pathParams.dataOutputDirFull)
end
% % Download and unzip the calibration data if it is not already there
% calData = fullfile(pathParams.dataOutputDirFull,'CalibrationData.zip');
% if ~exist (calData,'file')
%     url = 'https://ndownloader.figshare.com/files/9049840?private_link=a5a5c8f86dcd39e3bee3';
%     system (['curl -L ' sprintf(url) ' > ' sprintf(calData)])
%     currentDir = pwd;
%     cd (pathParams.dataOutputDirFull)
%     unzip(calData)
%     cd (currentDir)
% end

%% Define some file names
% run
glintFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_glint.mat']);
pupilFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_pupil.mat']);
calibratedGazeFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_gaze.mat']);

% calibration
grayVideoNameCAL = fullfile(pathParams.dataOutputDirFull, [pathParams.gazeCalName '_gray.avi']);
glintFileNameCAL = fullfile(pathParams.dataOutputDirFull, [pathParams.gazeCalName '_glint.mat']);
pupilFileNameCAL = fullfile(pathParams.dataOutputDirFull, [pathParams.gazeCalName '_pupil.mat']);
LTdatFileName = fullfile(pathParams.dataSourceDirRoot, ...
    pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir, ...
    [pathParams.gazeCalName '_LTdat.mat']);
gazeDataFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.gazeCalName '_gazeCalData.mat']);
gazeCalParamsFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.gazeCalName '_gazeCalParams.mat']);


%% Pull calibration data

% 1. just pull out LT calibration data (example for those runs that do not
% have a raw video for gaze calibration)
LTgazeDataFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.gazeCalName '_LTgazeCalData.mat']);
prepareLTGazeCalibrationData (LTdatFileName,LTgazeDataFileName,'useLiveTrackGazeData',true)

%2. now pull out the gaze data from the raw video
prepareLTGazeCalibrationData (LTdatFileName,gazeDataFileName,'useLiveTrackGazeData',false,'rawDataPath',pathParams.dataOutputDirFull)

%% compare calibration data from LT and raw video
% here we just plot the apparent gaze location in pixels to see how the
% LiveTrack data compares to the bayesian tracked data.

tmpLT = load(LTgazeDataFileName);
ltGaze.X = tmpLT.gazeCalData.pupil.X - tmpLT.gazeCalData.glint.X;
ltGaze.Y = tmpLT.gazeCalData.pupil.Y - tmpLT.gazeCalData.glint.Y;
tmpRAW = load(gazeDataFileName);
rawGaze.X = tmpRAW.gazeCalData.pupil.X - tmpRAW.gazeCalData.glint.X;
rawGaze.Y = tmpRAW.gazeCalData.pupil.Y - tmpRAW.gazeCalData.glint.Y;

clear tmpLT tmpRAW

figure
plot(ltGaze.X, ltGaze.Y,'*')
hold on
plot(rawGaze.X, rawGaze.Y,'*')
legend('LiveTrack', 'Bayesian fit')
title('Apparent Gaze location on screen')

% NOTE: investigate if the shift might be due to a different approach to
% the "square pixels" assumption

%% calc gaze calibration params using the raw data

calcGazeCalibrationParams (gazeDataFileName,gazeCalParamsFileName, 'verbosity', 'none')

%% apply the calibration to the raw data

applyGazeCalibration(pupilFileName,glintFileName,gazeCalParamsFileName,calibratedGazeFileName)

%% plot the calibrated data in screen and polar coordinates

% load gaze data

tmpData = load(calibratedGazeFileName);

% extract coordinates of pupil center
gazeStruct.X = tmpData.calibratedGaze.X;
gazeStruct.Y = tmpData.calibratedGaze.Y;
gazeStruct.ecc = tmpData.calibratedGaze.ecc;
gazeStruct.pol = tmpData.calibratedGaze.pol;

clear tmpData

plotCalibratedGaze(gazeStruct)

