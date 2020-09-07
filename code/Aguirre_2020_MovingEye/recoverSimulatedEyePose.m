% This routine runs simulations and plots the results, providing the raw
% figure panels for Figure 2 of Aguirre 2020, moving eye

clear
close all

% Set the re-plot flag
replotFlag = true;

% Define the set of pose values
aziSet = -20:0.01:20;
eleSet = -20:0.01:20;
stopSet = 0.5:0.01:4;
xSet = -10:0.01:10;
ySet = -10:0.01:10;

% How many sims?
nSims = 1000;

% How much perimeter noise to add (sigma in units of pixels)?
perimNoise = 0.25;

% Set a rmseThresh
rmseThresh = max([1, perimNoise * 4]);

% Create a default sceneGeometry
sceneGeometry=createSceneGeometry();

% Explicitly define the search args
searchArgs = {'eyePoseEllipseFitFunEvals',250,'glintTol',1,'eyePoseTol',1e-3};

% Turn off warnings for an underconstrained eyePose search
warning('off','eyePoseEllipseFit:underconstrainedSearch')

caseLabels = {'TwoGlint','OneGlint','OneGlintNoDepth'};

figHandle = figure();

for cc = 1:3
    
    switch cc
        case 1
            sceneGeometry.cameraPosition.glintSourceRelative = [-14 14; 0 0; 0 0];
            zSet = -10:0.01:10;
            perimCut = false;
            cameraTransBounds = [20; 20; 20];
        case 2
            sceneGeometry.cameraPosition.glintSourceRelative = [-14; 0; 0];
            zSet = -10:0.01:10;
            perimCut = false;
            cameraTransBounds = [20; 20; 20];
        case 3
            sceneGeometry.cameraPosition.glintSourceRelative = [-14; 0; 0];
            zSet = [0 0];
            perimCut = false;
            cameraTransBounds = [20; 20; 0];
    end
    
    % This is where we will save the simulation state
    stateSaveName = sprintf('/Users/aguirre/Desktop/simStateSave_%d.mat',cc);
    
    % Do we want to re-do the simulations, or just load them from disk?
    if ~replotFlag
        
        % Loop though simulations
        simSet = [];
        for ss = 1:nSims
            eyePose(ss,:) = [randsample(aziSet,1) randsample(eleSet,1) 0 randsample(stopSet,1)];
            cameraTrans(:,ss) = [randsample(xSet,1); randsample(ySet,1); randsample(zSet,1)];
            [ targetEllipse, glintCoordOrig ] = projectModelEye(eyePose(ss,:),sceneGeometry,'cameraTrans',cameraTrans(:,ss));
            
            % Obtain the glintCoord and perimeter points of the ellipse, adding
            % noise
            glintCoord = glintCoordOrig + randn(size(glintCoordOrig)).*perimNoise;
            [ Xp, Yp ] = ellipsePerimeterPoints( targetEllipse, 10, 0, perimNoise );
            
            % Get the eye pose, and repeat if the error is above threshold
            [eyePoseRecovered(ss,:), cameraTransRecovered(:,ss), RMSE(ss)] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds,searchArgs{:});
            if RMSE(ss)>rmseThresh
                [eyePoseRecovered(ss,:), cameraTransRecovered(:,ss), RMSE(ss)] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds,'eyePoseX0',eyePoseRecovered(ss,:),searchArgs{:});
                if RMSE(ss) > rmseThresh
                    fprintf('Damnit.\n')
                    eyePose(ss,:) = nan;
                    cameraTrans(:,ss) = nan;
                    eyePoseRecovered(ss,:) = nan;
                    cameraTransRecovered(:,ss) = nan;
                end
            end
            
        end
        
        save(stateSaveName)
        
    else
        tmpFigHandle = figHandle;
        load(stateSaveName)
        close(figHandle);
        figHandle = tmpFigHandle;
    end
    
    % Add to the figure
    makeFig(eyePose,eyePoseRecovered,cameraTrans,cameraTransRecovered,RMSE,rmseThresh,cc);
end

% Save the figure
fileName = '/Users/aguirre/Desktop/simFig.pdf';
print(figHandle,fileName,'-dpdf')

% Turn the warning back on
warning('off','eyePoseEllipseFit:underconstrainedSearch')



function makeFig(eyePose,eyePoseRecovered,cameraTrans,cameraTransRecovered,RMSE,rmseThresh,cc)

alphaVal = min([50/size(eyePose,1) 1]);
markerSize = 10;

lowRMSE = RMSE < rmseThresh;

deltaDepth = abs(cameraTrans(3,lowRMSE))';
absRot = abs(eyePose(lowRMSE,1)) + abs(eyePose(lowRMSE,2));

markerColor = [1 0.5 0.5];
pctSet = [5,95,50];
lineSpec = {'--k','--k','-k'};


subplot(4,3,1+(cc-1))
hold off
error = vecnorm((eyePose(lowRMSE,1:2) - eyePoseRecovered(lowRMSE,1:2))')';
medianError = nanmedian(error);
errorByDepth = corr(deltaDepth,error);
errorByRot = corr(absRot,error);
sim = [ eyePose(lowRMSE,1); eyePose(lowRMSE,2) ];
rec = [ eyePoseRecovered(lowRMSE,1); eyePoseRecovered(lowRMSE,2) ];
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = -20:1:20;
ctrs = {X -5:0.001:5};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
xlim([-20 20])
ylim([-4 4])
xlabel('simulated eye rotation [deg]');
ylabel('error [deg]');
axis square
str = sprintf('error, Rd, Rr [%2.2f, %2.2f, %2.2f]',medianError,errorByDepth,errorByRot);
title(str)


subplot(4,3,4+(cc-1))
hold off
sim = eyePose(lowRMSE,4);
rec = eyePoseRecovered(lowRMSE,4);
error = abs(sim-rec);
medianError = nanmedian(error);
errorByDepth = corr(deltaDepth,error);
errorByRot = corr(absRot,error);
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = 0.5:0.25:4;
ctrs = {X -1:0.01:1};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
xlim([0 4]);
ylim([-0.5 0.5]);
xlabel('simulated stop radius [mm]');
ylabel('error [mm]');
axis square
str = sprintf('error, Rd, Rr [%2.2f, %2.2f, %2.2f]',medianError,errorByDepth,errorByRot);
title(str)


subplot(4,3,7+(cc-1))
hold off
error = vecnorm((cameraTrans(1:2,lowRMSE)-cameraTransRecovered(1:2,lowRMSE)))';
medianError = nanmedian(error);
errorByDepth = corr(deltaDepth,error);
errorByRot = corr(absRot,error);
sim = [ cameraTrans(1,lowRMSE)'; cameraTrans(2,lowRMSE)' ];
rec = [ cameraTransRecovered(1,lowRMSE)'; cameraTransRecovered(2,lowRMSE)' ];
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = -10:0.5:10;
ctrs = {X -5:0.001:5};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
xlim([-10 10])
ylim([-2 2])
xlabel('simulated in-plane trans [mm]');
ylabel('error [mm]');
axis square
str = sprintf('error, Rd, Rr [%2.2f, %2.2f, %2.2f]',medianError,errorByDepth,errorByRot);
title(str)


subplot(4,3,10+(cc-1))
hold off
error = abs(cameraTrans(3,lowRMSE)-cameraTransRecovered(3,lowRMSE))';
medianError = nanmedian(error);
errorByDepth = corr(deltaDepth,error);
errorByRot = corr(absRot,error);
sim = cameraTrans(3,lowRMSE)';
rec = cameraTransRecovered(3,lowRMSE)';
scatter(sim,sim-rec,markerSize,'MarkerFaceColor',markerColor,'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
D = [sim,sim-rec];
X = -10:0.5:10;
ctrs = {X -10:0.001:10};
for pp = 1:length(pctSet)
    yVals = countourLine(D,ctrs,pctSet(pp),4);
    plot(X,yVals,lineSpec{pp})
    hold on
end
axis equal
xlim([-10 10])
ylim([-10 10])
xlabel('simulated depth trans [mm]');
ylabel('error [mm]');
axis square
str = sprintf('error, Rd, Rr [%2.2f, %2.2f, %2.2f]',medianError,errorByDepth,errorByRot);
title(str)


end


function [yValsFit, yVals] = countourLine(D,ctrs,percentile,polyOrder)

[N,c] = hist3(D,'ctrs',ctrs);
idx=sum(cumsum(N,2) < sum(N,2).*percentile/100,2)+2;
yVals = [nan c{2}];
yVals = yVals(idx);
p=polyfit(c{1},yVals,polyOrder);
yValsFit = polyval(p,c{1});

end
