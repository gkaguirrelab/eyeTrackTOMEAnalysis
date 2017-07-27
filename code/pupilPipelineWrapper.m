function pupilPipelineWrapper(pathParams, varargin)

%% Parse input and define variables
p = inputParser; p.KeepUnmatched = true;

% required input
p.addRequired('pathParams',@isstruct);

% optional input
p.addParameter('useLowResSizeCalVideo',false,@islogical);
p.addParameter('grayFileNameOnly',false,@islogical);
p.addParameter('skipStage',[],@iscell);
p.addParameter('skipRun',[],@islogical);
p.addParameter('customKeyValues',[],@(x)(isempty(x) | iscell(x)));

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

% for some subjects, the high-res video of the size calibration step was
% not obtained, only the low-res, LiveTrack "tracked" avi video. If the
% useLowResSizeCalVideo flag is set to true, we copy this low-res video
% over to the dataOutputDir and give it a "gray" suffix, so that it can be
% processed
if p.Results.useLowResSizeCalVideo
    scaleCalLowResVideos = dir(fullfile(pathParams.dataSourceDirFull,'ScaleCalibration*.avi'));
    if ~isempty(scaleCalLowResVideos)
        for rr = 1: length(scaleCalLowResVideos)            
            newFileName = ['LowRes' scaleCalLowResVideos(rr).name(1:end-4) '_gray.avi'];
            scaleCalLowResGrayAVIs(rr).name = newFileName;
            scaleCalLowResGrayAVIs(rr).folder = pathParams.dataOutputDirFull;
            fullFilePathDestination = fullfile(scaleCalLowResGrayAVIs(rr).folder, scaleCalLowResGrayAVIs(rr).name);
            fullFilePathSource = fullfile(scaleCalLowResVideos(rr).folder, scaleCalLowResVideos(rr).name);
            copyfile (fullFilePathSource, fullFilePathDestination)            
        end
    end
end

% if starting from raw2gray, get the file names from the  raw files in the data
% folder. If starting from a later step, get the run name from the gray
% files instead.
if any(strcmp(p.Results.skipStage,'raw2gray'))
    sourceVideos = dir(fullfile(pathParams.dataOutputDirFull,'*_gray.avi'));
    suffixCodes = {'*_gray.avi','GazeCal*gray.avi','*ScaleCal*gray.avi',};
    suffixToTrim = [9, 9, 9];
else
    sourceVideos = dir(fullfile(pathParams.dataSourceDirFull,'*.mov'));
    suffixCodes = {'*_raw.mov','GazeCal*.mov','RawScaleCal*.mov'};
    suffixToTrim = [8, 4, 4];
end

% In the event that we both wish to skip the raw2gray stage and we are
% using the lowResSizeCalVideos, then we need to add these low res videos
% to the sourceVideo list
if p.Results.useLowResSizeCalVideo && ~any(strcmp(p.Results.skipStage,'raw2gray'))
    sourceVideos = [sourceVideos scaleCalLowResGrayAVIs];
end

if ~isempty(p.Results.customKeyValues)
    runNamesToCustomize = cellfun(@(x) x{1},p.Results.customKeyValues,'UniformOutput',false);
else
    runNamesToCustomize=[];
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
    
    % Check if we the current runName matches an entry in the
    % runNamesToCustomize list
    customArgs=[];
    if ~isempty(p.Results.customKeyValues)
        checkForRunNameMatchCell = cellfun(@(x) regexp(pathParams.runName, regexptranslate('wildcard',x)), runNamesToCustomize,'UniformOutput',false);
        checkForRunNameMatchLogical = cellfun(@(x) ~isempty(x),checkForRunNameMatchCell);
        if any(checkForRunNameMatchLogical)
            if length(find(checkForRunNameMatchLogical))==1
                customArgs=p.Results.customKeyValues{find(checkForRunNameMatchLogical)};
                customArgs=customArgs(2:end);
            else
                error('conflicting customKeyValues are set for a run');
            end
        end
    end
    
    if isempty(customArgs)
        % check the high level skipRun flag
        if ~ p.Results.skipRun
            processVideoPipeline( pathParams, ...
                'nFrames',nFrames,'verbosity', verbosity,'tbSnapshot',tbSnapshot, ...
                'useParallel',true, 'overwriteControlFile',true, 'sizeCalFileFlag', sizeCalFileFlag, ...
                varargin{:});
        else
            continue
        end
    else
        % get skipRun flag in customArgs
        srFlag = strcmp(customArgs,'skipRun');
        % check skipRun flag in customArgs
        if any(srFlag) && customArgs{find(srFlag)+1}
            continue
        else
             processVideoPipeline( pathParams, ...
                'nFrames',nFrames,'verbosity', verbosity,'tbSnapshot',tbSnapshot, ...
                'useParallel',true, 'overwriteControlFile',true, 'sizeCalFileFlag', sizeCalFileFlag, ...
                varargin{:}, customArgs{:});
        end % check skipRun flag in customArgs
    end % check is there are custom arguments
end % loop over runs

    
end % function