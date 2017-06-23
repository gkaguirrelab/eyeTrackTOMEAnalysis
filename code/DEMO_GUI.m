function DEMO_GUI


%% set paths and make directories

% create test sandbox on desktop
sandboxDir = '~/Desktop/eyeTrackingDEMO';


% add standard dropbox params
params.projectFolder = 'TOME_data';
params.outputDir = 'TOME_processing';
params.projectSubfolder = 'session2_spatialStimuli';
params.eyeTrackingDir = 'EyeTracking';

params.subjectName = 'TOME_3020';
params.sessionDate = '050517';
params.runName = 'tfMRI_FLASH_AP_run01';


%% start the GUI

testGUI(sandboxDir,params)
