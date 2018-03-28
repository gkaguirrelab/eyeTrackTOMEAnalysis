function sizeCalibrationWrapper(pathParams,varargin)
% sizeCalibrationWrapper(pathParams,varargin)

% this wrapper assumes that the size calibration videos have been processed
% up to stage 3 (findPupilPerimeter).
%
% The routine is composed of 3 stages:
% 1. fitPupilPerimeter
% 2. calcSizeCalibration
% 3. applySizeCalibration
%
% The perimeter file will be fitted
% with an ellipse with minimal constraints, without going through the
% creation of a control file. After fitting the perimeter, the routine will
% calculate the size calibration factor. Then the calibration is applied to
% the avaliable runs. The first and last stage can be toggled off by
% assigning false to the respective custom key value. The skip Calibration flag can
% only be applied to SizeCalibration run to be escluded by the computation
% of the size Factors.

%% Parse input and define variables
p = inputParser; p.KeepUnmatched = true;

% required input
p.addRequired('pathParams',@isstruct);

% optional input
p.addParameter('skipFitPupilPerimeter',false,@islogical);
p.addParameter('skipApplySizeCalibration',false,@islogical);
p.addParameter('skipRun',false,@islogical);
p.addParameter('customKeyValues',[],@(x)(isempty(x) | iscell(x)));
p.addParameter('saveLog',true,@islogical);

% parse
p.parse(pathParams, varargin{:})
pathParams=p.Results.pathParams;


%% hard coded parameters
nFrames = Inf; % number of frames to process (set to Inf to do all)
verbosity = 'full'; % Set to none to make the demo silent
TbTbProjectName = 'eyeTrackTOMEAnalysis';


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

% Show all runs available
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

%% fit the perimeter of the calibration runs
% intialize calibration file index
ii = 1;

for rr = 1 :length(sourceVideos) % loop over video files
    
    %     toggle diary (so that the file gets updated when every run is completed)
    if p.Results.saveLog
        diary ON
    end
    fprintf ('\nProcessing video %d of %d\n',rr,length(sourceVideos))
    
    % locate and process calibration runs
    if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{3}))
        
        % extract the run name
        pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(3));
        
        % define input and output filenames
        perimeterFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_perimeter.mat']);
        pupilFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_pupil.mat']);
        
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
            if ~p.Results.skipFitPupilPerimeter
                fitPupilPerimeter(perimeterFileName, pupilFileName, ...
                    'verbosity', verbosity,'tbSnapshot',tbSnapshot);
            end
            sizeDataFilesNames(ii) = fullfile(pathParams.dataOutputDirFull,pathParams.runName);
            ii = ii+1;
        else
            % get skipRun flag in customArgs
            srFlag = strcmp(customArgs,'skipRun');
            % check skipRun flag in customArgs
            if any(srFlag) && customArgs{find(srFlag)+1}
                continue
            else
                if ~p.Results.skipFitPupilPerimeter
                    fitPupilPerimeter(perimeterFileName, pupilFileName, ...
                        'verbosity', verbosity,'tbSnapshot',tbSnapshot, ...
                        varargin{:});
                end
                sizeDataFilesNames(ii) = fullfile(pathParams.dataOutputDirFull,pathParams.runName);
                ii = ii+1;
            end % check skipRun flag in customArgs
        end % check is there are custom arguments
        
    else % exclude runs with an actual eye
        continue
    end  % locate and process calibration runs
    
    % toggle diary
    if p.Results.saveLog
        diary OFF
    end
end % loop over runs

% clear calibrations index
clear ii

%% calculate size factor
sizeCalFactorsFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.subjectID '_' pathParams.sessionDate '_sizeCalFactors.mat']);
calcSizeCalFactors(sizeDataFilesNames, sizeCalFactorsFileName, varargin{:});

%% apply size factor to all runs in the session
if ~p.Results.skipApplySizeCalibration
    for rr = 1 :length(sourceVideos) % loop over video files
        
        % toggle diary (so that the file gets updated when every run is completed)
        if p.Results.saveLog
            diary ON
        end
        fprintf ('\nApplying size calibration %d of %d\n',rr,length(sourceVideos))
        
        % locate and process calibration runs
        if regexp(sourceVideos(rr).name, regexptranslate('wildcard',suffixCodes{3}))
            continue
        else
            pathParams.runName = sourceVideos(rr).name(1:end-suffixToTrim(1));
            pupilFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_pupil.mat']);
            calibratedPupilFileName = fullfile(pathParams.dataOutputDirFull, [pathParams.runName '_calibratedPupil.mat']);
            applySizeCalibration(pupilFileName,sizeCalFactorsFileName,calibratedPupilFileName);
        end
        % toggle diary
        if p.Results.saveLog
            diary OFF
        end
    end
end




