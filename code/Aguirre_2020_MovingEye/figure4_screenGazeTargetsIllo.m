
clear
close all
sceneGeometry=createSceneGeometry('sphericalAmetropia',-5,'spectacleLens',-5);

% Move the screen closer
sceneGeometry.screenPosition.screenDistance = sceneGeometry.screenPosition.screenDistance/3;
sceneGeometry.screenPosition.dimensions = sceneGeometry.screenPosition.dimensions./3;


opticalSystem = sceneGeometry.refraction.retinaToCamera;

% Add the iris surface
opticalSystem = addIris(opticalSystem, 2.1, 'green');

% Remove the lens

% Strip the optical system of nan rows
opticalSystemMatrix = opticalSystem.opticalSystem;
numRows = size(opticalSystemMatrix,1);
opticalSystemMatrix = opticalSystemMatrix(sum(isnan(opticalSystemMatrix),2)~=size(opticalSystemMatrix,2),:);
notLens = ~contains(opticalSystem.surfaceLabels,'lens');
opticalSystemMatrix = opticalSystemMatrix(notLens,:);
opticalSystem.opticalSystem = opticalSystemMatrix;
opticalSystem.surfaceColors = opticalSystem.surfaceColors(notLens);
opticalSystem.surfaceLabels = opticalSystem.surfaceLabels(notLens);

[figHandle, eyeHandles] = plotOpticalSystem('surfaceSet',opticalSystem,'addLighting',true);

% Fill in the stop
C = [-3.9,0,0] ;   % center of circle
R = 2. ;    % Radius of circle
theta=0:0.01:2*pi ;
y=C(2)+R*cos(theta);
z=C(3)+R*sin(theta) ;
x=C(1)+zeros(size(z)) ;
eyeHandles(end+1)=patch(x,y,z,'k','FaceAlpha',0.5);


cameraHandles = addCameraIcon(sceneGeometry,[0 -15]);

gazeTargets = [
    7     0     0    -7     7    -7    -7     7     0
    0     0     7    -7    -7     7     0     7    -7];

screenHandles = addScreenIcon(sceneGeometry,[0 0], gazeTargets);


color = 'r';
%% Add a translation bar
arrowHandles = gobjects(0);
lineHandles = gobjects(0);

lineHandles(end+1)=plot3([125 125],[0 10],[25 25],'-', 'Color', color,'LineWidth',2);
arrowHandles(end+1)=mArrow3([125 0 25],[125 -2 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3([125 10 25],[125 12 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

lineHandles(end+1)=plot3([125 125],[5 5],[20 30],'-', 'Color', color,'LineWidth',2);
arrowHandles(end+1)=mArrow3([125 5 20],[125 5 18],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3([125 5 30],[125 5 32],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

rotate(arrowHandles,[0 1 0],-15,sceneGeometry.eye.rotationCenters.ele);
rotate(lineHandles,[0 1 0],-15,sceneGeometry.eye.rotationCenters.ele);

plot3(0,-100,60,'+m')

view(65,15)

xlim([-30 375]);
ylim([-125 125]);
zlim([-70 70 ]);

axis off
hidem(lineHandles)
set(figHandle,'color','none');
fileName = ['~/Desktop/Figure4_screenGazeTargetsIllo.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

showm(lineHandles)
hidem(arrowHandles)
hidem(cameraHandles)
hidem(eyeHandles)
hidem(screenHandles)
set(figHandle,'color','white');
fileName = ['~/Desktop/Figure4_screenGazeTargetsIllo.pdf'];
export_fig(figHandle,fileName,'-Painters');


