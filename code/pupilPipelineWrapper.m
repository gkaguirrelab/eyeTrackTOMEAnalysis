function pupilPipelineWrapper(pathParams, varargin)

%% Parse input and define variables
p = inputParser; p.KeepUnmatched = true;

% required input
p.addRequired('pathParams',@isstruct);

% optional input
p.addParameter('grayFileNameOnly',false,@islogical);
p.addParameter('skipStage',[],@iscell);

% parse
p.parse(pathParams, varargin{:})
pathParams=p.Results.pathParams;


%% hard coded parameters
nFrames = Inf; % number of frames to process (set to Inf to do all)
verbosity = 'full'; % Set to none to make the demo silent
TbTbProjectName = 'eyeTOMEAnalysis';

%% TbTb configuration
% We will suppress the verbose output, but detect if there are deploy
% errors and if so stop execution
tbConfigResult=tbUseProject(TbTbProjectName,'reset','full','verbose',false);
if sum(cellfun(@sum,extractfield(tbConfigResult, 'isOk')))~=length(tbConfigResult)
    error('There was a tb deploy error. Check the contents of tbConfigResult');
end
tbSnapshot=tbDeploymentSnapshot(tbConfigResult,'verbose',false);
clear tbConfigResult


%% define full paths for input and output
pathParams.dataSourceDirFull = fullfile(pathParams.dataSourceDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);
pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);
pathParams.controlFileDirFull = fullfile(pathParams.controlFileDirRoot, pathParams.projectSubfolder, ...
    pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);


% if starting from raw2gray, get the file names from the  raw files in the data
% folder. If starting from a later step, get the run name from the gray
% files instead.
if any(strcmp(p.Results.skipStage,'raw2gray'))
    sourceVideos = dir(fullfile(pathParams.dataOutputDirFull,'*_gray.avi'));
    suffixCodes = {'*_gray.avi','GazeCal*gray.avi','RawScaleCal*gray.avi'};
    suffixToTrim = [9, 9, 9];
else
    sourceVideos = dir(fullfile(pathParams.dataSourceDirFull,'*.mov'));
    suffixCodes = {'*_raw.mov','GazeCal*.mov','RawScaleCal*.mov'};
    suffixToTrim = [8, 4, 4];
end


% run the full pipeline on each source video
for rr = 1 :length(sourceVideos) %loop in all video files
    fprintf ('\nProcessing video %d of %d\n',rr,length(sourceVideos))
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{1}))
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(1)); %runs
        sizeCalFileFlag = false;
    end
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{2}))
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(2)); %gaze calibrations
        sizeCalFileFlag = false;
    end
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{3}))
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(3)); %scale calibrations
        sizeCalFileFlag = true;
    end
    processVideoPipeline( pathParams, ...
        'nFrames',nFrames,'verbosity', verbosity,'tbSnapshot',tbSnapshot, ...
        'useParallel',true, 'overwriteControlFile',true, 'sizeCalFileFlag', sizeCalFileFlag, ...
        varargin{:});
end

    
end % function