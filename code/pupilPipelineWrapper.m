function pupilPipelineWrapper(pathParams, varargin)
% pupilPipelineWrapper(pathParams, varargin)
%
%  NEED COMMENTS HERE

%% Parse input and define variables
p = inputParser; p.KeepUnmatched = true;

% required input
p.addRequired('pathParams',@isstruct);

% optional input
p.addParameter('useLowResSizeCalVideo',false,@islogical);
p.addParameter('skipStageByNumber',[],@isnumeric);
p.addParameter('skipStageByName',[],@iscell);
p.addParameter('videoTypeChoice',[],@ischar);
p.addParameter('skipRun',false,@islogical);
p.addParameter('customKeyValues',[],@(x)(isempty(x) | iscell(x)));
p.addParameter('saveLog',true,@islogical);
p.addParameter('consoleSelectAcquisition',false,@islogical);
p.addParameter('acquisitionStems',[],@(x)(isempty(x) | iscell(x)));
p.addParameter('stopOnTbDeployError',false,@islogical);
p.addParameter('obtainTbConfig',true,@islogical);

% parse
p.parse(pathParams, varargin{:});
pathParams=p.Results.pathParams;


%% hard coded parameters
nFrames = Inf; % number of frames to process (set to Inf to do all)
verbose = true; % Set to none to make the analysis silent
TbTbProjectName = 'eyeTrackTOMEAnalysis';


%% TbTb configuration
% We will suppress the verbose output, but detect if there are deploy
% errors and if so stop execution
if p.Results.obtainTbConfig
    tbConfigResult=tbUseProject(TbTbProjectName,'reset','full','verbose',false);
    if sum(cellfun(@sum,extractfield(tbConfigResult, 'isOk')))~=length(tbConfigResult)
        if p.Results.stopOnTbDeployError
            error('There was a tb deploy error. Check the contents of tbConfigResult');
        else
            warning('There was a tb deploy error. Check the contents of tbConfigResult');
        end
    end
    tbSnapshot=tbDeploymentSnapshot(tbConfigResult,'verbose',false);
    clear tbConfigResult
else
    tbSnapshot=[];
end


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
end


% if starting from deinterlaceVideo, get the file names from the  raw files
% in the data folder. If starting from a later step, get the run name from
% the gray files instead.
if  any(strcmp(p.Results.skipStageByName,'deinterlaceVideo')) || any(find(p.Results.skipStageByNumber,1))
    sourceVideos = dir(fullfile(pathParams.dataOutputDirFull,'*_gray.avi'));
    suffixCodes = {'*_gray.avi','GazeCal*gray.avi','*ScaleCal*gray.avi',};
    suffixToTrim = [9, 9, 9];
else
    sourceVideos = dir(fullfile(pathParams.dataSourceDirFull,'*.mov'));
    suffixCodes = {'*_raw.mov','GazeCal*.mov','RawScaleCal*.mov'};
    suffixToTrim = [8, 4, 4];
end

% If the consoleSelectAcquisition flag is set, give the user the option to
% select which acquisition to process
if p.Results.consoleSelectAcquisition
    tmpList = struct2cell(sourceVideos);
    choiceList = tmpList(1,:);
    fprintf('\n\nSelect the acquisitions to process:\n')
    for pp=1:length(choiceList)
        optionName=['\t' num2str(pp) '. ' choiceList{pp} '\n'];
        fprintf(optionName);
    end
    fprintf('\nYou can enter a single acquisition number (e.g. 4),\n  a range defined with a colon (e.g. 4:7),\n  or a list within square brackets (e.g., [4 5 7]):\n')
    choice = input('\nYour choice: ','s');
    sourceVideos = sourceVideos(eval(choice));
end

% If acqusitionStems is not empty, refine the list of source videos to be
% only those that match the acquisition stem
if ~isempty(p.Results.acquisitionStems)
    c = struct2cell(sourceVideos);
    idxMatch = cellfun(@(x) contains(x,p.Results.acquisitionStems),c(1,:));
    if sum(idxMatch)==0
        fprintf(['\n' pathParams.projectSubfolder ' - ' pathParams.subjectID ' - ' pathParams.sessionDate '\n']);
        fprintf('\nNo videos match the acquisition stem(s). Exiting.\n')
        return
    else
        sourceVideos = sourceVideos(idxMatch);
    end
end

if ~isempty(p.Results.customKeyValues)
    runNamesToCustomize = cellfun(@(x) x{1},p.Results.customKeyValues,'UniformOutput',false);
    runNamesToCustomize = cellfun(@(x) eval(x), runNamesToCustomize,'UniformOutput',false);
else
    runNamesToCustomize=[];
end

% run the full pipeline on each source video
if p.Results.saveLog
    fprintf(['\n' pathParams.projectSubfolder ' - ' pathParams.subjectID ' - ' pathParams.sessionDate '\n']);
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
    % Toggle diary (so that the file gets updated every run is completed)
    if p.Results.saveLog
        diary ON
    end
    fprintf ('\nProcessing video %d of %d\n',rr,length(sourceVideos))
    
    if isempty(p.Results.videoTypeChoice)
        if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{1}))
            pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(1)); % runs
            videoTypeChoice = 'LiveTrackWithVTOP_eye';
        end
        if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{2}))
            pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(2)); % gaze calibrations
            videoTypeChoice = 'LiveTrackWithVTOP_eye';
        end
        if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{3}))
            pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(3)); % scale calibrations
            videoTypeChoice = 'LiveTrackWithVTOP_sizeCal';
        end
    else
        videoTypeChoice = p.Results.videoTypeChoice;
        % Assumes here that the suffix of the source video is always
        % "_gray.avi", and thus 9 characters long.
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(1));
    end
    
    % Check if the current runName matches an entry in the
    % runNamesToCustomize list
    customArgs=[];
    if ~isempty(p.Results.customKeyValues)
        checkForRunNameMatchCell = cellfun(@(x) regexp(pathParams.runName, regexptranslate('wildcard',x)), runNamesToCustomize, 'UniformOutput',false);
        % loop and sum each line
        for jj = 1:length(checkForRunNameMatchCell)
            if isnumeric(checkForRunNameMatchCell{jj})
                checkForRunNameMatchLogical(jj) = any(checkForRunNameMatchCell{jj});
            elseif iscell(checkForRunNameMatchCell{jj})
                checkForRunNameMatchLogical(jj) = sum(cellfun(@(x) ~isempty(x), checkForRunNameMatchCell{jj}),2);
            end
        end
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
            runVideoPipeline( pathParams, ...
                'nFrames',nFrames,'verbose', verbose,'tbSnapshot',tbSnapshot, ...
                'useParallel',true, 'overwriteControlFile',true, 'videoTypeChoice', videoTypeChoice, ...
                varargin{:});
        else
            if p.Results.saveLog
                fprintf('Instructed to skip processing.\n')
            end
            continue
        end
    else
        % get skipRun flag in customArgs
        srFlag = strcmp(customArgs,'skipRun');
        % check skipRun flag in customArgs
        if any(srFlag) && customArgs{find(srFlag)+1}
            if p.Results.saveLog
                fprintf('Instructed to skip processing.\n')
            end
            continue
        else
            runVideoPipeline( pathParams, ...
                'nFrames',nFrames,'verbose', verbose,'tbSnapshot',tbSnapshot, ...
                'useParallel',true, 'overwriteControlFile',true, 'videoTypeChoice', videoTypeChoice, ...
                varargin{:}, customArgs{:});
        end % check skipRun flag in customArgs
    end % check is there are custom arguments
    % toggle diary
    if p.Results.saveLog
        diary OFF
    end
end % loop over runs

end % function