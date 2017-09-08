function calibrationAndTimebasePipelineWrapper(pathParams,varargin)
% gazePipelineWrapper(pathParams,varargin)

% header

%% Parse input and define variables
p = inputParser; p.KeepUnmatched = true;

% required input
p.addRequired('pathParams',@isstruct);

% optional input
p.addParameter('useLiveTrackGazeData',false,@islogical);
p.addParameter('skipStage',[],@iscell);
p.addParameter('skipRun',false,@islogical);
p.addParameter('customKeyValues',[],@(x)(isempty(x) | iscell(x)));
p.addParameter('saveLog',true,@islogical);

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

% define logs directory, log file and start logging
if p.Results.saveLog
    pathParams.logsDirFull = fullfile(pathParams.dataOutputDirRoot, pathParams.projectSubfolder, ...
        pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir,'logs');
    if ~exist(pathParams.logsDirFull, 'dir')
        mkdir(pathParams.logsDirFull)
    end
    logFileName = ['LOG_' datestr(now,'yyyymmdd_HHMMSS.txt')];
    diary (fullfile(pathParams.logsDirFull,logFileName))
    % display some useful header information
    [~,hostname] = system('hostname');
    hostname = strtrim(lower(hostname));
    display (hostname)
    display (version)
    display (pathParams)
    display (p.Results)
    display(p.Results.customKeyValues)
end


%% get all runs available
sourceVideos = dir(fullfile(pathParams.dataOutputDirFull,'*_gray.avi'));
suffixCodes = {'*_gray.avi','GazeCal*gray.avi','*ScaleCal*gray.avi',};
suffixToTrim = [9, 9, 9];

% run the full pipeline on each source video, excluding the calibrations
if p.Results.saveLog
    fprintf('\nProcessing the following videos:\n')
    for rr=1:length(sourceVideos)
        runName=['\t' num2str(rr) '. ' sourceVideos(rr).name '\n'];
        fprintf(runName);
    end
end
% toggle diary
if p.Results.saveLog
    diary OFF
end
for rr = 1 :length(sourceVideos) % loop over video files
    %     toggle diary (so that the file gets updated every run is completed)
    if p.Results.saveLog
        diary ON
    end
    fprintf ('\nProcessing video %d of %d\n',rr,length(sourceVideos))
    
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{1}))
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(1)); %runs
        videoTypeChoice = 'LiveTrackWithVTOP';
    end
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{2}))
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(2)); %gaze calibrations
        continue
    end
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{3}))
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(3)); %scale calibrations
        continue
    end
    
    % Check if we the current runName matches an entry in the
    % runNamesToCustomize list
    if ~isempty(p.Results.customKeyValues)
        runNamesToCustomize = cellfun(@(x) x{1},p.Results.customKeyValues,'UniformOutput',false);
    else
        runNamesToCustomize=[];
    end
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
        if ~p.Results.skipRun
            runCalibrationAndTimebasePipeline( pathParams, ...
                'verbosity', verbosity,'tbSnapshot',tbSnapshot, ...
                'videoTypeChoice', videoTypeChoice, ...
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
            runCalibrationAndTimebasePipeline( pathParams, ...
                'verbosity', verbosity,'tbSnapshot',tbSnapshot, ...
                'videoTypeChoice', videoTypeChoice, ...
                varargin{:}, customArgs{:});
        end % check skipRun flag in customArgs
    end % check is there are custom arguments
    % toggle diary
    if p.Results.saveLog
        diary OFF
    end
end % loop over runs

end % function