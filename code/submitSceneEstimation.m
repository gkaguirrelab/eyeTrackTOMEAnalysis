function submitSceneEstimation(subjectIdx)


%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, sceneParamsX0, corneaTorsion] = defineSubjectSceneParams;


%% Loop over the subjectIdx
for ss = subjectIdx
    
    %% If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    
    %% Adjust gaze targets for spectacle magnification
    % A spectacle lens has the property of magnifying / minifying the visual
    % world from the perspective of the eye. This alteration scales the
    % apparent visual field positions of the targets and results in a
    % concomittant change in eye movement amplitue. Note that while a contact
    % lens also has a magnification effect (albeit smaller), the lens rotates
    % with the eye. Thus, eye movement amplitude is not altered.
    for ii = 1:length(sceneArgs{ss})
        
        % Determine if this scene has a spectacle lens specified (which is
        % assumed to be on both eyes) or a fixSpectaleLens (which is assumed to
        % just be on the eye that is not being observed with the infrared
        % camera)
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
    
    
    %% Obtain camera depth and cameraTorsion vectors
    % Grab the camera depth for each scene.
    cameraDepth = cellfun(@(x) x(end),sceneParamsX0{ss});
    cameraTorsion = cellfun(@(x) x(3),sceneParamsX0{ss});
    
    
    %% Perform the search
    estimateSceneParams(videoStemName{ss}, frameSet{ss}, gazeTargets{ss}, ...
        'searchStrategy','gazeCal',...
        'cameraDepth',cameraDepth,'cameraTorsion',cameraTorsion,...
        'corneaTorsion',corneaTorsion{ss},...
        'eyeArgs',eyeArgs{ss},'sceneArgs',sceneArgs{ss});
    
end % Loop over subjects


end % submitSceneEstimation
