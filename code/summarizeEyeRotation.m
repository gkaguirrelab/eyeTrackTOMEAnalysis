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
experimentNames = {'session1_restAndStructure','session2_spatialStimuli'};

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
            
            % Loop over any gaze cal files for this session
            for gg = 1:length(fileListStruct)
                
                filePath = fullfile(fileListStruct(gg).folder,fileListStruct(gg).name);
                load(filePath,'sceneGeometry');
                
                aziCenterP1(subjectID) = sceneGeometry.eye.rotationCenters.azi(1);
                aziCenterP2(subjectID) = sceneGeometry.eye.rotationCenters.azi(2);
                eleCenterP1(subjectID) = sceneGeometry.eye.rotationCenters.ele(1);
                eleCenterP2(subjectID) = sceneGeometry.eye.rotationCenters.ele(2);
                AL(subjectID) = sceneGeometry.eye.meta.axialLength;
                gazePoseError(ss,gg,subjectID) = sceneGeometry.meta.estimateSceneParams.obj.rawErrors(3);
                vecPoseError(ss,gg,subjectID) = sceneGeometry.meta.estimateSceneParams.obj.rawErrors(4);

                cornealAstigmatism(subjectID) = sceneGeometry.eye.cornea.kvals(2) - sceneGeometry.eye.cornea.kvals(1);

            end
            
            % Report the gazeCal that has the lowest eyePose error from
            % the session
            gazeVals = squeeze(gazePoseError(ss,:,subjectID));
            vecVals = squeeze(vecPoseError(ss,:,subjectID));
            if ~all(isnan(gazeVals))
                [val,idx] = nanmin(gazeVals);
                outline = sprintf([subjectIDtxt ': gazeCal0%d, gazeError = %2.2f \n'],idx,val);
                fprintf(outline);
            end
        end
        
    end
    
end

% Report the accuracy in fitting fixation position
a = nanmedian(squeeze(nanmin(gazePoseError(1,:,:))));
b = nanmedian(squeeze(nanmin(vecPoseError(1,:,:))));
outline = sprintf('\nSession 1. Median best gaze error %2.2f, vec error %2.2f \n',a,b);
fprintf(outline);
a = nanmedian(squeeze(nanmin(gazePoseError(2,:,:))));
b = nanmedian(squeeze(nanmin(vecPoseError(2,:,:))));
outline = sprintf('nSession 2. Median best gaze error %2.2f, vec error %2.2f \n',a,b);
fprintf(outline);


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
xlim([10 16]);
ylim([10 16]);
axis square
xlabel('Azimuth depth');
ylabel('Elevation depth');
[b, aziEleCorrStats] = robustfit(-aziCenterP1(idx),-eleCenterP1(idx));
[rho,pval] = corr(-aziCenterP1(idx)',-eleCenterP1(idx)');
plot(12:16,b(1)+b(2).*(12:16),'r','LineWidth',0.5)
str = sprintf('slope=%2.2f, r=%2.2f, p=%2.2f',b(2),rho,pval);
title({'Azi vs. ele centers',str});

subplot(1,2,2);
meanRotationDeth = mean([aziCenterP1;aziCenterP1]);
h = scatter(-meanRotationDeth(idx),AL(idx),'o','MarkerFaceColor','b','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([10 17]);
ylim([21 28]);
axis square
xlabel('Mean rotation depth [mm]');
ylabel('Axial legnth [mm]');
[b, axialLengthStats] = robustfit(-meanRotationDeth(idx),AL(idx));
[rho,pval] = corr(-meanRotationDeth(idx)',AL(idx)');
plot(12:16,b(1)+b(2).*(12:16),'r','LineWidth',0.5)
str=sprintf('slope=%2.2f, r=%2.2f, p=%2.2f',b(2),rho,pval);
title({'Rotation depth vs. axial length',str});

