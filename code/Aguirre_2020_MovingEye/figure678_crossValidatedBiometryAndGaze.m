

%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, torsDepth, kvals] = defineSubjectSceneParams_CrossValidation;

gazeErrorTrain = nan(45,4);
gazeErrorTest = nan(45,4);
aziCenterP1 = nan(45,4);
eleCenterP1 = nan(45,4);
k1 = nan(45,4);
k2 = nan(45,4);
SR = nan(1,45);
AL = nan(1,45);
k1Measured = nan(1,45);
k2Measured = nan(1,45);
corneaAngles = nan(45,4,3);
isContactLens = false(1,45);
isSpectacleLens = false(1,45);

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
        corneaAngles(ss,cc,:) = sceneGeometry.eye.cornea.rotation;
        
        % Note if there is a contact or spectacle lens in the simulation
        isSpectacleLens(ss) = ~isempty(sceneGeometry.meta.createSceneGeometry.spectacleLens);
        isContactLens(ss) = ~isempty(sceneGeometry.meta.createSceneGeometry.contactLens);
        
        % Load the three training set sceneGeoms and get the median gaze
        % error
        tmpGazeError=[];
        for ii=1:length(idx)
            sceneGeometryFileName = [videoStemName{ss}{idx(ii)} '_sceneGeometry' suffixCross '.mat'];
            load(sceneGeometryFileName,'sceneGeometry');
            tmpGazeError(end+1)=sceneGeometry.meta.estimateSceneParams.obj.rawErrors(3);
        end
        gazeErrorTrain(ss,cc)=median(tmpGazeError);
        
        % Load the test sceneGeometry
        suffixTest = sprintf('_CrossVal_test0%d',cc);
        sceneGeometryFileName = [videoStemName{ss}{cc} '_sceneGeometry' suffixTest '.mat'];
        if ~isfile(sceneGeometryFileName)
            continue
        end
        load(sceneGeometryFileName,'sceneGeometry');
        
        gazeErrorTest(ss,cc) = sceneGeometry.meta.estimateSceneParams.obj.rawErrors(3);
        
    end

    % Save the axial length for this subject
    AL(ss) = sceneGeometry.eye.meta.axialLength;
    
end % Loop over subjects


% Report the median SEM for estimation of the rotation centers given three
% gaze calibration measurements
fprintf('The median jacknife SEM for estimation of the azi rotation center with 4 gaze cal measures is %2.2f \n',nanmedian(sqrt(3).*nanstd(aziCenterP1')));
fprintf('The median jacknife SEM for estimation of the ele rotation center with 4 gaze cal measures is %2.2f \n',nanmedian(sqrt(3).*nanstd(eleCenterP1')));

% Report the median SEM for estimation of the corneal curvature given three
% gaze calibration measurements
fprintf('The median jacknife SEM for estimation of k1 with 3 gaze cal measures is %2.2f \n',nanmedian(sqrt(3).*nanstd(k1')));
fprintf('The median jacknife SEM for estimation of k2 with 3 gaze cal measures is %2.2f \n',nanmedian(sqrt(3).*nanstd(k2')));

% Now take the median across the four estimates of the rotation centers,
% each of which used a sub-set of 3 of the measurments.
aziCenterP1 = nanmedian(aziCenterP1,2);
eleCenterP1 = nanmedian(eleCenterP1,2);

% Now take the median across the four estimates of the k vals,
% each of which used a sub-set of 3 of the measurments.
k1 = nanmedian(k1,2);
k2 = nanmedian(k2,2);


%% Figure 6a -- k1 and k2 values, across subject medians and IQRs
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
yticks(40:2:50)
xlim([0 2.5])
set(gca,'TickDir','out');
ylabel('Corneal curvature [Diopters]','FontSize',12);
title('k1 and k2 curvature. median ± IQR');


%% Figure 6b -- k1,k2, measured vs. fit
nexttile;
idx = ~isnan(k1) & ~isnan(k1Measured');
mdl = fitlm(k1(idx),k1Measured(idx),'linear','RobustOpts','on');
h = mdl.plot;
h(1).Marker = 'o';
h(1).MarkerEdgeColor = 'none';
h(1).MarkerFaceColor = [0.1 0 0];
h(2).LineWidth = 2;
h(3).LineStyle = '-';
h(4).LineStyle = '-';
xlim([40 50]);
ylim([40 50]);
xticks(40:2:50)
yticks(40:2:50)
axis square
set(gca,'TickDir','out');
xlabel('k1 by keratometry [diopters]','FontSize',12);
ylabel('k1 current model [diopters]','FontSize',12);
ci = mdl.coefCI;
ci = ci(2,:);
str = sprintf('n=%d, slope [95%% CI]=%2.2f [%2.2f-%2.2f], p=%2.3f',sum(idx),mdl.Coefficients{2,1},ci,mdl.coefTest);
title({'k1 recovered, ',str});
legend('off')

nexttile;
idx = ~isnan(k2) & ~isnan(k2Measured');
mdl = fitlm(k2(idx),k2Measured(idx),'linear','RobustOpts','on');
h = mdl.plot;
h(1).Marker = 'o';
h(1).MarkerEdgeColor = 'none';
h(1).MarkerFaceColor = [0.1 0 1];
h(2).LineWidth = 2;
h(3).LineStyle = '-';
h(4).LineStyle = '-';
xlim([40 50]);
ylim([40 50]);
xticks(40:2:50)
yticks(40:2:50)
axis square
set(gca,'TickDir','out');
xlabel('k2 by keratometry [diopters]','FontSize',12);
ylabel('k2 current model [diopters]','FontSize',12);
ci = mdl.coefCI;
ci = ci(2,:);
str = sprintf('n=%d, slope [95%% CI]=%2.2f [%2.2f-%2.2f], p=%2.3f',sum(idx),mdl.Coefficients{2,1},ci,mdl.coefTest);
title({'k2 recovered, ',str});
legend('off')


fileName = ['~/Desktop/Figure6_k1k2.pdf'];
saveas(figHandle,fileName);





%% Figure 7a -- Azi and Ele values, across subject medians and IQRs
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

fprintf('The median (±IQR) of the azi rotation center is %2.2f ± %2.2f \n',m,q);

idx = ~isnan(eleCenterP1);
h = scatter(zeros(1,sum(idx))+1.5,-eleCenterP1(idx),200,'o','MarkerFaceColor','b','MarkerEdgeColor','b');
h.MarkerFaceAlpha = 0.10;
h.MarkerEdgeAlpha = 0.15;
m = median(-eleCenterP1(idx));
q = iqr(-eleCenterP1(idx))/2;

fprintf('The median (±IQR) of the ele rotation center is %2.2f ± %2.2f \n',m,q);

plot(2,m,'xb')
plot([2 2],[m+q m-q],'-b');
ylim([0 18])
xlim([0 2.5])
set(gca,'TickDir','out');
ylabel('Rotation center depth [mm]','FontSize',12);
title('Azi and ele rotation centers. median ± IQR');


%% Figure 7b -- Correlation between azi and ele with axial length

nexttile;
mdl = fitlm(AL(idx),-aziCenterP1(idx),'linear','RobustOpts','on');
h = mdl.plot;
h(1).Marker = 'o';
h(1).MarkerEdgeColor = 'none';
h(1).MarkerFaceColor = [0.1 0 0];
h(2).LineWidth = 2;
h(3).LineStyle = '-';
h(4).LineStyle = '-';
xlim([20 28]);
ylim([10 16]);
yticks(10:2:16)
axis square
set(gca,'TickDir','out');
xlabel('Axial length [mm]','FontSize',12);
ylabel('Azi rotation depth [mm]','FontSize',12);
ci = mdl.coefCI;
ci = ci(2,:);
str = sprintf('n=%d, slope [95%% CI]=%2.2f [%2.2f-%2.2f], p=%2.3f',sum(idx),mdl.Coefficients{2,1},ci,mdl.coefTest);
title({'Azi rotation depth vs. axial length',str});
legend('off')


nexttile;
mdl = fitlm(AL(idx),-eleCenterP1(idx),'linear','RobustOpts','on');
h = mdl.plot;
h(1).Marker = 'o';
h(1).MarkerEdgeColor = 'none';
h(1).MarkerFaceColor = [0.1 0 1];
h(2).LineWidth = 2;
h(3).LineStyle = '-';
h(4).LineStyle = '-';
xlim([20 28]);
ylim([10 16]);
yticks(10:2:16)
axis square
set(gca,'TickDir','out');
xlabel('Axial length [mm]','FontSize',12);
ylabel('Ele rotation depth [mm]','FontSize',12);
ci = mdl.coefCI;
ci = ci(2,:);
str = sprintf('n=%d, slope [95%% CI]=%2.2f [%2.2f-%2.2f], p=%2.3f',sum(idx),mdl.Coefficients{2,1},ci,mdl.coefTest);
title({'Ele rotation depth vs. axial length',str});
legend('off')


fileName = ['~/Desktop/Figure7_rotationCenters.pdf'];
saveas(figHandle,fileName);



%% Figure 8a -- Gaze error by subject
figHandle = figure();
vals = nanmedian(gazeErrorTest,2);
[N,edges] = histcounts(vals,0:0.25:1.5);
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
set(gca,'TickDir','out');
title('Median gaze error each subject');
fileName = ['~/Desktop/Figure8a_GazeErrorHistogram.pdf'];
saveas(figHandle,fileName);


%% Figure 8b -- Recovered gaze location across subjects for the median performing gaze cal

figHandle = figure();
targetGaze(1,:) = [-7 -7 -7 0 0 0 7 7 7];
targetGaze(2,:) = [-7 0 7 -7 0 7 -7 0 7];
plot(targetGaze(1,:),targetGaze(2,:),'ok','MarkerSize',20);
hold on

% The idx of the gaze calibration that had the accuracy closest to the
% median accuracy for that subject
[~, idx] = min(abs(gazeErrorTest - nanmedian(gazeErrorTest,2))');

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
title(sprintf('Median across subject error %2.2f deg',nanmedian(nanmedian(gazeErrorTest,2))));

xlim([-11 11]);
ylim([-11 11]);
set(gca,'TickDir','out');
axis square

fileName = ['~/Desktop/Figure8b_GazeErrorOverlay.pdf'];
saveas(figHandle,fileName);

