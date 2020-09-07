

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
plot(sort(nanmedian(gazeError,2)),'or')
ylim([0 1.5])
xlabel('Subject number')
ylabel('Median cross-validated absolute gaze error [deg]')