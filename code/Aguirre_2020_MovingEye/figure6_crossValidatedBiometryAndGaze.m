

%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, torsDepth, kvals] = defineSubjectSceneParams_CrossValidation;

gazeError = nan(45,4);
aziCenterP1 = nan(45,4);
eleCenterP1 = nan(45,4);
k1 = nan(45,4);
k2 = nan(45,4);
SR = nan(1,45);
AL = nan(1,45);
k1Measured = nan(1,45);
k2Measured = nan(1,45);

% Load the subject data table
subjectTableFileName = fullfile(getpref('eyeTrackTOMEAnalysis','dropboxBaseDir'),'TOME_subject','TOME-AOSO_SubjectInfo.xlsx');
opts = detectImportOptions(subjectTableFileName);
subjectTable = readtable(subjectTableFileName, opts);


%% Loop over the subjectIdx
for ss = 1:45
    
    %% If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    %% Get the empirical k1 and k2 vals for this subject
    subString = sprintf(['TOME_30','%0.2d'],ss);
    idx = find(strcmp(subjectTable.TOME_ID,subString));
    k1Measured(ss)=str2double(subjectTable.K1_OD{idx});
    k2Measured(ss)=str2double(subjectTable.K2_OD{idx});
    
    %% Loop over the cross validations
    for cc = 1:4
        
        % The indices that are the training set
        idx = 1:4;
        idx = idx(idx~=cc);
        
        % Load a sceneGeometry in which this index was held out for the
        % training set. All three sceneGeometries created with this
        % given index held out of the training set have the same rotation
        % depth.
        suffixCross = sprintf('_CrossVal_hold0%d',cc);
        sceneGeometryFileName = [videoStemName{ss}{idx(1)} '_sceneGeometry' suffixCross '.mat'];
        load(sceneGeometryFileName,'sceneGeometry');
        
        % Store the rotation centers estimated for this training set
        aziCenterP1(ss,cc) = sceneGeometry.eye.rotationCenters.azi(1);
        eleCenterP1(ss,cc) = sceneGeometry.eye.rotationCenters.ele(1);
        
        % Store the k1, k2 values for this training set
        k1(ss,cc) = sceneGeometry.eye.cornea.kvals(1);
        k2(ss,cc) = sceneGeometry.eye.cornea.kvals(2);
        
        % Load the test sceneGeometry
        suffixTest = sprintf('_CrossVal_test0%d',cc);
        sceneGeometryFileName = [videoStemName{ss}{cc} '_sceneGeometry' suffixTest '.mat'];
        if ~isfile(sceneGeometryFileName)
            continue
        end
        load(sceneGeometryFileName,'sceneGeometry');
        
        gazeError(ss,cc) = sceneGeometry.meta.estimateSceneParams.obj.rawErrors(3);
        
    end

    % Save the axial length for this subject
    AL(ss) = sceneGeometry.eye.meta.axialLength;
    
end % Loop over subjects


% Report the median SEM for estimation of the rotation centers given three
% gaze calibration measurements
fprintf('The median SEM for estimation of the azi rotation center with 3 gaze cal measures is %2.2f \n',nanmedian(nanstd(aziCenterP1')));
fprintf('The median SEM for estimation of the ele rotation center with 3 gaze cal measures is %2.2f \n',nanmedian(nanstd(eleCenterP1')));

% Report the median SEM for estimation of the corneal curvature given three
% gaze calibration measurements
fprintf('The median SEM for estimation of k1 with 3 gaze cal measures is %2.2f \n',nanmedian(nanstd(k1')));
fprintf('The median SEM for estimation of k2 with 3 gaze cal measures is %2.2f \n',nanmedian(nanstd(k2')));

% Now take the median across the four estimates of the rotation centers,
% each of which used a sub-set of 3 of the measurments.
aziCenterP1 = nanmedian(aziCenterP1,2);
eleCenterP1 = nanmedian(eleCenterP1,2);

% Now take the median across the four estimates of the k vals,
% each of which used a sub-set of 3 of the measurments.
k1 = nanmedian(k1,2);
k2 = nanmedian(k2,2);


%% Figure 5a -- k1 and k2 values, across subject medians and IQRs
figHandle = figure();
t=tiledlayout(2,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';
nexttile([2 1]);

idx = ~isnan(k1);
h = scatter(zeros(1,sum(idx))+0.5,k1(idx),200,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
hold on
m = median(k1(idx));

% The IQR is the range between + and - one quartile. So, to plot the IQR
% around a median, we plot +- 1/2 the IQR, which then places the error bar
% on the bounds of the upper and lower quartile.
q = iqr(k1(idx))/2;
plot(1,m,'xk')
plot([1 1],[m+q m-q],'-k');

idx = ~isnan(k2);
h = scatter(zeros(1,sum(idx))+1.5,k2(idx),200,'o','MarkerFaceColor','b','MarkerEdgeColor','b');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
m = median(k2(idx));
q = iqr(k2(idx))/2;
plot(2,m,'xb')
plot([2 2],[m+q m-q],'-b');
ylim([40 50])
xlim([0 2.5])
ylabel('Curvature [Diopters]');
title('k1 and k2 curvature. median ± IQR');


%% Figure 5b -- k1,k2, measured vs. fit
nexttile;
idx = ~isnan(k1) & ~isnan(k1Measured');
h = scatter(k1(idx),k1Measured(idx),'o','MarkerFaceColor','k','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([40 50]);
ylim([40 50]);
axis square
xlabel('k1 measured [diopters]');
ylabel('k1 recovered [diopters]');
[b, k1stats] = robustfit(k1(idx),k1Measured(idx));
rho = corr(k1(idx),k1Measured(idx)');
plot(40:50,b(1)+b(2).*(40:50),'r','LineWidth',0.5)
str = sprintf('n=%d, slope=%2.2f, r=%2.2f, p=%2.2f',sum(idx),b(2),rho,k1stats.p(2));
title({'k1 recovered, ',str});

nexttile;
idx = ~isnan(k2) & ~isnan(k2Measured');
h = scatter(k2(idx),k2Measured(idx),'o','MarkerFaceColor','b','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([40 50]);
ylim([40 50]);
axis square
xlabel('k2 measured [diopters]');
ylabel('k2 recovered [diopters]');
[b, k2stats] = robustfit(k2(idx),k2Measured(idx));
rho = corr(k2(idx),k2Measured(idx)');
plot(40:50,b(1)+b(2).*(40:50),'r','LineWidth',0.5)
str = sprintf('n=%d, slope=%2.2f, r=%2.2f, p=%2.2f',sum(idx),b(2),rho,k2stats.p(2));
title({'k2 recovered, ',str});



fileName = ['~/Desktop/Figure5_k1k2.pdf'];
saveas(figHandle,fileName);





%% Figure 6a -- Azi and Ele values, across subject medians and IQRs
figHandle = figure();
t=tiledlayout(2,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';
nexttile([2 1]);

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
h = scatter(zeros(1,sum(idx))+1.5,-eleCenterP1(idx),200,'o','MarkerFaceColor','b','MarkerEdgeColor','b');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
m = median(-eleCenterP1(idx));
q = iqr(-eleCenterP1(idx))/2;
plot(2,m,'xb')
plot([2 2],[m+q m-q],'-b');
ylim([0 18])
xlim([0 2.5])
ylabel('Rotation center depth [mm]');
title('Azi and ele rotation centers. median ± IQR');


%% Figure 6b -- Correlation between azi and ele with axial length
nexttile;
h = scatter(AL(idx),-aziCenterP1(idx),'o','MarkerFaceColor','k','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([21 28]);
ylim([10 17]);
axis square
xlabel('Axial legnth [mm]');
ylabel('Azi rotation depth [mm]');
[b, axialLengthStats] = robustfit(AL(idx)',-aziCenterP1(idx));
[rho,pval] = corr(AL(idx)',-aziCenterP1(idx));
plot(20:30,b(1)+b(2).*(20:30),'r','LineWidth',0.5)
str=sprintf('n=%d, slope=%2.2f, r=%2.2f, p=%2.2f',sum(idx),b(2),rho,axialLengthStats.p(2));
title({'Azi rotation depth vs. axial length',str});

nexttile;
h = scatter(AL(idx),-eleCenterP1(idx),'o','MarkerFaceColor','b','MarkerEdgeColor','none');
h.MarkerFaceAlpha = 0.25;
hold on
xlim([21 28]);
ylim([10 17]);
axis square
xlabel('Axial legnth [mm]');
ylabel('ele rotation depth [mm]');
[b, axialLengthStats] = robustfit(AL(idx)',-eleCenterP1(idx));
[rho,pval] = corr(AL(idx)',-eleCenterP1(idx));
plot(20:30,b(1)+b(2).*(20:30),'r','LineWidth',0.5)
str=sprintf('n=%d, slope=%2.2f, r=%2.2f, p=%2.2f',sum(idx),b(2),rho,axialLengthStats.p(2));
title({'Ele rotation depth vs. axial length',str});


fileName = ['~/Desktop/Figure6_rotationCenters.pdf'];
saveas(figHandle,fileName);



%% Figure 7 -- Gaze error by subject
figHandle = figure();
[N,edges] = histcounts(nanmedian(gazeError,2),0:0.25:1.5);
for nn=1:length(N)
    for cc=1:N(nn)
        scatter(nn,cc,300,'o','MarkerEdgeColor','none',...
        'MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5);
        hold on
    end
    tickLabels{nn} = [num2str(edges(nn)) ' — ' num2str(edges(nn+1))];
end
xlim([0 length(N)*3])
xticks(1:length(N))
xticklabels(tickLabels)
xtickangle(90)
box off
xlabel('Median absolute gaze error [deg]')
ylabel('Number of subjects')
title('Median gaze error each subject');
fileName = ['~/Desktop/Figure7a_GazeErrorHistogram.pdf'];
saveas(figHandle,fileName);


%% Figure 5c -- Recovered gaze location across subjects for the median performing gaze cal

figHandle = figure();
targetGaze(1,:) = [-7 -7 -7 0 0 0 7 7 7];
targetGaze(2,:) = [-7 0 7 -7 0 7 -7 0 7];
plot(targetGaze(1,:),targetGaze(2,:),'ok','MarkerSize',20);
hold on

% The idx of the gaze calibration that had the accuracy closest to the
% median accuracy for that subject
[~, idx] = min(abs(gazeError - nanmedian(gazeError,2))');

for ss = 1:45
    
    % If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    % Loop over the cross validations
    cc = idx(ss);
    suffixTest = sprintf('_CrossVal_test0%d',cc);
    
    % Load the test sceneGeometry
    sceneGeometryFileName = [videoStemName{ss}{cc} '_sceneGeometry' suffixTest '.mat'];
    if ~isfile(sceneGeometryFileName)
        continue
    end
    load(sceneGeometryFileName,'sceneGeometry');
    
    poseGaze = sceneGeometry.meta.estimateSceneParams.obj.modelPoseGaze;
    
    if isfield(sceneGeometry.refraction.retinaToCamera.magnification,'spectacle')
        mag = sceneGeometry.refraction.retinaToCamera.magnification.spectacle;
        poseGaze = poseGaze./mag;
    end
    
    l = scatter(poseGaze(1,:),poseGaze(2,:),400,'o','MarkerEdgeColor','none',...
        'MarkerFaceColor',[1 0 0],'MarkerFaceAlpha',0.1);
    
end

plot(targetGaze(1,:),targetGaze(2,:),'ok','MarkerSize',20,'LineWidth',2);
title(sprintf('Median across subject error %2.2f deg',nanmedian(nanmedian(gazeError,2))));

xlim([-11 11]);
ylim([-11 11]);
axis square

fileName = ['~/Desktop/Figure7b_GazeErrorOverlay.pdf'];
saveas(figHandle,fileName);

