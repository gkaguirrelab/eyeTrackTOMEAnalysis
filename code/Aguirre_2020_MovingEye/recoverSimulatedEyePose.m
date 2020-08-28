% This routine runs simulations and plots the results, providing the raw
% figure panels for Figure 2 of Aguirre 2020, moving eye

clear

% Create a default sceneGeometry
sceneGeometry=createSceneGeometry();

% How much cameraTrans do we want to allow:
cameraTransBounds = [20; 20; 20];

% Define the set of pose values
aziSet = [-20:0.01:20];
eleSet = [-20:0.01:20];
stopSet = [0.5:0.01:4];
xSet = [-10:0.01:10];
ySet = [-10:0.01:10];

% How many sims?
nSims = 1000;

% Turn off warnings for an underconstrained eyePose search
warning('off','eyePoseEllipseFit:underconstrainedSearch')

caseLabels = {'TwoGlint','TwoGlintHalfPerim','OneGlint','OneGlintNoDepth'};

for cc = 1:4
    
    switch cc
        case 1
            sceneGeometry.cameraPosition.glintSourceRelative = [-14 14; 0 0; 0 0];
            zSet = [-10:0.01:10];
            perimCut = false;
        case 2
            sceneGeometry.cameraPosition.glintSourceRelative = [-14 14; 0 0; 0 0];
            zSet = [-10:0.01:10];
            perimCut = true;
        case 3
            sceneGeometry.cameraPosition.glintSourceRelative = [-14; 0; 0];
            zSet = [-10:0.01:10];
            perimCut = false;
        case 4
            sceneGeometry.cameraPosition.glintSourceRelative = [-14; 0; 0];
            zSet = [0 0];
            perimCut = false;
    end
    
    % Loop though simulations
    simSet = [];
    for ss = 1:nSims
        tag = '';
        eyePose(ss,:) = [randsample(aziSet,1) randsample(eleSet,1) 0 randsample(stopSet,1)];
        cameraTrans(:,ss) = [randsample(xSet,1); randsample(ySet,1); randsample(zSet,1)];
        [ targetEllipse, glintCoord ] = projectModelEye(eyePose(ss,:),sceneGeometry,'cameraTrans',cameraTrans(:,ss));
        [ Xp, Yp ] = ellipsePerimeterPoints( targetEllipse, 10 );
        
        % Remove the top-half of the points
        if perimCut
            topIdx = Yp>mean(Yp);
            Xp = Xp(~topIdx);
            Yp = Yp(~topIdx);
        end
        
        [eyePoseRecovered(ss,:), cameraTransRecovered(:,ss), RMSE] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds);
        if RMSE>1
            [eyePoseRecovered(ss,:), cameraTransRecovered(:,ss), RMSE] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds,'eyePoseX0',eyePoseRecovered(ss,:));
            if RMSE < 1
                fprintf('Bingo!\n')
                tag = 'Bingo!';
            else
                fprintf('Damnit.\n')
                eyePose(ss,:) = nan;
                cameraTrans(:,ss) = nan;
                eyePoseRecovered(ss,:) = nan;
                cameraTransRecovered(:,ss) = nan;
            end
        end
        
    end
    
    figHandle = makeFig(eyePose,eyePoseRecovered,cameraTrans,cameraTransRecovered);
    fileName = ['/Users/aguirre/Desktop/sim_' caseLabels{cc} '.pdf'];
    saveas(figHandle,fileName)
    
end

% Turn the warning back on
warning('off','eyePoseEllipseFit:underconstrainedSearch')



function figHandle = makeFig(eyePose,eyePoseRecovered,cameraTrans,cameraTransRecovered)


figHandle = figure();
subplot(2,3,1)
X = eyePose(:,1:2);
Y = eyePoseRecovered(:,1:2);
scatter(X(:,1),Y(:,1),100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
hold on
scatter(X(:,2),Y(:,2),100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
axis square
xlim([-20 20])
ylim([-20 20])
xlabel('simulated eye rotation [deg]');
ylabel('recovered eye rotation [deg]');

subplot(2,3,2)
X = eyePose(:,4);
Y = eyePoseRecovered(:,4);
scatter(X,Y,100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
axis square
xlim([0 4]);
ylim([0 4]);
xlabel('simulated stop radius [mm]');
ylabel('recovered stop radius [mm]');


subplot(2,3,3)
X = cameraTrans(1:2,:);
Y = cameraTransRecovered(1:2,:);
scatter(X(1,:),Y(1,:),100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
hold on
scatter(X(2,:),Y(2,:),100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
axis square
xlim([-10 10]);
ylim([-10 10]);
xlabel('simulated in-plane trans [mm]');
ylabel('recovered in-plane trans [mm]');


subplot(2,3,4)
X = cameraTrans(3,:);
Y = cameraTransRecovered(3,:);
scatter(X,Y,100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
axis square
xlim([-10 10]);
ylim([-10 10]);
xlabel('simulated depth trans [mm]');
ylabel('recovered depth trans [mm]');


subplot(2,3,5)
X = vecnorm(cameraTrans(1:2,:));
Y = vecnorm(((eyePose(:,1:2)-eyePoseRecovered(:,1:2)))')';
p = polyfit(X,Y,1);
scatter(X,Y,100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
hold on
plot(0:10,polyval(p,0:10),'-k','LineWidth',2)
xlim([0 15]);
ylim([0 10]);
axis square
xlabel('simulated in-plane trans [mm]');
ylabel('eye pose rotation error [deg]');


subplot(2,3,6)
X = abs(cameraTrans(3,:));
Y = vecnorm(((eyePose(:,1:2)-eyePoseRecovered(:,1:2)))')';
p = polyfit(X,Y,1);
scatter(X,Y,100,'MarkerFaceColor','r','MarkerEdgeColor','none',...
    'MarkerFaceAlpha',.1);
hold on
plot(0:10,polyval(p,0:10),'-k','LineWidth',2)
xlim([0 10]);
ylim([0 10]);
axis square
xlabel('simulated depth trans [mm]');
ylabel('eye pose rotation error [deg]');

end
