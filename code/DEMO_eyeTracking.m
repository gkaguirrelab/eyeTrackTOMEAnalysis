% DEMO_eyeTracking
%
% Demonstrate the entire eyetracking analysis pipeline.
%
% A local sandbox folder named 'eyeTrackingDEMO' will be created on the
% desktop to replicate the dropbox environment of the real routine. Files
% will be downloaded from figshare and placed in the sandbox (about 7 GB).
%
% Make sure your machine is configured to work with ToolboxToolbox.
%
% Run-time on an average computer is about XX minutes. For a quicker demo,
% reduce the hardcoded nFrames to (e.g.) 1000.
%
% Usage examples
% ==============
%
% DEMO_eyeTracking
%

%% set paths and make directories
% create test sandbox on desktop
sandboxDir = '~/Desktop/eyeTrackingDEMO';
if ~exist(sandboxDir,'dir')
    mkdir(sandboxDir)
end

%% hard coded parameters
nFrames = 1000; % number of frames to process (set to Inf to do all)
verbosity = 'full'; % Set to none to make the demo silent
TbTbProjectName = 'eyeTOMEAnalysis';

% define path parameters
pathParams.dataSourceDirRoot = fullfile(sandboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(sandboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(sandboxDir,'controlFies');
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '050517';
pathParams.runName = 'tfMRI_FLASH_AP_run01';


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
pathParams.dataSourceDirFull = fullfile(pathParams.dataSourceDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);
pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);
pathParams.controlFileDirFull = fullfile(pathParams.controlFileDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);

% Since we are operating in a sandbox, create the data directory
if ~exist(pathParams.dataSourceDirFull,'dir')
    mkdir(pathParams.dataSourceDirFull)
end
% Download the data if it is not already there
rawVideoName = fullfile(pathParams.dataSourceDirFull,[pathParams.runName '_raw.mov']);
if ~exist (rawVideoName,'file')
    url = 'https://ndownloader.figshare.com/files/8711089?private_link=8279728e507d375541c7';
    system (['curl -L ' sprintf(url) ' > ' sprintf(rawVideoName)])
end


%% Perform the analysis
processVideoPipeline( pathParams, ...
    'nFrames',nFrames,'verbosity', verbosity,'tbSnapshot',tbSnapshot, 'useParallel',true);


%% Plot some fits
ellipseFitFileName = fullfile(pathParams.dataOutputDirFull,[pathParams.runName '_pupil.mat']);
dataLoad = load(ellipseFitFileName);
ellipseFitData = dataLoad.ellipseFitData;
clear dataLoad

figure
plot(ellipseFitData.pInitialFitTransparent(:,3),'-.k');
hold on
plot(ellipseFitData.pPosteriorMeanTransparent(:,3),'-r','LineWidth',2)
plot(ellipseFitData.pPosteriorMeanTransparent(:,3)-ellipseFitData.pPosteriorSDTransparent(:,3),'-b')
plot(ellipseFitData.pPosteriorMeanTransparent(:,3)+ellipseFitData.pPosteriorSDTransparent(:,3),'-b')
hold off

figure
plot(ellipseFitData.pInitialFitTransparent(:,1),'-.k');
hold on
plot(ellipseFitData.pPosteriorMeanTransparent(:,1),'-r','LineWidth',2)
plot(ellipseFitData.pPosteriorMeanTransparent(:,1)-ellipseFitData.pPosteriorSDTransparent(:,1),'-b')
plot(ellipseFitData.pPosteriorMeanTransparent(:,1)+ellipseFitData.pPosteriorSDTransparent(:,1),'-b')
hold off
