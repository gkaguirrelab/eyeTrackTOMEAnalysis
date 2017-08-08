function DEMO_sizeCalibration
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
% Download and unzip the calibration data if it is not already there
calData = fullfile(pathParams.dataOutputDirFull,'CalibrationData.zip');
if ~exist (calData,'file')
    url = 'https://ndownloader.figshare.com/files/9049840?private_link=a5a5c8f86dcd39e3bee3';
    system (['curl -L ' sprintf(url) ' > ' sprintf(calData)])
    currentDir = pwd;
    cd (pathParams.dataOutputDirFull)
    unzip(calData)
    cd (currentDir)
end

%% get calibration data
% find calibration runs
calRunNames = dir (fullfile(pathParams.dataOutputDirFull, 'RawScaleCal*pupil.mat'));
sizeDataFilesNames = { ...
    fullfile(calRunNames(1).folder, calRunNames(1).name) ...
    fullfile(calRunNames(2).folder, calRunNames(2).name) ...
    fullfile(calRunNames(3).folder, calRunNames(3).name) ...
    };

% define ground truth (in case of manual input)
sizeGroundTruths = [4 5 6];

% define output file name
sizeFactorsFileName = fullfile(pathParams.dataOutputDirFull, 'sizeFactors.mat');

% get size calibration values
calcSizeFactors(sizeDataFilesNames, sizeFactorsFileName)
