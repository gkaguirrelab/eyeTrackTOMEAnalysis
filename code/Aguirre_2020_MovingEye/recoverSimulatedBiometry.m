% This routine runs simulations and plots the results, providing the raw
% figure panels for Figure 4 of Aguirre 2020, moving eye

clear
close all

% How many scenes and boots?
nScenes = 1;
nBoots = 10;

% Constrain the bounds so that we do not search over depth
model.eye.x0 = [14.104, 44.2410, 45.6302, 0, 2.5000, 0, 1, 1, 0];
model.eye.bounds = [0, 5, 5, 180, 5, 2.5, 0.25, 0.25, 0];
model.scene.bounds = [10 10 10 20 20 0];

% Set up the eye params to vary in simulation
valRange = model.eye.x0(1) - model.eye.bounds(1) : 0.1 : model.eye.x0(1) + model.eye.bounds(1);
corneaAxialRadius = repmat(14.104,nBoots,1);
valRange = model.eye.x0(3) - model.eye.bounds(3) : 0.1 : model.eye.x0(3) + model.eye.bounds(3);
kvals = [randsample(valRange,nBoots); randsample(valRange,nBoots)]';
needSwap = kvals(:,1)>kvals(:,2);
kvals(needSwap,:) = fliplr(kvals(needSwap,:));
valRange = 0.75:0.01:1.25;
rotationCenterScalers = [randsample(valRange,nBoots); randsample(valRange,nBoots)]';

% Set up the scene params to vary in simulation
valRange = -10:0.1:10;
cameraTrans = [randsample(valRange,nBoots); randsample(valRange,nBoots); zeros(1,nBoots)];

% Define a set of gaze targets at ±7°
frameSet = 1:9;
gazeTargets(1,:) = [-7 -7 -7 0 0 0 7 7 7];
gazeTargets(2,:) = [-7 0 7 -7 0 7 -7 0 7];

% How much noise are we adding to the glints and perimeters?
perimNoise = 0;

% Define a save location for results
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');
outDir = fullfile(dropboxBaseDir,'TOME_analysis','modelSimulations','recoverSimulatedBiometry');

% Loop over simulations
for bb = 1:nBoots
    
    % Create a sceneGeometry with these parameters
    sceneGeometry=createSceneGeometry(...
        'corneaAxialRadius',corneaAxialRadius(bb),...
        'kvals',kvals(bb,:),...
        'rotationCenterScalers',rotationCenterScalers(bb,:));
    sceneGeometry.cameraPosition.translation = ...
        sceneGeometry.cameraPosition.translation + cameraTrans(:,bb);
        
    % Assemble a set of scenes
    for ss = 1:nScenes
        
        glintData = [];
        perimeter = [];
        
        % Loop over the gaze targets and get 
        for pp = 1:size(gazeTargets,2)
                        
            eyePose = [gazeTargets(1,pp),gazeTargets(2,pp),0,2];
            [ targetEllipse, glintCoordOrig ] = projectModelEye(eyePose,sceneGeometry);
            
            % Obtain the glintCoord and perimeter points of the ellipse, adding
            % noise
            glintCoord = glintCoordOrig + randn(size(glintCoordOrig)).*perimNoise;
            [ Xp, Yp ] = ellipsePerimeterPoints( targetEllipse, 10, 0, perimNoise );
            
            glintData.X(pp,1) = glintCoord(1);
            glintData.Y(pp,1) = glintCoord(2);
            
            perimeter.data{pp}.Xp = Xp;
            perimeter.data{pp}.Yp = Yp;
            
        end
        
        pCell{ss}=perimeter;
        gCell{ss}=glintData;
        
    end
    
    sceneObjects = estimateSceneParams(repmat({'simulate'},nScenes,1), repmat({frameSet},nScenes,1),repmat({gazeTargets},nScenes,1), ...
        'searchStrategy','gazeCal','savePlots',false,'saveFiles',false, ...
        'model',model,'glintData',gCell,'perimeter',pCell);
    
%    corneaAxialRadiusRecovered(bb) = sceneObjects{1}.x(5);
    kvalsRecovered(bb,:) = sceneObjects{1}.x(6:7);
    rotationCenterScalersRecovered(bb,:) = sceneObjects{1}.x(11:12);
    cameraTransRecovered(:,bb) = sceneObjects{1}.x(17:19)';
    
end

stateSaveName = tempname(outDir);
save(stateSaveName)
