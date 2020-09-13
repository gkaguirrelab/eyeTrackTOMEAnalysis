
clear
close all
sceneGeometry=createSceneGeometry('sphericalAmetropia',-5,'spectacleLens',-5);

opticalSystem = sceneGeometry.refraction.retinaToMedium;

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

[figHandle, eyeHandles] = plotOpticalSystem('surfaceSet',opticalSystem,'addLighting',true,'surfaceAlpha',0.1);

% Fill in the stop
C = [-3.9,0,0] ;   % center of circle
R = 2. ;    % Radius of circle
theta=0:0.01:2*pi ;
y=C(2)+R*cos(theta);
z=C(3)+R*sin(theta) ;
x=C(1)+zeros(size(z)) ;
eyeHandles(end+1)=patch(x,y,z,'k','FaceAlpha',0.5);


%% Add a camera
cameraHandles = addCameraIcon(sceneGeometry);
for ii = 1:length(cameraHandles)
    cameraHandles(ii).FaceAlpha = cameraHandles(ii).FaceAlpha .* 0.75;
    cameraHandles(ii).EdgeAlpha = 0.5
end

arrowHandles = gobjects(0);
lineHandles = gobjects(0);
color = 'r';
%% Add a translation bar
lineHandles(end+1)=plot3([120 130],[5 5],[25 25],'-', 'Color', color,'LineWidth',2);
arrowHandles(end+1)=mArrow3([120 5 25],[118 5 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3([130 5 25],[132 5 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

lineHandles(end+1)=plot3([125 125],[0 10],[25 25],'-', 'Color', color,'LineWidth',2);
arrowHandles(end+1)=mArrow3([125 0 25],[125 -2 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3([125 10 25],[125 12 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

lineHandles(end+1)=plot3([125 125],[5 5],[20 30],'-', 'Color', color,'LineWidth',2);
arrowHandles(end+1)=mArrow3([125 5 20],[125 5 18],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3([125 5 30],[125 5 32],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);


% Add axes to indicate the centers of rotation
swivelRadius = 8;
axisSet = {[3 2 1]};
cSet = {[125 5 25]};
p1Set = {[-swivelRadius 0 0],[0 swivelRadius 0],[swivelRadius 0 0],[-swivelRadius 0 0]};
p2Set = {[0 swivelRadius 0],[swivelRadius 0 0],[0 -swivelRadius 0],[-swivelRadius -2 0]};
for cc = 1:1
    for aa = 1:4
        p1 = cSet{cc}+p1Set{aa}(axisSet{cc});
        p2 = cSet{cc}+p2Set{aa}(axisSet{cc});
        if aa == 4
            arrowHandles(end+1)=mArrow3(p1,p2,'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
        else
            lineHandles(end+1) = plotArc3D(p1, p2, cSet{cc}, 20,color);
            lineHandles(end).LineWidth = 2;
        end
    end
end

view(82,5);
axis off

plot3(120,-35,40,'xm')

xlim([-30 130]);
ylim([-35 30]);
zlim([-20 40]);

hidem(lineHandles);

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure1_parametersCameraTrans.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

showm(lineHandles)
hidem(arrowHandles)
hidem(eyeHandles)
hidem(cameraHandles)
set(figHandle,'color','white');
fileName = ['~/Desktop/Figure1_parametersCameraTrans.pdf'];
export_fig(figHandle,fileName,'-Painters');
close(figHandle)

