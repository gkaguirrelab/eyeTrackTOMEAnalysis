% SCRIPT performing processing of the entire pupil video.



%% TEMPLATE
% use this as a model for each session

% dropboxDir = '';
% params.outputDir = 'TOME_processing';
% params.projectFolder = 'TOME_processing';

% params.projectSubfolder = 'sessionX_XXXXXX';
% params.subjectName = 'TOME_30XX';
% params.sessionDate = 'mmddyy';

% params.eyeTrackingDir = 'EyeTracking';

% glintTrackingWrapper(dropboxDir,params)

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';

%% TOME_3015 session1

% define path parameters
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';

pupilPipelineWrapper(dropboxDir,params)




