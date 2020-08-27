

% Create a default sceneGeometry
sceneGeometry=createSceneGeometry();

% How much cameraTrans do we want to allow:
cameraTransBounds = [20; 20; 20];

% Define the set of pose values
aziSet = [-20:1:20];
eleSet = [-20:1:20];
stopSet = [0.5:0.25:4];
xSet = [-10:1:10];
ySet = [-10:1:10];
zSet = [-10:1:10];

% Let's do the 2 light source case first
sceneGeometry.cameraPosition.glintSourceRelative = [-14 14; 0 0; 0 0];

% Loop though simulations
nSims = 5;
simSet = [];
for ss = 1:nSims
    tag = '';
    eyePose = [randsample(aziSet,1) randsample(eleSet,1) 0 randsample(stopSet,1)];
    cameraTrans = [randsample(xSet,1); randsample(ySet,1); randsample(zSet,1)];
    [ targetEllipse, glintCoord ] = projectModelEye(eyePose,sceneGeometry,'cameraTrans',cameraTrans);
    [ Xp, Yp ] = ellipsePerimeterPoints( targetEllipse, 10 );
    [eyePoseRecovered, cameraTransRecovered, RMSE] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds);
    if RMSE>1
        [eyePoseRecovered, cameraTransRecovered, RMSE] = eyePoseEllipseFit(Xp, Yp, glintCoord, sceneGeometry,'cameraTransBounds',cameraTransBounds,'eyePoseX0',eyePoseRecovered);
        if RMSE < 1
            fprintf('Bingo!\n')
            tag = 'Bingo!';
        else
            fprintf('Damnit.\n')
        end
    end
    simSet(ss).eyePose = eyePose;
    simSet(ss).eyePoseRecovered = eyePoseRecovered;
    simSet(ss).cameraTrans = cameraTrans';
    simSet(ss).cameraTransRecovered = cameraTransRecovered';
    simSet(ss).RMSE = RMSE;
    simSet(ss).tag = tag;
end
