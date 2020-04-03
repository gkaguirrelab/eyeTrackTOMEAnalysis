function submitSceneEstimation(subjectIdx)


%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, sceneParamsX0] = defineSubjectSceneParams;


%% Loop over the subjectIdx
for ss = subjectIdx
    
    
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
    
    
    %% Obtain the mean camera depth parameter
    % While we have entie sceneParams, the scene estimation routine just need a
    % reasonable estimate of camera depth. This can be the same for all scenes,
    % and the routine will adjust this as needed in the search for each scene.
    cameraDepth = round(mean(cellfun(@(x) x(end),sceneParamsX0{ss})));
    
    
    %% Perform the search
    estimateSceneParams(videoStemName{ss}, frameSet{ss}, gazeTargets{ss}, ...
        'searchStrategy','gazeCal','cameraDepth',cameraDepth,...
        'eyeArgs',eyeArgs{ss},'sceneArgs',sceneArgs{ss});
    
end % Loop over subjects


end % submitSceneEstimation

