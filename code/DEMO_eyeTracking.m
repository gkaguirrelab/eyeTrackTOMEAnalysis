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

%% hard codeded parameters 
nFrames = 1000; % number of frames to process (set to Inf to do all)
pupilCircleThresh = 0.06; % these parameters determine how the gray video
pupilEllipseThresh = 0.945; % is thresholded to best find the pupil
verbosity = 'full'; % Set to none to make the demo silent


%% TbTb configuration
% We will suppress the verbose output, but detect if there are deploy
% errors and if so stop execution
tbConfigResult=tbUseProject('eyeTOMEAnalysis','reset','full','verbose',false);
if sum(cellfun(@sum,extractfield(tbConfigResult, 'isOk')))~=length(tbConfigResult)
    error('There was a tb deploy error. Check the contents of tbConfigResult');
end
tbSnapshot=tbDeploymentSnapshot(tbConfigResult,'verbose',false);
clear tbConfigResult


%% set paths and make directories
% create test sandbox on desktop
sandboxDir = '~/Desktop/eyeTrackingDEMO';
if ~exist(sandboxDir,'dir')
    mkdir(sandboxDir)
end

% add standard dropbox params
pathParams.projectFolder = 'TOME_data';
pathParams.outputDir = 'TOME_processing';
pathParams.projectSubfolder = 'session2_spatialStimuli';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectName = 'TOME_3020';
pathParams.sessionDate = '050517';
pathParams.runName = 'tfMRI_FLASH_AP_run01';

% create mock TOME folders in sandbox
dataDir = fullfile(sandboxDir,pathParams.projectFolder, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate, pathParams.eyeTrackingDir);
if ~exist(dataDir,'dir')
    mkdir(dataDir)
end
processingDir = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate, pathParams.eyeTrackingDir);
if ~exist(processingDir,'dir')
    mkdir(processingDir)
end

% download the test run from figshare
rawVideoName = fullfile(dataDir,[pathParams.runName '_raw.mov']);
if ~exist (rawVideoName,'file')
    url = 'https://ndownloader.figshare.com/files/8711089?private_link=8279728e507d375541c7';
    system (['curl -L ' sprintf(url) ' > ' sprintf(rawVideoName)])
end


%% Perform the analysis

% Convert raw video to cropped, resized, 60Hz gray
grayVideoName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_gray.avi']);
raw2gray(rawVideoName,grayVideoName,'nFrames',nFrames,...
    'verbosity', verbosity)

% track the glint
glintFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_glint.mat']);
trackGlint(grayVideoName, glintFileName, ...
    'verbosity', verbosity, 'tbSnapshot',tbSnapshot);

% extract pupil perimeter
perimeterFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_perimeter.mat']);
extractPupilPerimeter(grayVideoName, perimeterFileName, ...
    'pupilCircleThresh', pupilCircleThresh, ...
    'pupilEllipseThresh', pupilEllipseThresh, ...
    'verbosity', verbosity, 'tbSnapshot',tbSnapshot);

% generate preliminary control file
controlFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_controlFile.csv']);
makePreliminaryControlFile(controlFileName, perimeterFileName, glintFileName, ...
    'verbosity', verbosity, 'tbSnapshot',tbSnapshot);

% correct the perimeter video
correctedPerimeterFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_correctedPerimeter.mat']);
correctPupilPerimeter(perimeterFileName,controlFileName,correctedPerimeterFileName, ...
    'verbosity', verbosity, 'tbSnapshot', tbSnapshot)

% bayesian fit of the pupil on the corrected perimeter video
ellipseFitDataFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_pupil.mat']);
bayesFitPupilPerimeter(correctedPerimeterFileName, ellipseFitDataFileName, ...
    'useParallel',true, ...
    'verbosity', verbosity, 'tbSnapshot', tbSnapshot);


%% Plot some fits
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
