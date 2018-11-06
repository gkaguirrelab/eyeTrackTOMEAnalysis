%% SCRIPT timebase


%% define paths and directories

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

% TOME_3001 session1
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';
customKeyValue1 = {'T2*','skipRun',true}; % there is no report for this run (livetrack failed)
customKeyValues = {customKeyValue1};
timebaseWrapper(pathParams,'reportSanityCheck',false, ...
    'customKeyValues', customKeyValues);

% TOME_3002 session1 
% no gaze calibration collected
% need to process sizeCal Videos
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3003 session1
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '090216';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3004 session1 A
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '091916';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3004 session1 B 
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '101416';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3005 session1
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '092316';
timebaseWrapper(pathParams,'reportSanityCheck',false);


% TOME_3007 session1
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101116';
% REST RUNS NOT TRACKED GREAT: low contrast between iris and pupil.
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3008 session1
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '102116';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3009 session1
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '100716';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3011 session1
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '111116';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3012 session1 a
pathParams.subjectID = 'TOME_3012';
pathParams.sessionDate = '020117';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3012 session1 b
pathParams.subjectID = 'TOME_3012';
pathParams.sessionDate = '021017';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3013 session1
pathParams.subjectID = 'TOME_3013';
pathParams.sessionDate = '121216';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3014 session1
pathParams.subjectID = 'TOME_3014';
pathParams.sessionDate = '021517';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3015 session1
pathParams.subjectID = 'TOME_3015';
pathParams.sessionDate = '030117';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3016 session1
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '031017';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3017 session1
pathParams.subjectID = 'TOME_3017';
pathParams.sessionDate = '032917';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3018 session1 -- first date
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '040717';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3018 session1 -- second date
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '041817';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3019 session1
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '042617a';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3020 session1
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '042817';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3021 session1
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060717';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3022 session1
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061417';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3023 session1 a
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '080917';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3023 session1 -b
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '081117';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3024 session1
pathParams.subjectID = 'TOME_3024';
pathParams.sessionDate = '090617';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3025 session1
pathParams.subjectID = 'TOME_3025';
pathParams.sessionDate = '091317';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3026 session1
pathParams.subjectID = 'TOME_3026';
pathParams.sessionDate = '100417';
timebaseWrapper(pathParams,'reportSanityCheck',false);

% TOME_3027 excluded from study

% TOME_3028 session
pathParams.subjectID = 'TOME_3028';
pathParams.sessionDate = '102817';
timebaseWrapper(pathParams,'reportSanityCheck',false);


% TOME_3029 session1
pathParams.subjectID = 'TOME_3029';
pathParams.sessionDate = '120117';
timebaseWrapper(pathParams,'reportSanityCheck',false);


% TOME_3029 session1 -b
pathParams.subjectID = 'TOME_3029';
pathParams.sessionDate = '120617';
timebaseWrapper(pathParams,'reportSanityCheck',false);


% TOME_3030 session1
pathParams.subjectID = 'TOME_3030';
pathParams.sessionDate = '122017';
timebaseWrapper(pathParams,'reportSanityCheck',false);




%% SESSION 2 HERE
pathParams.projectSubfolder = 'session2_spatialStimuli';

%TOME_3001 session2
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3002 session2
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3003 session2
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '091616';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3004 session2
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '101416';
timebaseWrapper(pathParams,'reportSanityCheck',false);
% error in processing video #17. See readme file

%TOME_3005 session2
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '100316';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3007 session2
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101716';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3008 session2
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '103116';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3009 session2
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '102516';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3011 session2
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '012017';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3012 session2
pathParams.subjectID = 'TOME_3012';
pathParams.sessionDate = '020317';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3013 session2
pathParams.subjectID = 'TOME_3013';
pathParams.sessionDate = '011117';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3014 session2
pathParams.subjectID = 'TOME_3014';
pathParams.sessionDate = '021717';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3015 session2
pathParams.subjectID = 'TOME_3015';
pathParams.sessionDate = '032417';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3016 session2
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '032017';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3017 session2
pathParams.subjectID = 'TOME_3017';
pathParams.sessionDate = '033117';
timebaseWrapper(pathParams,'reportSanityCheck',true);

%TOME_3019 session2
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '050317';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3020 session2
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '050517';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3021 session2
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060917';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3022 session2
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061617';
timebaseWrapper(pathParams,'reportSanityCheck',true);


% TOME_3023 session2
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '081117';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3023 session2
pathParams.subjectID = 'TOME_3023';
pathParams.sessionDate = '081117b';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3024 session2
pathParams.subjectID = 'TOME_3024';
pathParams.sessionDate = '090817';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3025 session2
pathParams.subjectID = 'TOME_3025';
pathParams.sessionDate = '091517';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3026 session2
pathParams.subjectID = 'TOME_3026';
pathParams.sessionDate = '100617';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3027 excluded from study

% TOME_3028 session2
pathParams.subjectID = 'TOME_3028';
pathParams.sessionDate = '111517';
timebaseWrapper(pathParams,'reportSanityCheck',true);

% TOME_3029 session2
pathParams.subjectID = 'TOME_3029';
pathParams.sessionDate = '120617';
timebaseWrapper(pathParams,'reportSanityCheck',true);


