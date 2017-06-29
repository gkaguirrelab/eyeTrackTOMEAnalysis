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

%% hard code number of frames (make Inf to do all)
nFrames = 1000;
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


%% Convert raw video to cropped, resized, 60Hz gray
grayVideoName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_gray.avi']);
raw2gray(rawVideoName,grayVideoName,'nFrames',nFrames, 'verbosity', verbosity)


%% track the glint
glintFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_glint.mat']);
trackGlint(grayVideoName, glintFileName, 'verbosity', verbosity, 'tbSnapshot',tbSnapshot);




%% STEP 3: make pupil perimeter video

perimeterVideoName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_perimeter.avi']);

% the user needs to set these values!
pupilCircleThresh = 0.06; 
pupilEllipseThresh = 0.945;
perimeterParams = extractPupilPerimeter(grayI, perimeterVideoName, ...
    'pupilCircleThresh', pupilCircleThresh, ...
    'pupilEllipseThresh', pupilEllipseThresh, ...
    'verbosity', verbosity);

extractPupilPerimeter(grayI, perimeterVideoName,'pupilCircleThresh', pupilCircleThresh, 'pupilEllipseThresh', pupilEllipseThresh);




%% GENERATE PRELIMINARY CONTROL FILE SECTION BEGINS HERE
% The control file is a set of formatted instruction to edit on the pupil
% perimeter video and help the fitting routine with cleaner data. 
% 
% The following part of the code produces the computer-generated control
% file for pupil fitting. This preliminary control file will be later
% reviewed by an operator, who will make the necessary corrections using a
% GUI.
% 
% In principle, the preliminary control file itself could be used to
% prepare the perimeter video for fitting, but the fitting results would be
% less accurate. Therefore, in the final release of the code, we will skip
% the steps concerning the creation of the preliminary control file and use
% the more accurate control files generated during data analysis.

%% blink detection
disp('Finding blinks')

tic
% find the blinks
blinkFrames = findBlinks(glintFileName);
toc

% show them on the tracked video (this function is for display only)
showBlinks(blinkFrames,grayI)

% note: blinkFrames is an array containing the index of the frames marked as
% blinks.
%% guess pupil cuts
disp('Computing pupil cuts')

tic
framesToCut = guessPupilCuts(perimeterVideoName,glintFileName,blinkFrames);
toc

%% make control file
controlFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_controlFile.csv']);

makePreliminaryControlFile(controlFileName, framesToCut, blinkFrames )

%% GENERATE PRELIMINARY CONTROL FILE SECTION ENDS HERE

%% make corrected perimeter video
% for testing purposes we just use the preliminary control file to correct
% the perimeter video.

correctedPerimeterVideoName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_correctedPupilPerimeter.avi']);
tic
correctPupilPerimeterVideo(perimeterVideoName,controlFileName,glintFileName, correctedPerimeterVideoName)
toc

%% bayesian fit of the pupil on the corrected perimeter video
ellipseFitDataFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_pupil.mat']);

finalFitVideoOutFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_fitFitPupilPerimeter.avi']);

[ellipseFitData] = bayesFitPupilPerimeter(correctedPerimeterVideoName, ...
    'verbosity','full', 'tbSnapshot',tbSnapshot, ...
    'ellipseFitDataFileName',ellipseFitDataFileName,'useParallel',true,...
    'nFrames',50,'developmentMode',true);

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
