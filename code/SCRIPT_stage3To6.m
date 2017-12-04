%% SCRIPT makeControlFile -->initial ellipse fit
% header goes here

% note: skipping all scale calibration at this stage

%% Common to all script lines to define the dropbox directories

% set dropbox directory
[~,hostname] = system('hostname');
hostname = strtrim(lower(hostname));
if strcmp(hostname,'melchior.uphs.upenn.edu') %melchior has some special dropbox folder settings
    dropboxDir = '/Volumes/Bay_2_data/giulia/Dropbox-Aguirre-Brainard-Lab';
else % other machines use the standard dropbox location
    [~, userName] = system('whoami');
    userName = strtrim(userName);
    dropboxDir = ...
        fullfile('/Users', userName, ...
        '/Dropbox (Aguirre-Brainard Lab)');
end

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.eyeTrackingDir = 'EyeTracking';


%% SESSION 1 HERE
pathParams.projectSubfolder = 'session1_restAndStructure';

% TOME_3001 session1 - good
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3002 session1
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3003 session1
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '090216';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3004 session1 A - good
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '091916';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3004 session1 B - good
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '101416';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3005 session1
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '092316';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3007 session1
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101116';
% REST RUNS NOT TRACKED GREAT: low contrast between iris and pupil.
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);


% TOME_3008 session1
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '102116';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3009 session1
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '100716';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3011 session1
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '111116';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);
