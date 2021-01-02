% Create a gif that illustrates the scene search process

% clear
% close all
% 
% % Use the sceneGeometry from an example subject (TOME_3021)
% videoStemName = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session2_spatialStimuli/TOME_3021/060917/EyeTracking/GazeCal01';
% load([videoStemName '_sceneGeometry.mat'],'sceneGeometry');
% 
% % Extract from the existing sceneGeometry the input parameters that we need
% % to process just this single sceneGeometry file
% frameSet = sceneGeometry.meta.estimateSceneParams.obj.frameSet;
% gazeTargets = sceneGeometry.meta.estimateSceneParams.obj.gazeTargets;
% eyeArgs = sceneGeometry.meta.estimateSceneParams.obj.meta.eyeArgs;
% sceneArgs = sceneGeometry.meta.estimateSceneParams.obj.meta.sceneArgs{2};
% errorArgs = sceneGeometry.meta.estimateSceneParams.obj.meta.errorArgs;
% cameraDepth = sceneGeometry.meta.estimateSceneParams.obj.meta.cameraDepth(2);
% cameraTorsion = sceneGeometry.meta.estimateSceneParams.obj.meta.cameraTorsion(2);
% 
% % Prevent a search across camera depth by setting the bounds in the last
% % position to zero for eye and scene.
% model.eye.bounds = [5, 5, 5, 180, 5, 2.5, 0.25, 0.25, 0];
% model.scene.bounds = [10 10 10 20 20 0];
% 
% % Run the search
% sceneObject = estimateSceneParams(videoStemName,frameSet,gazeTargets, ...
%     'model',model,...
%     'eyeArgs',eyeArgs,'sceneArgs',sceneArgs,'errorArgs',errorArgs,...
%     'cameraDepth',cameraDepth,'cameraTorsion',cameraTorsion,...
%     'searchStrategy','gazeCal','savePlots',false,'saveFiles',false);

% Get the x parameter history
xHist = sceneObject{1}.xHist;

% Save location for the GIF. Sorry for the Mac bias.
gifSaveName = '~/Desktop/sceneSearch.gif';

% Loop over the iterations, plot, and save to the gif
for ii = 1:size(xHist,1)
    
    % Get this set of parameeters
    x = squeeze(sceneObject{1}.xHist(ii,:));
    
    if ii==1
        xLast = x;
    else
        x = squeeze(sceneObject{1}.xHist(ii-1,:));
    end
    
    % Update the scene object for this iteration
    sceneObject{1}.x=x;
    sceneObject{1}.updateScene;
    sceneObject{1}.updateError(sceneObject{1}.errorArgs{:});
    
    % Create a montage of the model for this iteration, load it into
    % memory, and delete the version saved to disk
    fileNameSuffix = sprintf('_iter%0.3d',ii);
    sceneObject{1}.saveEyeModelMontage(fileNameSuffix,true,true)
    fileName = [videoStemName '_sceneGeometry_eyeModelMontage' fileNameSuffix '.png'];
    montageImage = imread(fileName);
    delete(fileName);
    
    % Setup a figure
    if ii==1
        figHandle = figure;
        figHandle.Position = [91 146 1130 659];
        figHandle.Color = 'w';
    else
        clf(figHandle,'reset')
    end
    
    t=tiledlayout(3,4);
    t.TileSpacing = 'none';
    t.Padding = 'none';
    
    % Display the montage
    nexttile([3 3])
    imshow(montageImage)
    
    % Plot the ability of the rotation values assigned to each eyePose to map
    % to the list of gaze targets
    
    % Get the values for this iteration
    modelPoseGaze = sceneObject{1}.modelPoseGaze;
    rawErrors = sceneObject{1}.rawErrors;
    
    % Plot gaze error
    nexttile([1 1])
    plot(gazeTargets(1,:),gazeTargets(2,:),'ok','MarkerSize',10); hold on;
    plot(modelPoseGaze(1,:),modelPoseGaze(2,:),'xr','MarkerSize',10); hold on;
    ylim([-10 10])
    xlim([-10 10])
    axis square
    str = sprintf('Gaze error = %2.2f°',rawErrors(3));
    title(str);
    xlabel('gaze position [deg]')
    ylabel('gaze position [deg]')
    
    % Text display for this iteration
    nexttile([1 1]);
    plot(0,0,'.')
    axis off
    text(0,0.8,sprintf('Iteration %0.3d',ii),'FontSize',14,'HorizontalAlignment','center');
    text(-1,0.6,'Eye','FontSize',12,'HorizontalAlignment','left');

    str = addColor(sprintf('corneal axial length [mm]: $%2.2f',x(5)),x(5) == xLast(5));
    text(-0.9,0.4,str,'FontSize',12,'HorizontalAlignment','left');

    str = addColor(sprintf('k1, k2 [D]: $%2.2f, %2.2f',x(6:7)),all(x(6:7) == xLast(6:7)));    
    text(-0.9,0.2,str,'FontSize',12,'HorizontalAlignment','left');

    str = addColor(sprintf('torsion, tilt, tip [deg]: $%2.2f, %2.2f, %2.2f',x(8:10)),all(x(8:10) == xLast(8:10)));
    text(-0.9,0.0,str,'FontSize',12,'HorizontalAlignment','left');
    
    str = addColor(sprintf('rotation center [joint, diff]: $%2.2f, %2.2f',x(11:12)),all(x(11:12) == xLast(11:12)));
    text(-0.9,-0.2,str,'FontSize',12,'HorizontalAlignment','left');
    
    text(-1,-0.4,'Scene','FontSize',12,'HorizontalAlignment','left');
    
    str = addColor(sprintf('primary position [deg]: $%2.2f, %2.2f',x(14:15)),all(x(14:15) == xLast(14:15)));
    text(-0.9,-0.6,str,'FontSize',12,'HorizontalAlignment','left');
    
    str = addColor(sprintf('camera torsion [deg]: $%2.2f',x(16)),x(16) == xLast(16));
    text(-0.9,-0.8,str,'FontSize',12,'HorizontalAlignment','left');
    
    str = addColor(sprintf('camera position [mm]: $%2.2f, %2.2f, %2.2f',x(17:19)),all(x(17:19) == xLast(17:19)));
    text(-0.9,-1,str,'FontSize',12,'HorizontalAlignment','left');
    
    % Plot the raw error
    nexttile([1 1]);
    errorScale = [25 0.25 10 50];
    bAx = bar(1:4,log10(50*sceneObject{1}.rawErrors([1 2 3 5])./errorScale),'FaceColor',[0.5 0.5 0.5]);
    xlim([0.5 4.5]);
    ylim([0 2]);
    title('log_1_0 error')
    set(gca,'xticklabel',categorical({'perim','glint','gaze','trans'}))
    set(gca,'Color','none');
    set(gca, 'YTick', []);
    box off
    
    % Update the gif
    if ii==1
        gif(gifSaveName,'frame',figHandle);
        gif('frame',figHandle);
    else
        gif('frame',figHandle);
        gif('frame',figHandle);
    end
    
end

close all


function str = addColor(str,flag)
    if flag
        str = strrep(str,'$','');
    else
        str = strrep(str,'$','\color[rgb]{1,0,0}');
    end

end
