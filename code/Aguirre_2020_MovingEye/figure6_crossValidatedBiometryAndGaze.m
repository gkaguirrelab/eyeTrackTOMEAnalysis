

%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, torsDepth, kvals] = defineSubjectSceneParams_CrossValidation;

gazeError = nan(45,4);
aziCenterP1 = nan(45,4);
eleCenterP1 = nan(45,4);

%% Loop over the subjectIdx
for ss = 1:45
    
    %% If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    
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
        
        % Load the test sceneGeometry
        suffixTest = sprintf('_CrossVal_test0%d',cc);
        sceneGeometryFileName = [videoStemName{ss}{cc} '_sceneGeometry' suffixTest '.mat'];
        if ~isfile(sceneGeometryFileName)
            continue
        end
        load(sceneGeometryFileName,'sceneGeometry');
        
        gazeError(ss,cc) = sceneGeometry.meta.estimateSceneParams.obj.rawErrors(3);
        
    end
    
end % Loop over subjects


% Report the median SEM for estimation of the rotation centers given three
% gaze calibration measurements
fprintf('The median SEM for estimation of the azi rotation center with 3 gaze cal measures is %2.2f \n',nanmedian(nanstd(aziCenterP1')));
fprintf('The median SEM for estimation of the ele rotation center with 3 gaze cal measures is %2.2f \n',nanmedian(nanstd(eleCenterP1')));

% Now take the median across the four estimates of the rotation centers,
% each of which used a sub-set of 3 of the measurments.
aziCenterP1 = nanmedian(aziCenterP1,2);
eleCenterP1 = nanmedian(eleCenterP1,2);


%% Figure 5b -- Azi and Ele values, across subject medians and IQRs
figHandle = figure();
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
ylim([0 18])
xlim([0 2.5])
ylabel('Rotation center depth [mm]');
title('Azi and ele rotation centers. median ± IQR');

fileName = ['~/Desktop/Figure5b_rotationCenters.pdf'];
saveas(figHandle,fileName);


%% Figure 5d -- Gaze error by subject
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
fileName = ['~/Desktop/Figure5d_GazeErrorHistogram.pdf'];
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

fileName = ['~/Desktop/Figure5c_GazeErrorOverlay.pdf'];
saveas(figHandle,fileName);

