%% SCRIPT performing processing of the entire pupil video.

% This analysis script makes the following assumptions: 
% 
% 1. all videos have already gone through the `convertRawToGray` stage. This is to
% save both processing time and hard drive space on analysis machines,
% since the gray videos are much smaller than the raw ones. The convertRawToGray
% stage was performed using this command for all sessions.
pupilPipelineWrapper(pathParams, 'lastStage', 'convertRawToGray')

% 2. an operator predetermined the optimal keyValuesPairs for the analysis
% using this function:
testExtractParams(pathParams, 'nFrames', 100, 'displayMode', true, 'pupilRange', [30 90], 'pupilCircleThresh', 0.06, 'pupilGammaCorrection', 1)

% 3. some sessions will require custom keyValuePairs for different runs.
% This custom key values will be explicitely declared within the script.

% 4. session for which only LowRes Size calibration videos are available are 
% properly flagged.


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
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValue2 = {'LowResScaleCal*', 'frameMask', [40 40]};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 90], 'pupilCircleThresh', 0.035, 'pupilGammaCorrection', .50, ...
    'useLowResSizeCalVideo',true,'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3002 session1
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
customKeyValue1 = {'T1*','pupilRange', [30 90], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .5};
customKeyValue2 = {'rfMRI_REST_*','pupilRange', [30 200], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', 1,'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3003 session1
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '090216';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 100], 'pupilCircleThresh', 0.05, 'pupilGammaCorrection', .5, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3004 session1 A
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '091916';
customKeyValue1 = {'LowResScaleCal*', 'pupilCircleThresh', 0.02, 'pupilRange', [20 60], 'frameMask', [60 40],'perimeterColor','r'};
customKeyValue2 = {'rfMRI_REST_*', 'pupilRange', [30 100], 'pupilCircleThresh', 0.05,'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValue3 = {'dMRI_*', 'pupilRange', [30 100], 'pupilCircleThresh', 0.05 };
customKeyValue4 = {'T1_', 'pupilRange', [30 100], 'pupilCircleThresh', 0.05};
customKeyValue5 = {'T2_', 'pupilRange', [30 100], 'pupilCircleThresh', 0.05};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3; customKeyValue4; customKeyValue5};
pupilPipelineWrapper(pathParams, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3004 session1 B
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '101416';
customKeyValue1 = {'LowResScaleCal*', 'pupilCircleThresh', 0.02,'pupilRange', [10 60], 'frameMask', [60 40],'perimeterColor','r'};
customKeyValue2 = {'rfMRI_REST_*', 'pupilRange', [30 100], 'pupilCircleThresh', 0.05, 'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValue3 = {'GazeCal*', 'pupilRange', [30 100], 'pupilCircleThresh', 0.05};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3};
pupilPipelineWrapper(pathParams, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3005 session1
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '092316';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 100], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .5, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3007 session1
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101116';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'pupilCircleThresh', 0.03, 'glintGammaCorrection', 8, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3008 session1
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '102116';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'pupilGammaCorrection', .5, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3009 session1
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '100716';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3011 session1
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '111116';
customKeyValue1 = {'T1','pupilRange', [40 120], 'pupilCircleThresh', 0.07};
customKeyValue2 = {'rfMRI_REST_*', 'pupilRange', [50 150], 'pupilCircleThresh', 0.06, 'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3013 session1
pathParams.subjectID = 'TOME_3013';
pathParams.sessionDate = '121216';
customKeyValue1 = {'GazeCal','pupilRange', [20 120], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .5};
customKeyValue2 = {'rfMRI_REST_*','pupilRange', [20 200], 'pupilCircleThresh', 0.03, 'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3014 session1
pathParams.subjectID = 'TOME_3014';
pathParams.sessionDate = '021517';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 280], 'pupilCircleThresh', 0.03, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3015 session1
pathParams.subjectID = 'TOME_3015';
pathParams.sessionDate = '030117';
%for calibration runs
customKeyValue1 = {'*Cal*', 'pupilRange', [20 180], 'pupilCircleThresh', 0.05};
customKeyValue2 = {'T*_*', 'pupilRange', [30 200], 'pupilCircleThresh', 0.04};
customKeyValue3 = {'dMRI_*', 'pupilRange', [20 200], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', 1};
customKeyValue4 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3; customKeyValue4};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3016 session1
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '031017';
customKeyValue1 = {'RawScaleCal*', 'pupilGammaCorrection', .7,'frameMask', [60 40]};
customKeyValue2 = {'GazeCal*', 'pupilGammaCorrection', .7,'cutErrorThreshold', 35};
customKeyValue3 = {'T1*', 'pupilGammaCorrection', 1,'glintGammaCorrection', 5.5,'cutErrorThreshold', 25};
customKeyValue4 = {'T2*', 'pupilGammaCorrection', 1,'glintGammaCorrection', 5.5,'cutErrorThreshold', 25};
customKeyValue5 = {'dMRI_*', 'pupilGammaCorrection', 1,'glintGammaCorrection', 5.5,'cutErrorThreshold', 25};
customKeyValue6 = {'rfMRI_REST_*', 'pupilRange', [30 330], 'pupilCircleThresh', 0.06, 'pupilGammaCorrection', 1,'glintGammaCorrection', 5.5,'cutErrorThreshold', 27, ...
    'exponentialTauParams',[.25 .25 10 1 1],'likelihoodErrorExponent',[1.25 1.25 2 2 2], 'ellipseTransparentUB', [320 240 10000 0.35 0.5*pi],'constrainEccen_x_Theta', [0.35 0.35]};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3; customKeyValue4; customKeyValue5; customKeyValue6};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3017 session1
pathParams.subjectID = 'TOME_3017';
pathParams.sessionDate = '032917';
customKeyValue1 = {'*ScaleCal*', 'pupilRange', [20 100], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', 1.3,'frameMask', [2 30]};
customKeyValue2 = {'GazeCal*', 'pupilRange', [30 100], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .7,'cutErrorThreshold', 40};
customKeyValue3 = {'T1*', 'pupilRange', [30 150], 'pupilCircleThresh', 0.03,'cutErrorThreshold',30};
customKeyValue4 = {'T2*', 'pupilRange', [30 150], 'pupilCircleThresh', 0.03, 'cutErrorThreshold',30};
customKeyValue5 = {'rfMRI_REST_*', 'pupilRange', [30 180], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .75,'frameMask', [2 40],'cutErrorThreshold',30, ...
    'exponentialTauParams',[.25 .25 10 1 1],'likelihoodErrorExponent',[1.25 1.25 2 2 2], 'ellipseTransparentUB', [320 240 10000 0.35 0.5*pi],'constrainEccen_x_Theta', [0.35 0.35]};
customKeyValue6 = {'dMRI_*', 'pupilRange', [30 150], 'pupilCircleThresh', 0.03,'cutErrorThreshold',30 };
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3; customKeyValue4; customKeyValue5; customKeyValue6};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3018 session1 -- first date
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '040717';
customKeyValue1 = {'*Cal*', 'pupilRange', [15 100], 'pupilCircleThresh', 0.03};
customKeyValue2 = {'dMRI_*', 'pupilRange', [15 100], 'pupilCircleThresh', 0.03};
customKeyValue3 = {'rfMRI_REST_*', 'pupilRange', [15 200], 'pupilCircleThresh', 0.05,'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3018 session1 -- second date
pathParams.subjectID = 'TOME_3018';
pathParams.sessionDate = '041817';
customKeyValue1 = {'*Cal*', 'pupilRange', [10 100], 'pupilCircleThresh', 0.03};
customKeyValue2 = {'dMRI_*', 'pupilRange', [10 100], 'pupilCircleThresh', 0.03};
customKeyValue3 = {'rfMRI_REST_*', 'pupilRange', [10 140], 'pupilCircleThresh', 0.04, 'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3019 session1
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '042617a';
customKeyValue1 = {'rfMRI_REST_*','exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1};
pupilPipelineWrapper(pathParams, ...
    'pupilCircleThresh', 0.04, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3020 session1
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '042817';
customKeyValue1 = {'*Cal*', 'pupilRange', [15 180], 'pupilCircleThresh', 0.05};
customKeyValue2 = {'T1*', 'pupilRange', [15 180], 'pupilCircleThresh', 0.05};
customKeyValue3 = {'dMRI_*', 'pupilRange', [15 180], 'pupilCircleThresh', 0.05};
customKeyValue4 = {'rfMRI_REST_*', 'pupilRange', [40 300], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .5,'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3; customKeyValue4};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3021 session1
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060717';
customKeyValue1 = {'*Cal*', 'pupilCircleThresh', 0.04};
customKeyValue2 = {'rfMRI_REST_*', 'pupilCircleThresh', 0.04, 'likelihoodErrorExponent', [1.25 1.25 2 2 2],'exponentialTauParams', [.25, .25, 10, 1, 1]};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

% TOME_3022 session1
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061417';
customKeyValue1 = {'*Cal*', 'pupilCircleThresh', 0.04};
customKeyValue2 = {'T1*', 'pupilCircleThresh', 0.03};
customKeyValue3 = {'dMRI_*', 'pupilCircleThresh', 0.03};
customKeyValue4 = {'rfMRI_REST_*', 'pupilRange', [30 400], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', 1,...
    'exponentialTauParams', [.25, .25, 10, 1, 1], 'likelihoodErrorExponent', [1.25 1.25 2 2 2]};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3; customKeyValue4};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);



%% SESSION 2 HERE
pathParams.projectSubfolder = 'session2_spatialStimuli';

%TOME_3001 session2
pathParams.subjectID = 'TOME_3001';
pathParams.sessionDate = '081916';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 200], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75, ...
    'useLowResSizeCalVideo',true,'skipStage', {'convertRawToGray','findGlint','findPupilPerimeter'});

%TOME_3002 session2
pathParams.subjectID = 'TOME_3002';
pathParams.sessionDate = '082616';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 200], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75, ...
    'useLowResSizeCalVideo',true,'skipStage', {'convertRawToGray','findGlint','findPupilPerimeter'});

%TOME_3003 session2
pathParams.subjectID = 'TOME_3003';
pathParams.sessionDate = '091616';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 200], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75, ...
    'useLowResSizeCalVideo',true,'skipStage', {'convertRawToGray','findGlint','findPupilPerimeter'});

%TOME_3004 session2
pathParams.subjectID = 'TOME_3004';
pathParams.sessionDate = '101416';
customKeyValue1 = {'*Cal*', 'pupilRange', [20 200], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75};
customKeyValue2 = {'tfMRI_*', 'pupilRange', [20 180], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .5};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray','findGlint','findPupilPerimeter'}, ...
    'customKeyValues', customKeyValues);

%TOME_3005 session2
pathParams.subjectID = 'TOME_3005';
pathParams.sessionDate = '100316';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 180], 'pupilCircleThresh', 0.07, 'pupilGammaCorrection', .5, ...
    'useLowResSizeCalVideo',true,'skipStage', {'convertRawToGray','findGlint','findPupilPerimeter'});

%TOME_3007 session2
pathParams.subjectID = 'TOME_3007';
pathParams.sessionDate = '101716';
customKeyValue1 = {'*Cal*', 'pupilRange', [20 140], 'pupilCircleThresh', 0.02, 'pupilGammaCorrection', .5};
customKeyValue2 = {'tfMRI_*', 'pupilRange', [30 240], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

%TOME_3008 session2
pathParams.subjectID = 'TOME_3008';
pathParams.sessionDate = '103116';
customKeyValue1 = {'RawScaleCal*', 'pupilRange', [15 100], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75, 'ellipseTransparentLB',[0, 0, 500, 0, -0.5*pi],'perimeterColor','r'};
customKeyValue2 = {'GazeCal*', 'pupilRange', [30 260], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', 0.75, 'glintGammaCorrection', 2.5,'glintRange', [10 40]};
customKeyValue3 = {'tfMRI_*', 'pupilRange', [30 260], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

%TOME_3009 session2
pathParams.subjectID = 'TOME_3009';
pathParams.sessionDate = '102516';
customKeyValue1 = {'*Cal*', 'pupilRange', [15 250], 'pupilCircleThresh', 0.05, 'pupilGammaCorrection', .75};
customKeyValue2 = {'tfMRI_*', 'pupilRange', [30 250], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .75};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'useLowResSizeCalVideo',true, 'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

%TOME_3011 session2
pathParams.subjectID = 'TOME_3011';
pathParams.sessionDate = '012017';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 180], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', .75, ...
    'skipStage', {'convertRawToGray'});

%TOME_3012 session2
pathParams.subjectID = 'TOME_3012';
pathParams.sessionDate = '020317';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 250], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .75, ...
    'skipStage', {'convertRawToGray'});

%TOME_3013 session2
pathParams.subjectID = 'TOME_3013';
pathParams.sessionDate = '011117';
customKeyValue1 = {'RawScaleCal*', 'pupilRange', [20 200], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .7};
customKeyValue2 = {'GazeCal*', 'pupilRange', [20 250], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .75};
customKeyValue3 = {'tfMRI_*', 'pupilRange', [20 250], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .75};
customKeyValues = {customKeyValue1; customKeyValue2; customKeyValue3};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

%TOME_3014 session2
pathParams.subjectID = 'TOME_3014';
pathParams.sessionDate = '021717';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 250], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .75, ...
    'skipStage', {'convertRawToGray'});

%TOME_3015 session2
pathParams.subjectID = 'TOME_3015';
pathParams.sessionDate = '032417';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 200], 'pupilCircleThresh', 0.05, 'pupilGammaCorrection', 1,'frameMask', [30 5], ...
    'skipStage', {'convertRawToGray'});

%TOME_3016 session2
pathParams.subjectID = 'TOME_3016';
pathParams.sessionDate = '032017';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 200], 'pupilCircleThresh', 0.02, 'pupilGammaCorrection', 1, ...
    'skipStage', {'convertRawToGray'});

%TOME_3017 session2
pathParams.subjectID = 'TOME_3017';
pathParams.sessionDate = '033117';
customKeyValue1 = {'*Cal*', 'pupilRange', [20 200], 'pupilCircleThresh', 0.02, 'pupilGammaCorrection', 1};
customKeyValue2 = {'tfMRI_*', 'pupilRange', [20 180], 'pupilCircleThresh', 0.03, 'pupilGammaCorrection', .75};
customKeyValues = {customKeyValue1; customKeyValue2};
pupilPipelineWrapper(pathParams, ...
    'skipStage', {'convertRawToGray'}, ...
    'customKeyValues', customKeyValues);

%TOME_3019 session2
pathParams.subjectID = 'TOME_3019';
pathParams.sessionDate = '050317';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [30 100], 'pupilCircleThresh', 0.02, 'pupilGammaCorrection', .3, ...
    'skipStage', {'convertRawToGray'});

% TOME_3020 session2
pathParams.eyeTrackingDir = 'EyeTracking';
pathParams.subjectID = 'TOME_3020';
pathParams.sessionDate = '050517';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 120], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', 1.5, ...
    'skipStage', {'convertRawToGray'});

% TOME_3021 session2
pathParams.subjectID = 'TOME_3021';
pathParams.sessionDate = '060917';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 90], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', 1.5, ...
    'skipStage', {'convertRawToGray'});

% TOME_3022 session2
pathParams.subjectID = 'TOME_3022';
pathParams.sessionDate = '061617';
pupilPipelineWrapper(pathParams, ...
    'pupilRange', [20 90], 'pupilCircleThresh', 0.04, 'pupilGammaCorrection', 1.5, ...
    'ellipseTransparentLB',[0, 0, 500, 0, -0.5*pi], ...
    'skipStage', {'convertRawToGray'});
