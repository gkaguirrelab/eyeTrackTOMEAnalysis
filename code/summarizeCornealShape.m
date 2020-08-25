% This routine loads the sceneGeometry files generated under Sessions 1 and
% 2. In Session 2 there were multiple sceneGeometry measurements per
% session. We use the measurement that had the smallest error in predicting
% fixation location. From each sceneGeometry file we obtain the center of
% rotation of the eye for azimuthal and elevational movements. The test /
% re-test reliability of those measurements are shown across the two
% sessions.


% Get the DropBox base directory
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');

% Define the data directory names
rootDir = fullfile(dropboxBaseDir,'TOME_processing');
experimentNames = {'session2_spatialStimuli'};

% Set up some variables to hold the measurements
gazePoseError=nan(2,4,46);
vecPoseError=nan(2,4,46);



SR = nan(1,46);
AL = nan(1,46);
aziCenterP1 = nan(1,46);
eleCenterP1 = nan(1,46);
aziCenterP2 = nan(1,46);
eleCenterP2 = nan(1,46);

cornealAstigmatism = nan(1,46);

% Loop over session types
for ss = 1:length(experimentNames)
    
    % Assemble the dataRootDr
    dataRootDir = fullfile(rootDir,experimentNames{ss});
    
    % Get the set of "EyeTracking" directories
    sessionListStruct=dir(fullfile(dataRootDir,'*/*/*'));
    sessionListStruct = sessionListStruct(cellfun(@(x) strcmp(x,'EyeTracking'), {sessionListStruct.name}));
    
    figure
    kk = nan(length(sessionListStruct),6);
    % Loop over the list of sessions
    for ii=1:length(sessionListStruct)
        
        % Get the list of gaze sceneGeometry files in this directory
        sessionDir = fullfile(sessionListStruct(ii).folder,sessionListStruct(ii).name);
        fileListStruct=dir(fullfile(sessionDir,'GazeCal*sceneGeometry.mat'));
        
        % If the list is not empty, load up the sceneGeom files and find the
        % one with the best fVal
        if ~isempty(fileListStruct)
            
            % Figure out which subject this is
            tmp = strsplit(sessionDir,filesep);
            sessionLabel = fullfile(tmp{end-2},tmp{end-1});
            subjectIDtxt = tmp{end-2};
            subjectID = str2double(subjectIDtxt(8:9));
            
            % Load the first gaze cal file
            gg = 1;
            
            filePath = fullfile(fileListStruct(gg).folder,fileListStruct(gg).name);
            load(filePath,'sceneGeometry');
            
            kk(ii,:) = [sceneGeometry.eye.cornea.axialRadius, sceneGeometry.eye.cornea.kvals];
%             
%             % Render the corneal surface
%             if ii==4
%                 plotOpticalSystem('surfaceSet',sceneGeometry.refraction.stopToMedium.opticalSystem([1 3],:),'addLighting',true,'newFigure',false);
%             end
%             if ii==11
%                 plotOpticalSystem('surfaceSet',sceneGeometry.refraction.stopToMedium.opticalSystem([1 3],:),'newFigure',false);
%             end
        end
        
    end
    
end

