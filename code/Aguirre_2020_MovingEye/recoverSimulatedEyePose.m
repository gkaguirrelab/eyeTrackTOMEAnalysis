% This routine runs simulations and plots the results, providing the raw
% figure panels for Figure 2 of Aguirre 2020, moving eye

clear

% Create a default sceneGeometry
sceneGeometry=createSceneGeometry();

% Define the set of pose values
aziSet = -20:0.01:20;
eleSet = -20:0.01:20;
stopSet = 0.5:0.01:4;
xSet = -10:0.01:10;
ySet = -10:0.01:10;

% How many sims?
nSims = 10;

% How much perimeter noise to add (sigma in units of pixels)?
perimNoise = 1;

% Explicitly define the search args
searchArgs = {'eyePoseEllipseFitFunEvals',250,'glintTol',1,'eyePoseTol',1e-3};

% Turn off warnings for an underconstrained eyePose search
warning('off','eyePoseEllipseFit:underconstrainedSearch')

caseLabels = {'TwoGlint','TwoGlintHalfPerim','OneGlint','OneGlintNoDepth'};

for cc = 1:4
    
    switch cc
        case 1
            sceneGeometry.cameraPosition.glintSourceRelative = [-14 14; 0 0; 0 0];
            zSet = -10:0.01:10;
            perimCut = false;
            cameraTransBounds = [20; 20; 20];
        case 2
            sceneGeometry.cameraPosition.glintSourceRelative = [-14 14; 0 0; 0 0];
            zSet = -10:0.01:10;
            perimCut = true;
            cameraTransBounds = [20; 20; 20];
        case 3
            sceneGeometry.cameraPosition.glintSourceRelative = [-14; 0; 0];
            zSet = -10:0.01:10;
            perimCut = false;
            cameraTransBounds = [20; 20; 20];
        case 4
            sceneGeometry.cameraPosition.glintSourceRelative = [-14; 0; 0];
            zSet = [0 0];
            perimCut = false;
            cameraTransBounds = [20; 20; 0];
    end
    
    % Loop though simulations
    simSet = [];
    for ss = 1:nSims
        tag = '';
        eyePose(ss,:) = [randsample(aziSet,1) randsample(eleSet,1) 0 randsample(stopSet,1)];
        cameraTrans(:,ss) = [randsample(xSet,1); randsample(ySet,1); randsample(zSet,1)];
        [ targetEllipse, glintCoord ] = projectModelEye(eyePose(ss,:),sceneGeometry,'cameraTrans',cameraTrans(:,ss));
        
        % Remove the top-half of the points
        if perimCut
            [ Xp, Yp ] = ellipsePerimeterPoints( targetEllipse, 20, 0, perimNoise );
            topIdx = Yp>mean(Yp);
            Xp = Xp(~topIdx);
            Yp = Yp(~topIdx);
        else
            [ Xp, Yp ] = ellipsePerimeterPoints( targetEllipse, 10, 0, perimNoise );
        end

        % Get the eye pose, and repeat if the error is above threshold
        [eyePoseRecovered(ss,:), cameraTransRecovered(:,ss), RMSE(ss)] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds,searchArgs{:});
%         if RMSE(ss)>0.1
%             [eyePoseRecovered(ss,:), cameraTransRecovered(:,ss), RMSE(ss)] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds,'eyePoseX0',eyePoseRecovered(ss,:),searchArgs{:});
%             if RMSE(ss) > 0.1
%                 fprintf('Damnit.\n')
%                 eyePose(ss,:) = nan;
%                 cameraTrans(:,ss) = nan;
%                 eyePoseRecovered(ss,:) = nan;
%                 cameraTransRecovered(:,ss) = nan;
%             end
%         end
        
    end
    
    alphaVal = min([20/nSims 1]);
    figHandle = makeFig(eyePose,eyePoseRecovered,cameraTrans,cameraTransRecovered,alphaVal);
    fileName = ['/Users/aguirre/Desktop/sim_' caseLabels{cc} '.pdf'];
    saveas(figHandle,fileName)
    
end

% Turn the warning back on
warning('off','eyePoseEllipseFit:underconstrainedSearch')



function figHandle = makeFig(eyePose,eyePoseRecovered,cameraTrans,cameraTransRecovered,alphaVal)


figHandle = figure();
subplot(2,3,1)
X = eyePose(:,1:2);
Y = eyePoseRecovered(:,1:2);
medianError = nanmedian(vecnorm((X-Y)'));
scatter(X(:,1),Y(:,1),50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
scatter(X(:,2),Y(:,2),50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
axis square
xlim([-20 20])
ylim([-20 20])
xlabel('simulated eye rotation [deg]');
ylabel('recovered eye rotation [deg]');
str = sprintf('median absolute error = %2.2f',medianError);
title(str)

subplot(2,3,2)
X = eyePose(:,4);
Y = eyePoseRecovered(:,4);
medianError = nanmedian(abs(X-Y));
scatter(X,Y,50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
axis square
xlim([0 4]);
ylim([0 4]);
xlabel('simulated stop radius [mm]');
ylabel('recovered stop radius [mm]');
str = sprintf('median absolute error = %2.2f',medianError);
title(str)


subplot(2,3,3)
X = cameraTrans(1:2,:);
Y = cameraTransRecovered(1:2,:);
medianError = nanmedian(vecnorm((X-Y)));
scatter(X(1,:),Y(1,:),50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
scatter(X(2,:),Y(2,:),50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
axis square
xlim([-10 10]);
ylim([-10 10]);
xlabel('simulated in-plane trans [mm]');
ylabel('recovered in-plane trans [mm]');
str = sprintf('median absolute error = %2.2f',medianError);
title(str)


subplot(2,3,4)
X = cameraTrans(3,:);
Y = cameraTransRecovered(3,:);
medianError = nanmedian(abs(X-Y));
scatter(X,Y,50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
axis square
xlim([-10 10]);
ylim([-10 10]);
xlabel('simulated depth trans [mm]');
ylabel('recovered depth trans [mm]');
str = sprintf('median absolute error = %2.2f',medianError);
title(str)


subplot(2,3,5)
X = vecnorm(cameraTrans(1:2,:));
Y = vecnorm(((eyePose(:,1:2)-eyePoseRecovered(:,1:2)))')';
nanIdx = isnan(X);
p = polyfit(X(~nanIdx),Y(~nanIdx),1);
scatter(X,Y,50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
plot(0:15,polyval(p,0:15),'-k','LineWidth',2)
xlim([0 15]);
ylim([0 5]);
axis square
xlabel('simulated in-plane trans [mm]');
ylabel('eye pose rotation error [deg]');
str = sprintf('max error = %2.2f, #nan = %d',max(Y),sum(nanIdx));
title(str)

subplot(2,3,6)
X = abs(cameraTrans(3,:));
Y = vecnorm(((eyePose(:,1:2)-eyePoseRecovered(:,1:2)))')';
nanIdx = isnan(X);
p = polyfit(X(~nanIdx),Y(~nanIdx),1);
scatter(X,Y,50,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',alphaVal);
hold on
plot(0:10,polyval(p,0:10),'-k','LineWidth',2)
xlim([0 10]);
ylim([0 5]);
axis square
xlabel('simulated depth trans [mm]');
ylabel('eye pose rotation error [deg]');
str = sprintf('max error = %2.2f',max(Y));
title(str)


end
