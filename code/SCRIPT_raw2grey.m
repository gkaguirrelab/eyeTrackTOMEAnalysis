% SCRIPT FOR raw2gray

% in this script we convert the raw video from the VTOP device to the gray
% compressed fomat suitable for the analisys.
%
% at a later point in the analysis this script will be integrated in a
% larger one.


%% TEMPLATE
% use this as a model for each session
% 
% dropboxDir = '';
% pathParams.projectFolder = 'TOME_data';
% pathParams.outputDir = 'TOME_processing';
% pathParams.projectFolder = 'TOME_processing';
% 
% pathParams.projectSubfolder = 'sessionX_XXXXXX';
% pathParams.subjectName = 'TOME_30XX';
% pathParams.sessionDate = 'mmddyy';
% 
% pathParams.eyeTrackingDir = 'EyeTracking';
% 
% raw2grayWrapper (dropboxDir,pathParams)


%% TOME_3001 session1

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.projectFolder = 'TOME_data';
pathParams.outputDir = 'TOME_processing';

pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.subjectName = 'TOME_3001';
pathParams.sessionDate = '081916';

pathParams.eyeTrackingDir = 'EyeTracking';

raw2grayWrapper (dropboxDir,pathParams)

%% TOME_3002 session1

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.projectFolder = 'TOME_data';
pathParams.outputDir = 'TOME_processing';

pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.subjectName = 'TOME_3002';
pathParams.sessionDate = '082616';

pathParams.eyeTrackingDir = 'EyeTracking';

raw2grayWrapper (dropboxDir,pathParams)

%% TOME_3003 session1

dropboxDir = '/Users/saguna/Dropbox (Aguirre-Brainard Lab)';
pathParams.projectFolder = 'TOME_data';
pathParams.outputDir = 'TOME_processing';

pathParams.projectSubfolder = 'session1_restAndStructure';
pathParams.subjectName = 'TOME_3003';
pathParams.sessionDate = '090216';

pathParams.eyeTrackingDir = 'EyeTracking';

raw2grayWrapper (dropboxDir,pathParams)


