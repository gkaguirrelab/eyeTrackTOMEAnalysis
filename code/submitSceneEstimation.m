function submitSceneEstimation(subjectIdx)


%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, torsDepth, kvals] = defineSubjectSceneParams;


%% Loop over the subjectIdx
for ss = subjectIdx
    
    %% If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    
    %% Anounce we are working on the next subject
    fprintf('\nEstimating scene parameters for subject %d \n',ss);
    
    
    %% Adjust gaze targets for spectacle magnification
    % A spectacle lens has the property of magnifying / minifying the visual
    % world from the perspective of the eye. This alteration scales the
    % apparent visual field positions of the targets and results in a
    % concomittant change in eye movement amplitue. Note that while a contact
    % lens also has a magnification effect (albeit smaller), the lens rotates
    % with the eye. Thus, eye movement amplitude is not altered.
    for ii = 1:length(sceneArgs{ss})
        
        % Determine if this scene has a spectacle lens specified (which is
        % assumed to be on both eyes) or a fixSpectaleLens (which is
        % assumed to just be on the eye that is not being observed with the
        % infrared camera)
        theseArgs = sceneArgs{ss}{ii};
        idx = find(or(strcmp(theseArgs,{'spectacleLens'}),strcmp(theseArgs,{'fixSpectacleLens'})));
        if ~isempty(idx)
            
            % Obtain the magnification for this lens
            args = [eyeArgs{:} 'spectacleLens' theseArgs(idx+1) ];
            tmpSceneGeometry = createSceneGeometry(args{:});
            magnification = tmpSceneGeometry.refraction.retinaToCamera.magnification.spectacle;
            
            % Adjust the gazeTargets and store back in the cell array
            gazeTargets{ss}{ii} = gazeTargets{ss}{ii} .* magnification;
            
        end
    end
    
    
    %% Obtain camera torsion and depth for each scene.
    cameraTorsion = cellfun(@(x) x(1),torsDepth{ss});
    cameraDepth = cellfun(@(x) x(2),torsDepth{ss});
    
    %% Assemble the eye x0 params using the passed kvals
    model=[];
    if isempty(kvals{ss})
        % The mean corneal curvature in the TOME subjects, with 0 corneal
        % torsion, and 2.5 degrees of tilt

        model.eye.x0 = [14.104, 43.399, 44.33653846, 0, 2.5, 0, 0.91, 0.94, 0];
        model.eye.bounds = [5, 5, 5, 180, 5, 2.5, 0.25, 0.25, 30];
    else
        model.eye.x0 = [14.104, kvals{ss}, 2.5, 0, 0.91, 0.94, 0];
        model.eye.bounds = [5, 5, 5, 180, 5, 2.5, 0.25, 0.25, 30];
    end


    %% Special case for TOME_3045
    if ss==45
        % 3045 seems to have quite a short corneal axial length, so
        % starting with a shorter value to help the search along
        model.eye.x0(1) = 9;
    end
    
    %% Special case for TOME_3046
    if ss==46
        model.scene.x0 = [0, 0, cameraTorsion, -2.88, -8.00, cameraDepth ];
    end
    
    %% Special case for the synthesized fixation subjects (01, 02, 03, 05)
    if any([1 2 3 5]==ss)
        searchStrategy = 'synthFix';
    else
        searchStrategy = 'gazeCal';
    end
    
    %% Constrain the eyePose bounds in the errorArgs
    errorArgs = {'eyePoseUB',[25,25,0,4],'eyePoseLB',[-25,-25,0,0.5]}; 

    
    %% Perform the search
    estimateSceneParams(videoStemName{ss}, frameSet{ss}, gazeTargets{ss}, ...
        'searchStrategy',searchStrategy,...
        'cameraDepth',cameraDepth,'cameraTorsion',cameraTorsion,...
        'model',model,...
        'errorArgs',errorArgs,...
        'eyeArgs',eyeArgs{ss},'sceneArgs',sceneArgs{ss});
    
end % Loop over subjects


end % submitSceneEstimation

