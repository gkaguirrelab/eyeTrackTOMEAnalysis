% This routine runs simulations and plots the results, providing the raw
% figure panels for Figure 4 of Aguirre 2020, moving eye

clear
close all

% How many scenes and boots?
nScenes = 1;
nBoots = 250;

% Define a save location for results
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');
outDir = fullfile(dropboxBaseDir,'TOME_analysis','modelSimulations','recoverSimulatedBiometry');

% Set the reCalcFlag
recalcFlag = false;

if recalcFlag
    % Constrain the bounds so that we do not search over depth
    model.eye.x0 = [14.104, 44.2410, 45.6302, 0, 2.5000, 0, 1, 1, 0];
    model.eye.bounds = [0, 5, 5, 180, 5, 2.5, 0.25, 0.25, 0];
    model.scene.bounds = [10 10 10 20 20 0];
    
    % Set up the eye params to vary in simulation
    valRange = model.eye.x0(1) - model.eye.bounds(1) : 0.01 : model.eye.x0(1) + model.eye.bounds(1);
    corneaAxialRadius = repmat(14.104,nBoots,1);
    valRange = model.eye.x0(3) - model.eye.bounds(3) : 0.01 : model.eye.x0(3) + model.eye.bounds(3);
    kvals = [randsample(valRange,nBoots,true); randsample(valRange,nBoots,true)]';
    needSwap = kvals(:,1)>kvals(:,2);
    kvals(needSwap,:) = fliplr(kvals(needSwap,:));
    valRange = 11:0.01:16;
    aziCenter = randsample(valRange,nBoots,true);
    eleCenter = randsample(valRange,nBoots,true);
    ele0 = 12; azi0 = 14.7;
    rotDiff = @(azi,ele) ((azi.*ele0)./(azi0.*ele)).^(1/2);
    rotJoint = @(azi,ele) (ele.*((azi.*ele0)./(azi0.*ele)).^(1/2))./ele0;
    rotationCenterScalers = [rotJoint(aziCenter,eleCenter); rotDiff(aziCenter,eleCenter)]';
    
    % Set up the scene params to vary in simulation
    valRange = -10:0.01:10;
    cameraTrans = [randsample(valRange,nBoots,true); randsample(valRange,nBoots,true); zeros(1,nBoots)];
    
    % Define a set of gaze targets at ±7°
    frameSet = 1:9;
    gazeTargets(1,:) = [-7 -7 -7 0 0 0 7 7 7];
    gazeTargets(2,:) = [-7 0 7 -7 0 7 -7 0 7];
    
    % How much noise are we adding to the glints and perimeters?
    perimNoise = 0.25;
    
    % Loop over simulations
    for bb = 1:nBoots
        
        bb
        
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
            'searchStrategy','simulateBio','savePlots',false,'saveFiles',false, ...
            'model',model,'glintData',gCell,'perimeter',pCell);
        kvalsRecovered(bb,:) = sceneObjects{1}.x(6:7);
        rotationCenterScalersRecovered(bb,:) = sceneObjects{1}.x(11:12);
        cameraTransRecovered(:,bb) = sceneObjects{1}.x(17:19)';
        meanGazeError(bb) = mean(vecnorm(sceneObjects{1}.modelPoseGaze-gazeTargets));
    end
    
    stateSaveName = tempname(outDir);
    save(stateSaveName)
else
    
    fileNames = {'tp5b16f1d4_52b6_4b39_999e_4093592aba0b.mat','tp6e876ca7_0af8_42bc_aaba_960e9f716fe0.mat','tpe931fa2a_feb4_4d62_ac5d_7b026f9af1da.mat','tpe3436800_610d_4166_8c3b_5ea5e65dbac0.mat'};
    cameraTrans = [];
    cameraTransRecovered = [];
    kvals = [];
    kvalsRecovered = [];
    rotationCenterScalersRecovered = [];
    aziCenter = [];
    eleCenter = [];
    meanGazeError = []
    for ii = 1:length(fileNames)
        stateSaveName = fullfile(outDir,fileNames{ii});
        dataLoad = load(stateSaveName);
        cameraTrans = [cameraTrans dataLoad.cameraTrans];
        cameraTransRecovered = [cameraTransRecovered dataLoad.cameraTransRecovered];
        kvals = [kvals; dataLoad.kvals];
        kvalsRecovered = [kvalsRecovered; dataLoad.kvalsRecovered];
        rotationCenterScalersRecovered = [rotationCenterScalersRecovered; dataLoad.rotationCenterScalersRecovered];
        aziCenter = [aziCenter dataLoad.aziCenter];
        eleCenter = [eleCenter dataLoad.eleCenter];
        meanGazeError = [meanGazeError dataLoad.meanGazeError];
    end
    
    nBoots = 1000;
    bb = 1000;
    
end

alphaVal = min([100/nBoots 1]);
markerSize = 10;

markerColor = [1 0.5 0.5];
pctSet = [5,95,50];
lineSpec = {'--k','--k','-k'};

median(meanGazeError)

subplot(4,3,1)
hold off
error = vecnorm((cameraTrans(1:2,1:nBoots)-cameraTransRecovered(1:2,1:nBoots)))';
medianError = nanmedian(error);
sim = [ cameraTrans(1,1:nBoots)'; cameraTrans(2,1:nBoots)' ];
rec = [ cameraTransRecovered(1,1:nBoots)'; cameraTransRecovered(2,1:nBoots)' ];
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = -10:1:10;
ctrs = {X -1:0.0001:1};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
xlim([-10 10])
ylim([-1 1])
xlabel('simulated in-plane trans [mm]');
ylabel('error [mm]');
axis square
str = sprintf('error [%2.2f]',medianError);
title(str)


subplot(4,3,2)
hold off
error = abs(kvals(1:nBoots,1) - kvalsRecovered(1:nBoots,1) );
medianError = nanmedian(error);
sim = kvals(1:nBoots,1);
rec = kvalsRecovered(1:nBoots,1);
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = 40:0.5:49;
ctrs = {X -2:0.001:2};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
axis equal
xlim([40 49])
ylim([-2 2])
xlabel('k1 [diopters]');
ylabel('error [diopters]');
axis square
str = sprintf('error [%2.2f]',medianError);
title(str)



subplot(4,3,3)
hold off
error = abs(kvals(1:nBoots,2) - kvalsRecovered(1:nBoots,2) );
medianError = nanmedian(error);
sim = kvals(1:nBoots,2);
rec = kvalsRecovered(1:nBoots,2);
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = 41:0.5:51;
ctrs = {X -2:0.001:2};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
axis equal
xlim([41 51])
ylim([-2 2])
xlabel('k2 [diopters]');
ylabel('error [diopters]');
axis square
str = sprintf('error [%2.2f]',medianError);
title(str)


% Grab the rotation depths
for ii = 1:nBoots
    eye.meta.rotationCenterScalers = rotationCenterScalersRecovered(ii,:);
    eye.meta.eyeLaterality = 'Right';
    eye.meta.primaryPosition = [0 0];
    rotationCenters = human.rotationCenters(eye);
    aziCenterRecovered(ii) = -rotationCenters.azi(1);
    eleCenterRecovered(ii) = -rotationCenters.ele(1);
end

subplot(4,3,4)
hold off
error = abs( aziCenter(1:nBoots) - aziCenterRecovered(1:nBoots) );
medianError = nanmedian(error);
sim = aziCenter(1:nBoots)';
rec = aziCenterRecovered(1:nBoots)';
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = 11:0.5:16;
ctrs = {X -1:0.0001:1};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
axis equal
xlim([11 16])
ylim([-1 1])
xlabel('azi center depth [mm]');
ylabel('error [mm]');
axis square
str = sprintf('error [%2.2f]',medianError);
title(str)


subplot(4,3,5)
hold off
error = abs( eleCenter(1:nBoots) - eleCenterRecovered(1:nBoots) );
medianError = nanmedian(error);
sim = eleCenter(1:nBoots)';
rec = eleCenterRecovered(1:nBoots)';
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = 11:0.5:16;
ctrs = {X -1:0.001:1};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
axis equal
xlim([11 16])
ylim([-1 1])
xlabel('ele center depth [mm]');
ylabel('error [mm]');
axis square
str = sprintf('error [%2.2f]',medianError);
title(str)


function [yValsFit, yVals] = countourLine(D,ctrs,percentile,polyOrder)

[N,c] = hist3(D,'ctrs',ctrs);
idx=sum(cumsum(N,2) < sum(N,2).*percentile/100,2)+2;
yVals = [nan c{2}];
yVals = yVals(idx);
xVals = c{1};
validX = sum(N,2)>0;
p=polyfit(xVals(validX),yVals(validX),polyOrder);
yValsFit = polyval(p,xVals);

end
