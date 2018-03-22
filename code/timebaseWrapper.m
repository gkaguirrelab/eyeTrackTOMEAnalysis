function timebaseWrapper (pathParams,varargin)
% timebaseWrapper (pathParams,varargin)

%  header goes here


%% Parse input and define variables
p = inputParser; p.KeepUnmatched = true;

% required input
p.addRequired('pathParams',@isstruct);

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

% derive timebase on each source video, excluding the calibrations
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
    
    % locate and skip calibrations, process MRI runs
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{2})) || regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{3}))
        continue
    elseif regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{1}))
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(1)); %runs
        
        % check if we the current runName matches an entry in the
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
                
                % define input and output filenames
                glintFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_glint.mat']);
                ltReportFileName = fullfile(pathParams.dataSourceDirFull, [pathParams.runName '_report.mat']);
                timebaseFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_timebase.mat']);
                
                % derive timebase
                deriveTimebaseFromLTData(glintFileName,ltReportFileName,timebaseFileName, varargin{:});
            end % check skipRun flag in customArgs
        end % check is there are custom arguments
    end  % locate and skip calibrations, process MRI runs
    
    % toggle diary
    if p.Results.saveLog
        diary OFF
    end    
end % loop over runs

end % function