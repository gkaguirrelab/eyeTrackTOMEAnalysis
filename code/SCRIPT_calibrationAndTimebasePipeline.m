%% SCRIPT performing calibration on the TOME dataset

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

% TOME_3001 session1
% no gaze calibration collected
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';
customKeyValue1 = {'T2*','skipStage',{'deriveTimebaseFromLTData'}}; % there is no report for this run
customKeyValues = {customKeyValue1};
calibrationAndTimebasePipelineWrapper(pathParams,'reportSanityCheck',false, ...
    'customKeyValues', customKeyValues);

% TOME_3002 session1 SKIPPED
% no gaze calibration collected
% need to process sizeCal Videos
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
calibrationAndTimebasePipelineWrapper(pathParams,'reportSanityCheck',false);

% TOME_3003 session1 SKIPPED
% no gaze calibration collected
% need to process sizeCal Videos
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '090216';
calibrationAndTimebasePipelineWrapper(pathParams,'reportSanityCheck',false);

% TOME_3004 session1 A
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '091916';
calibrationAndTimebasePipelineWrapper(pathParams,'reportSanityCheck',false);





% TOME_3016 session1
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '031017';
calibrationAndTimebasePipelineWrapper(pathParams,'reportSanityCheck',false);



