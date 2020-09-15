
% Get the DropBox base directory
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');

fileNameStem = fullfile(dropboxBaseDir,'TOME_processing','session2_spatialStimuli','TOME_3021','060917','EyeTracking','GazeCal01');

% Load the sceneGeometry
load([fileNameStem '_sceneGeometry.mat'],'sceneGeometry');

fixIdxIn = 1253;

videoFrameIn = makeMedianVideoImage([fileNameStem '_gray.avi'],'startFrame',fixIdxIn,'nFrames',1);


figHandle = figure();
imshow(videoFrameIn,[], 'Border', 'tight');

fileName = ['~/Desktop/Figure2_deriveEyePoseA.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');
close(figHandle)


figHandle = figure();
%blank = zeros(size(videoFrameIn))+0.75;
imshow(videoFrameIn,[], 'Border', 'tight');

Xp = sceneGeometry.meta.estimateSceneParams.obj.perimeter{6}.Xp;
Yp = sceneGeometry.meta.estimateSceneParams.obj.perimeter{6}.Yp;

hold on
plot(Xp,Yp,'.w');

glintCoord = [sceneGeometry.meta.estimateSceneParams.obj.glintDataX(6), ...
    sceneGeometry.meta.estimateSceneParams.obj.glintDataY(6)];

plot(glintCoord(1),glintCoord(2),'or','MarkerFaceColor','r')

fileName = ['~/Desktop/Figure2_deriveEyePoseB.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');
close(figHandle)

eyePose = sceneGeometry.meta.estimateSceneParams.obj.modelEyePose(6,:);
[figHandle, plotObjectHandles]  =  renderEyePose(eyePose, sceneGeometry, ...
        'newFigure', true, 'visible', true, ...
        'backgroundImage',videoFrameIn, ...
        'showAzimuthPlane', false, ...
        'modelEyeLabelNames', {'retina' 'pupilEllipse' 'cornea' 'glint_01'}, ...
        'modelEyePlotColors', {'.w' '-g' '.y' 'Qr'}, ...
        'modelEyeSymbolSizeScaler',1,...
        'modelEyeAlpha', [0.25 1 0.25 1]);
plotObjectHandles(2).LineWidth = 2;
    
    fileName = ['~/Desktop/Figure2_deriveEyePoseC.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');
close(figHandle)
