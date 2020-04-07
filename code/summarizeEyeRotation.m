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
sessionDir = 'session1_restAndStructure';

% Set up some variables to hold the measurements
gazePoseError=nan(1,46);
vecPoseError=nan(1,46);
SR = nan(1,46);
AL = nan(1,46);
aziCenterP1 = nan(1,46);
eleCenterP1 = nan(1,46);
aziCenterP2 = nan(1,46);
eleCenterP2 = nan(1,46);

% Assemble the dataRootDr
dataRootDir = fullfile(rootDir,sessionDir);

% Get the set of "EyeTracking" directories
sessionListStruct=dir(fullfile(dataRootDir,'*/*/*'));
sessionListStruct = sessionListStruct(cellfun(@(x) strcmp(x,'EyeTracking'), {sessionListStruct.name}));

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
        tmp = tmp{end-2};
        subjectID = str2double(tmp(8:9));
                
        % Loop over any gaze cal files for this session
        filePath = fullfile(fileListStruct.folder,fileListStruct.name);
        load(filePath,'sceneGeometry');
        
        aziCenterP1(subjectID) = sceneGeometry.eye.rotationCenters.azi(1);
        aziCenterP2(subjectID) = sceneGeometry.eye.rotationCenters.azi(2);
        eleCenterP1(subjectID) = sceneGeometry.eye.rotationCenters.ele(1);
        eleCenterP2(subjectID) = sceneGeometry.eye.rotationCenters.ele(2);
        AL(subjectID) = sceneGeometry.eye.meta.axialLength;
        gazePoseError(subjectID) = sceneGeometry.meta.estimateSceneParams.rawErrors(3);
        vecPoseError(subjectID) = sceneGeometry.meta.estimateSceneParams.rawErrors(4);
    end
    
end

% Report the accuracy in fitting fixation position
nanmedian(gazePoseError)
nanmedian(vecPoseError)


% Report median rotation values
fprintf('Median azimuth rotation center in mm (P1, P2): %2.2f, %2.2f \n', nanmedian(aziCenterP1),nanmedian(aziCenterP2));
fprintf('Median elevation rotation center in mm (P1, P2): %2.2f, %2.2f \n', nanmedian(eleCenterP1),nanmedian(eleCenterP2));


% Figure 2 -- Azi and Ele values, medians and IQRs
figure
idx = ~isnan(aziCenterP1);
h = scatter(zeros(1,sum(idx))+0.5,-aziCenterP1(idx),200,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
hold on
m = median(-aziCenterP1(idx));

% The IQR is the range between + and - one quartile. So, to plot the IQR
% around a median, we plot +- 1/2 the IQR, which then places the error bar
% on the bounds of the upper and lower quartile.
q = iqr(-aziCenterP1(idx))/2;
plot(1,m,'xk')
plot([1 1],[m+q m-q],'-k');

idx = ~isnan(eleCenterP1);
h = scatter(zeros(1,sum(idx))+1.5,-eleCenterP1(idx),200,'o','MarkerFaceColor','r','MarkerEdgeColor','r');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
m = median(-eleCenterP1(idx));
q = iqr(-eleCenterP1(idx))/2;
plot(2,m,'xr')
plot([2 2],[m+q m-q],'-r');
ylim([0 15])
xlim([0 3])
ylabel('Rotation center depth [mm]');
title('Azi and ele rotation centers. median +- IQR');

% Figure 3 -- Across subjects, the correlation between azi and ele, and the
% correlation of mean rotation center with axial length
figure
subplot(1,2,1);
idx = logical(double(~isnan(aziCenterP1)) .* double(~isnan(eleCenterP1)));
h = scatter(-aziCenterP1(idx),-eleCenterP1(idx),'o','MarkerFaceColor','b','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([8 16]);
ylim([8 16]);
axis square
xlabel('Azimuth depth');
ylabel('Elevation depth');
b = robustfit(-aziCenterP1(idx),-eleCenterP1(idx));
plot(8:15,b(1)+b(2).*(8:15),'r','LineWidth',0.5)
title('Azimuth vs elevation rotation centers across subjects');

subplot(1,2,2);
meanRotationDeth = mean([aziCenterP1;aziCenterP1]);
h = scatter(AL(idx),-meanRotationDeth(idx),'o','MarkerFaceColor','b','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([20 28]);
ylim([8 16]);
axis square
xlabel('Axial legnth [mm]');
ylabel('Mean rotation depth [mm]');
title('Mean rotation depth vs. axial length across subjectsa');
b = robustfit(AL(idx),-meanRotationDeth(idx));
plot(20:28,b(1)+b(2).*(20:28),'r','LineWidth',0.5)


