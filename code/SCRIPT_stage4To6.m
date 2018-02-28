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
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3002 session1
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3003 session1
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '090216';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3004 session1 A - good
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '091916';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3004 session1 B - good
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '101416';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3005 session1
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '092316';
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3007 session1
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101116';
% REST RUNS NOT TRACKED GREAT: low contrast between iris and pupil.
customKeyValue1 = {'LowResScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);


% TOME_3008 session1
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '102116';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3009 session1
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '100716';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3011 session1
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '111116';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3012 session1 a
pathParams.subjectID = 'TOME_3012';
pathParams.sessionDate = '020117';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3012 session1 b
pathParams.subjectID = 'TOME_3012';
pathParams.sessionDate = '021017';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3013 session1
pathParams.subjectID = 'TOME_3013';
pathParams.sessionDate = '121216';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3014 session1
pathParams.subjectID = 'TOME_3014';
pathParams.sessionDate = '021517';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3015 session1
pathParams.subjectID = 'TOME_3015';
pathParams.sessionDate = '030117';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3016 session1
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '031017';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3017 session1
pathParams.subjectID = 'TOME_3017';
pathParams.sessionDate = '032917';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3018 session1 -- first date
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '040717';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3018 session1 -- second date
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '041817';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3019 session1
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '042617a';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3020 session1
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '042817';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3021 session1
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060717';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3022 session1
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061417';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3023 session1 a
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '080917';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3023 session1 -b
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '081117';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3024 session1
pathParams.subjectID = 'TOME_3024';
pathParams.sessionDate = '090617';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3025 session1
pathParams.subjectID = 'TOME_3025';
pathParams.sessionDate = '091317';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3026 session1
pathParams.subjectID = 'TOME_3026';
pathParams.sessionDate = '100417';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3027 excluded from study

% TOME_3028 session
pathParams.subjectID = 'TOME_3028';
pathParams.sessionDate = '102817';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3029 session1
pathParams.subjectID = 'TOME_3029';
pathParams.sessionDate = '120117';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3029 session1 -b
pathParams.subjectID = 'TOME_3029';
pathParams.sessionDate = '120617';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3030 session1
pathParams.subjectID = 'TOME_3030';
pathParams.sessionDate = '122017';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);



%% SESSION 2 HERE
pathParams.projectSubfolder = 'session2_spatialStimuli';

%TOME_3001 session2
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3002 session2
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3003 session2
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '091616';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3004 session2
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '101416';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3005 session2
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '100316';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3007 session2
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101716';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3008 session2
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '103116';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3009 session2
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '102516';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3011 session2
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '012017';
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3012 session2
pathParams.subjectID = 'TOME_3012';
pathParams.sessionDate = '020317';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3013 session2
pathParams.subjectID = 'TOME_3013';
pathParams.sessionDate = '011117';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3014 session2
pathParams.subjectID = 'TOME_3014';
pathParams.sessionDate = '021717';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3015 session2
pathParams.subjectID = 'TOME_3015';
pathParams.sessionDate = '032417';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3016 session2
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '032017';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3017 session2
pathParams.subjectID = 'TOME_3017';
pathParams.sessionDate = '033117';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

%TOME_3019 session2
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '050317';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3020 session2
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '050517';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3021 session2
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060917';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3022 session2
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061617';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);


% TOME_3023 session2
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '081117';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3023 session2
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '081117b';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3024 session2
pathParams.subjectID = 'TOME_3024';
pathParams.sessionDate = '090817';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3025 session2
pathParams.subjectID = 'TOME_3025';
pathParams.sessionDate = '091517';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3026 session2
pathParams.subjectID = 'TOME_3026';
pathParams.sessionDate = '100617';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3027 excluded from study

% TOME_3028 session2
pathParams.subjectID = 'TOME_3028';
pathParams.sessionDate = '111517';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

% TOME_3029 session2
pathParams.subjectID = 'TOME_3029';
pathParams.sessionDate = '120617';
customKeyValue1 = {'*ScaleCal*', 'skipRun', true,...
   };
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'skipStageByNumber', [1 2 3], 'lastStage','fitPupilPerimeter', ...
    'makeFitVideoByNumber', 6,...
    'useLowResSizeCalVideo',true, ...
    'customKeyValues', customKeyValues);

