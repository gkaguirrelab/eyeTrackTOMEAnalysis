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
sessionDirs = {'session1_restAndStructure','session2_spatialStimuli'};

% Set up some variables to hold the measurements
fvals=nan(2,46);
SR = nan(2,46);
AL = nan(2,46);
aziCenter = nan(2,46);
eleCenter = nan(2,46);


% Loop over sessions
for ss = 1:2
    
    % Assemble the dataRootDr
    dataRootDir = fullfile(rootDir,sessionDirs{ss});
    
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
            tmp = tmp{end-2};
            subjectID = str2double(tmp(8:9));
                        
            % Reset some inner loop variables
            sessionFvals = [];
            sessionSR = [];
            sessionAL = [];
            sessionAzi = [];
            sessionEle = [];
            
            % Loop over any gaze cal files for this session
            for gg = 1:length(fileListStruct)
                filePath = fullfile(fileListStruct(gg).folder,fileListStruct(gg).name);
                load(filePath,'sceneGeometry');
                sessionFvals(end+1,:)=sceneGeometry.meta.estimateSceneParams.search.fVal;
                sessionSR(end+1,:)=sceneGeometry.eye.meta.sphericalAmetropia;
                sessionAL(end+1,:)=sceneGeometry.eye.meta.axialLength;
                sessionAzi(end+1,:)=sceneGeometry.eye.rotationCenters.azi(1);
                sessionEle(end+1,:)=sceneGeometry.eye.rotationCenters.ele(1);
            end
            
            % Store the values from the best sceneGeometry
            [~,bestIdx] = min(sessionFvals);
            fvals(ss,subjectID) = sessionFvals(bestIdx);
            SR(ss,subjectID) = sessionSR(bestIdx);
            AL(ss,subjectID) = sessionAL(bestIdx);
            aziCenter(ss,subjectID) = sessionAzi(bestIdx);
            eleCenter(ss,subjectID) = sessionEle(bestIdx);
        end
    end
end

% Report the accuracy in fitting fixation position
medianFixationError = nanmedian(fvals,2)';
idx = ~isnan(fvals(1,:));
iqrFixationError(1) = iqr(fvals(1,idx));
idx = ~isnan(fvals(2,:));
iqrFixationError(2) = iqr(fvals(2,idx));
fprintf('Median absolute fixation errors, session 1 and 2 (degrees): [%2.2f, %2.2f]\n',medianFixationError);
fprintf('IQR absolute fixation errors, session 1 and 2 (degrees): [%2.2f, %2.2f]\n',iqrFixationError);

% Figure 1 -- Reproducibility of center of rotation measurement
figure
subplot(1,2,1);
h = scatter(-aziCenter(1,:),-aziCenter(2,:),100,'o','MarkerFaceColor','k','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
xlim([8 15]);
ylim([8 15]);
xlabel('Session 1');
ylabel('Session 2');
axis square
h = refline(1,0);
h.Color = 'k';
r = corr(aziCenter(1,:)',aziCenter(2,:)','Rows','pairwise');
n = sum(~isnan(sum(aziCenter)));
textString = sprintf('Azimuthal rotation center, n = %d, r = %2.2f',n,r);
title(textString);
subplot(1,2,2);
h = scatter(-eleCenter(1,:),-eleCenter(2,:),100,'o','MarkerFaceColor','r','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
xlim([8 15]);
ylim([8 15]);
xlabel('Session 1');
ylabel('Session 2');
axis square
h = refline(1,0);
h.Color = 'r';
r = corr(eleCenter(1,:)',eleCenter(2,:)','Rows','pairwise');
n = sum(~isnan(sum(aziCenter)));
textString = sprintf('Elevational rotation center, n = %d, r = %2.2f',n,r);
title(textString);

% Take the mean measures across session 1 and 2
meanAziCenter = nanmean(aziCenter);
meanEleCenter = nanmean(eleCenter);
meanSR = nanmean(SR);
meanAL = nanmean(AL);

% Figure 2 -- Azi and Ele values, medians and IQRs
figure
idx = ~isnan(meanAziCenter);
h = scatter(zeros(1,sum(idx))+0.5,-meanAziCenter(idx),200,'o','MarkerFaceColor','k','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.1;
hold on
m = median(-meanAziCenter(idx));
q = iqr(-meanAziCenter(idx));
plot(1,m,'xk')
plot([1 1],[m+q m-q],'-k');

idx = ~isnan(meanEleCenter);
h = scatter(zeros(1,sum(idx))+1.5,-meanEleCenter(idx),200,'o','MarkerFaceColor','r','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.1;
m = median(-meanEleCenter(idx));
q = iqr(-meanEleCenter(idx));
plot(2,m,'xr')
plot([2 2],[m+q m-q],'-r');
ylim([0 15])
xlim([0 3])
ylabel('Rotation center depth [mm]');
title('Azi and ele rotation centers. median +- IQR');
