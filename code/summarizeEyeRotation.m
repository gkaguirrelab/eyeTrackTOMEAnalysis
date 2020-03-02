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
bestIndices = nan(2,46);
aziCenterP1 = nan(2,46);
eleCenterP1 = nan(2,46);
aziCenterP2 = nan(2,46);
eleCenterP2 = nan(2,46);


% Loop over sessions
for ss = 1:2
    
    fprintf(['\n' sessionDirs{ss} '\n\n']);

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
            sessionLabel = fullfile(tmp{end-2},tmp{end-1});
            tmp = tmp{end-2};
            subjectID = str2double(tmp(8:9));
            
            % Reset some inner loop variables
            xVals = [];
            sessionFvals = [];
            sessionSR = [];
            sessionAL = [];
            sessionAziP1 = [];
            sessionEleP1 = [];
            sessionAziP2 = [];
            sessionEleP2 = [];
            
            % Loop over any gaze cal files for this session
            for gg = 1:length(fileListStruct)
                filePath = fullfile(fileListStruct(gg).folder,fileListStruct(gg).name);
                load(filePath,'sceneGeometry');
                if isfield(sceneGeometry.meta.estimateSceneParams,'rawErrors') && ...
                    isfield(sceneGeometry.meta.estimateSceneParams,'x')
                    sessionFvals(end+1,:)=sceneGeometry.meta.estimateSceneParams.rawErrors(3);
                    sessionSR(end+1,:)=sceneGeometry.eye.meta.sphericalAmetropia;
                    sessionAL(end+1,:)=sceneGeometry.eye.meta.axialLength;
                    sessionAziP1(end+1,:)=sceneGeometry.eye.rotationCenters.azi(1);
                    sessionEleP1(end+1,:)=sceneGeometry.eye.rotationCenters.ele(1);
                    sessionAziP2(end+1,:)=sceneGeometry.eye.rotationCenters.azi(2);
                    sessionEleP2(end+1,:)=sceneGeometry.eye.rotationCenters.ele(2);
                    xVals(end+1,:) = sceneGeometry.meta.estimateSceneParams.x;
                else
                    sessionFvals(end+1,:)=nan;
                    sessionSR(end+1,:)=nan;
                    sessionAL(end+1,:)=nan;
                    sessionAziP1(end+1,:)=nan;
                    sessionEleP1(end+1,:)=nan;
                    sessionAziP2(end+1,:)=nan;
                    sessionEleP2(end+1,:)=nan;
                    if gg == 1
                        xVals = nan(1,10);
                    else
                        xVals(end+1,:)=nan;
                    end
                end
            end
            
            % Store the values from the best sceneGeometry
            [~,bestIdx] = min(sessionFvals);
            bestIndices(ss,subjectID)=bestIdx;
            fvals(ss,subjectID) = sessionFvals(bestIdx);
            SR(ss,subjectID) = sessionSR(bestIdx);
            AL(ss,subjectID) = sessionAL(bestIdx);
%             aziCenterP1(ss,subjectID) = sessionAziP1(bestIdx);
%             eleCenterP1(ss,subjectID) = sessionEleP1(bestIdx);
%             aziCenterP2(ss,subjectID) = sessionAziP2(bestIdx);
%             eleCenterP2(ss,subjectID) = sessionEleP2(bestIdx);
            aziCenterP1(ss,subjectID) = medianw(sessionAziP1,1./sessionFvals,1);
            eleCenterP1(ss,subjectID) = medianw(sessionEleP1,1./sessionFvals,1);
            aziCenterP2(ss,subjectID) = medianw(sessionAziP2,1./sessionFvals,1);
            eleCenterP2(ss,subjectID) = medianw(sessionEleP2,1./sessionFvals,1);

            
            % Obtain the weighted xvals
            medianXVals = medianw( xVals, 1./sessionFvals,1);

            % Report which GazeCal is the best for this session
            if sessionFvals(bestIdx) < 1e6
            msg = [sessionLabel ' - GazeCal0' num2str(bestIdx) '_sceneGeometry.mat - fVal ' num2str(sessionFvals(bestIdx)) '\n'];
            fprintf(msg);
            msg = sprintf('Weighted median (%d cals) rotation centers [%2.2f, %2.2f], cornea [%2.2f, %2.2f, %2.2f, %2.2f] \n',length(fileListStruct),medianXVals(5:10));
            fprintf(msg);
            end            
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
h = scatter(-aziCenterP1(1,:),-aziCenterP1(2,:),100,'o','MarkerFaceColor','k','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
xlim([8 15]);
ylim([8 15]);
xlabel('Session 1');
ylabel('Session 2');
axis square
h = refline(1,0);
h.Color = 'k';
[rho,pval] = corr(aziCenterP1(1,:)',aziCenterP1(2,:)','Rows','pairwise','Type','Spearman');
n = sum(~isnan(sum(aziCenterP1)));
textString = sprintf('Azi center, n = %d, Spearman rho = %2.2f, p = %2.5f',n,rho,pval);
title(textString);
subplot(1,2,2);
h = scatter(-eleCenterP1(1,:),-eleCenterP1(2,:),100,'o','MarkerFaceColor','r','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
xlim([8 15]);
ylim([8 15]);
xlabel('Session 1');
ylabel('Session 2');
axis square
h = refline(1,0);
h.Color = 'r';
[rho,pval] = corr(eleCenterP1(1,:)',eleCenterP1(2,:)','Rows','pairwise','Type','Spearman');
n = sum(~isnan(sum(aziCenterP1)));
textString = sprintf('Ele center, n = %d, Spearman rho = %2.2f, p = %2.5f',n,rho,pval);
title(textString);

% Take the mean measures across session 1 and 2
meanAziCenterP1 = nanmean(aziCenterP1);
meanEleCenterP1 = nanmean(eleCenterP1);
meanAziCenterP2 = nanmean(aziCenterP2);
meanEleCenterP2 = nanmean(eleCenterP2);
meanSR = nanmean(SR);
meanAL = nanmean(AL);

% Report median rotation values
fprintf('Median azimuth rotation center in mm (P1, P2): %2.2f, %2.2f \n', nanmedian(meanAziCenterP1),nanmedian(meanAziCenterP2));
fprintf('Median elevation rotation center in mm (P1, P2): %2.2f, %2.2f \n', nanmedian(meanEleCenterP1),nanmedian(meanEleCenterP2));


% Figure 2 -- Azi and Ele values, medians and IQRs
figure
idx = ~isnan(meanAziCenterP1);
h = scatter(zeros(1,sum(idx))+0.5,-meanAziCenterP1(idx),200,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
hold on
m = median(-meanAziCenterP1(idx));
q = iqr(-meanAziCenterP1(idx));
plot(1,m,'xk')
plot([1 1],[m+q m-q],'-k');

idx = ~isnan(meanEleCenterP1);
h = scatter(zeros(1,sum(idx))+1.5,-meanEleCenterP1(idx),200,'o','MarkerFaceColor','r','MarkerEdgeColor','r');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
m = median(-meanEleCenterP1(idx));

% The IQR is the range between + and - one quartile. So, to plot the IQR
% around a median, we plot +- 1/2 the IQR, which then places the error bar
% on the bounds of the upper and lower quartile.
q = iqr(-meanEleCenterP1(idx))/2;
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
idx = logical(double(~isnan(meanAziCenterP1)) .* double(~isnan(meanEleCenterP1)));
h = scatter(-meanAziCenterP1(idx),-meanEleCenterP1(idx),'o','MarkerFaceColor','b','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([8 16]);
ylim([8 16]);
axis square
xlabel('Azimuth depth');
ylabel('Elevation depth');
b = robustfit(-meanAziCenterP1(idx),-meanEleCenterP1(idx));
plot(8:15,b(1)+b(2).*(8:15),'r','LineWidth',0.5)
title('Azimuth vs elevation rotation centers across subjects');

subplot(1,2,2);
meanRotationDeth = mean([meanAziCenterP1;meanEleCenterP1]);
h = scatter(meanAL(idx),-meanRotationDeth(idx),'o','MarkerFaceColor','b','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([20 28]);
ylim([8 16]);
axis square
xlabel('Axial legnth [mm]');
ylabel('Mean rotation depth [mm]');
title('Mean rotation depth vs. axial length across subjectsa');
b = robustfit(meanAL(idx),-meanRotationDeth(idx));
plot(20:28,b(1)+b(2).*(20:28),'r','LineWidth',0.5)


