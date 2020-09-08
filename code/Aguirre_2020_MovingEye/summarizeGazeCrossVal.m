

%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, torsDepth, kvals] = defineSubjectSceneParams_CrossValidation;

gazeError = nan(45,4);

%% Loop over the subjectIdx
for ss = 1:45
    
    %% If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    
    %% Loop over the cross validations
    for cc = 1:4
        suffixCross = sprintf('_CrossVal_hold0%d',cc);
        suffixTest = sprintf('_CrossVal_test0%d',cc);
        
        % The indices that are the training set
        idx = 1:4;
        idx = idx(idx~=cc);
        
        % Load the test sceneGeometry
        sceneGeometryFileName = [videoStemName{ss}{cc} '_sceneGeometry' suffixTest '.mat'];
        if ~isfile(sceneGeometryFileName)
            continue
        end
        load(sceneGeometryFileName,'sceneGeometry');
        
        gazeError(ss,cc) = sceneGeometry.meta.estimateSceneParams.obj.rawErrors(3);
        
    end
    
end % Loop over subjects

nanmedian(nanmedian(gazeError,2))

figure
scatter(1:45,sort(nanmedian(gazeError,2)),200,'o','MarkerEdgeColor','none',...
    'MarkerFaceColor',[1 0 0],'MarkerFaceAlpha',0.5);
ylim([0 1.5])
xlabel('Subject number')
ylabel('Median cross-validated absolute gaze error [deg]')

[~, idx] = min(abs(gazeError - nanmedian(gazeError,2))');

figure
targetGaze(1,:) = [-7 -7 -7 0 0 0 7 7 7];
targetGaze(2,:) = [-7 0 7 -7 0 7 -7 0 7];
plot(targetGaze(1,:),targetGaze(2,:),'ok','MarkerSize',20);
hold on
for ss = 1:45
    
    %% If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    
    %% Loop over the cross validations
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

xlim([-11 11]);
ylim([-11 11]);
axis square
