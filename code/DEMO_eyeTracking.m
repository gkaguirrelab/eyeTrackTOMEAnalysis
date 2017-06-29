
% this is a demo of the whole eyetracking analysis pipeline.
% 
% A sandbox folder named 'eyeTrackingDEMO' will be created on the user's desktop to replicate
% the dropbox environment of the real routine. All data downloaded and
% produced by the routine will live in the sandbox folder, that will grow
% to take 7-8 GB on the hard disk.
% 
% Make sure your machine is configured to work with ToolboxToolbox.
% The function will download an example eye raw video from fig share. Make
% sure you have an active internet connection.
% 
% For a quicker demo, the user has the option to set how many frames of the
% video they wish to process. As default, the routine will process the
% whole video.
% 
% Usage examples
% ==============
% 
% DEMO_eyeTracking
% 

%% ToolboxToolbox configuration
tbConfigResult=tbUseProject('eyeTOMEAnalysis','reset','full');
tbSnapshot=tbDeploymentSnapshot(tbConfigResult);
clear tbConfigResult

%%  Hard code number of frames (make Inf to do all)
numberOfFrames = Inf;

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
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir);
if ~exist(dataDir,'dir')
    mkdir(dataDir)
end

processingDir = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir);
if ~exist(processingDir,'dir')
    mkdir(processingDir)
end

%% download the test run from figshare
rawVideoName = fullfile(dataDir,[pathParams.runName '_raw.mov']);

if ~exist (rawVideoName,'file')
    url = 'https://ndownloader.figshare.com/files/8711089?private_link=8279728e507d375541c7';
    system (['curl -L ' sprintf(url) ' > ' sprintf(rawVideoName)])
end

%% NOTE: RUN PARAMS vs CONTROL PARAMS

% As we move to a more modular code structure, the overuse of a single
% params struct to control every aspect of the analysis might lead to
% errors and confusion, as even the simplest function would receive a
% massive struct as input variable.

% I suggest we keep using the "params strategy" for metadata-kind of
% information (or RUN PARAMS), such as: subject name, session, runName... 

% All tracking parameters (or CONTROL PARAMS) will be fed through an input
% parser into the tracking functions in form of "options" instead. This
% will allow for easier control of each option (manually or via a control
% file), easier default values settings, and it is very much in style with
% matlab's native functions input managment.


%% STEP 1: convert raw eye video to 60Hz gray

grayVideoName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_gray.avi']);
tic
raw2gray(rawVideoName,grayVideoName,'numberOfFrames',numberOfFrames)
toc


%% track the glint
disp('Tracking glint...')

tic
glintFileName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_glint.mat']);
[glint, glintTrackingParams] = trackGlint(grayI, glintFileName);
toc


%% make pupil perimeter video
disp('Making pupil perimeter video...')

tic
perimeterVideoName = fullfile(sandboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
        pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir, ...
        [pathParams.runName '_perimeter.avi']);
pupilCircleThresh = 0.06; 
pupilEllipseThresh = 0.945;
perimeterParams = extractPupilPerimeter(grayI, perimeterVideoName,'pupilCircleThresh', pupilCircleThresh, 'pupilEllipseThresh', pupilEllipseThresh);
toc

%% COMMENTS SO FAR
% 
%  up to this point the routine produces the following output files,
%  necessary for the subsequent steps:
%  1. pupil perimeter video
%  2. glint tracking file (X,Y position frame by frame)
% 
% 
%  The routine also outputs these structs (currently not saved): 
%  1. glintTrackingParams 
%  2. perimeterParams 
%  They include ALL input necessary
%  to replicate the analysis exactly how it was performed the first time
%  around (including the grayI frameseries that originated from prepareVideo).
%  This means that parsing the structs as inputs for the function
%  trackGlint and extractPupilPerimeter respectively will exactly
%  replicate their outputs.
%  The advantage compared to the "params" strategy is again the modularity:
%  only necessary and unambiguous inputs are fed to each step.



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
    'forceNumFrames',50,'developmentMode',true);

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
