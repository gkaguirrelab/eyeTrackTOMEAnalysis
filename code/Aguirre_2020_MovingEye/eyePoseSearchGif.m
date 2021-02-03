%% eyePoseSearchGif
% Illustrate a search across eyePose values to fit eye features.
%{
11: Tweet text goes here
%}
%

clear
close all


% Use the sceneGeometry from an example subject (TOME_3021)
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');
processingBaseDir = fullfile(dropboxBaseDir,'TOME_processing');
videoStemName = fullfile(processingBaseDir,'/session2_spatialStimuli/TOME_3021/060917/EyeTracking/GazeCal01');
load([videoStemName '_sceneGeometry.mat'],'sceneGeometry');

% Pick which of the fixation frames to work with
idx = 1;

% Extract from the existing sceneGeometry the input parameters that we need
% to process just this single sceneGeometry file
frameSet = sceneGeometry.meta.estimateSceneParams.obj.frameSet;

% Get this frame of the video
videoFileName = [videoStemName '_gray.avi'];
theImage = makeMedianVideoImage(videoFileName, 'startFrame', frameSet(idx),'nFrames', 1);

% Grab the material for fitting
Xp = sceneGeometry.meta.estimateSceneParams.obj.perimeter{idx}.Xp;
Yp = sceneGeometry.meta.estimateSceneParams.obj.perimeter{idx}.Yp;

glintCoord = [ ...
    sceneGeometry.meta.estimateSceneParams.obj.glintDataX(idx), ...
    sceneGeometry.meta.estimateSceneParams.obj.glintDataY(idx) ...
    ];

% Define some inaccurate x0 values, to throw the search initialization off
% the trail for a better demo
cameraTransX0 = [0; 0; 0];
eyePoseX0 = [0 0 0 1];

% Search and save the search history
[~, ~, ~, ~, ~, ~, xHist] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry, 'eyePoseX0', eyePoseX0, 'cameraTransX0', cameraTransX0);
xTrue = xHist(end,:);

% Save location for the GIF. Sorry for the Mac bias.
gifSaveName = '~/Desktop/eyePoseSearch.gif';

% These are the elements of the model eye that we will render
modelEyeLabelNames = {'retina' 'pupilEllipse' 'cornea' 'glint_01'};
modelEyePlotColors = {'.w' '-g' '.y' '*r'};

% Get the image dimensions
imDims = size(theImage);

% Initialize the gif with frames that show the features to be fit
renderEyePose([0 0 0 1],sceneGeometry,'backgroundImage',theImage,'newFigure', true,'modelEyeLabelNames',{});
hold on
gif(gifSaveName);
text(10,450,sprintf('eyePose_end = [ % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f ]',xTrue), 'Color', 'g','Interpreter','none');
for ii = 1:5; gif; end
t1 = text(50,50,'Eye features to be fit','FontSize',20,'Color', 'w');
for ii = 1:30; gif; end
h = scatter(Xp,Yp,5,'.','MarkerFaceColor','w');
t2 = text(50,100,'pupil perimeter','FontSize',14,'Color', 'w');
for ii = 1:30; gif; end
delete(h);
delete(t2);
for ii = 1:5; gif; end
h = scatter(glintCoord(1),glintCoord(2),75,'o','MarkerFaceColor','r','MarkerEdgeColor', 'r');
t3 = text(50,150,'glint','FontSize',14,'Color', 'w');
for ii = 1:30; gif; end
delete(h);
delete(t1);
delete(t3);
for ii = 1:30; gif; end


%% Loop over the search history
plotHandles = [];
poseText = [];
for ii = 1:size(xHist,1)

    if ii>1 && max(abs(xHist(ii,:)-xHist(ii-1,:)))<0.001
        continue
    end
    
    delete(plotHandles)
    delete(poseText)
        [~, plotHandles] = renderEyePose(xHist(ii,1:4), sceneGeometry, 'newFigure', false, ...
            'cameraTrans',xHist(ii,5:7)',...
            'modelEyeAlpha',0.5,...
            'modelEyeLabelNames', modelEyeLabelNames, ...
            'modelEyePlotColors', modelEyePlotColors);
    
    poseText = text(10,420,sprintf('eyePose__fit  = [ % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f ]',xHist(ii,:)),'Interpreter','none','Color', 'w');
        
    % This updates the gif
    gif; gif;
    
end

poseText = text(10,420,sprintf('eyePose__fit  = [ % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f, % 2.1f ]',xHist(ii,:)), 'Color', 'g','Interpreter','none');

for ii = 1:60; gif; end

% Close any open windows
close all

