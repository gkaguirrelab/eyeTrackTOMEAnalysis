

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


%% Illustration of the rotation centers


[figHandle, eyeHandles] = plotOpticalSystem('surfaceSet',opticalSystem,'addLighting',true,'surfaceAlpha',0.2);

% Add axes to indicate the centers of rotation
swivelRadius = 3;
cdr = 0.5;

%% AZI
aziAxisHandlesBit = gobjects(0);
aziAxisHandlesVec = gobjects(0);
azi = sceneGeometry.eye.rotationCenters.azi;
aziAxisHandlesVec(end+1)=plot3([azi(1) azi(1)],[azi(2) azi(2)],[azi(3)-20 azi(3)+20],'-k');
S = quadric.scale(quadric.unitSphere,[cdr cdr cdr]);
S = quadric.translate(S,azi);
boundingBox = [azi(1)-cdr azi(1)+cdr azi(2)-cdr azi(2)+cdr azi(3)-cdr azi(3)+cdr];
aziAxisHandlesBit(end+1) = quadric.plotSurface(S, boundingBox, [0 0 0], 1);
pointC = [azi(1), azi(2), azi(3)+20];
pointA = [azi(1)-swivelRadius, azi(2), azi(3)+20];
pointB = [azi(1), azi(2)-swivelRadius, azi(3)+20];
aziAxisHandlesVec(end+1) = plotArc3D(pointA, pointB, pointC, 50,'k');
pointB = [azi(1), azi(2)+swivelRadius, azi(3)+20];
aziAxisHandlesVec(end+1) = plotArc3D(pointA, pointB, pointC, 50,'k');
pointA = [azi(1)+swivelRadius, azi(2), azi(3)+20];
aziAxisHandlesVec(end+1) = plotArc3D(pointB, pointA, pointC, 50,'k');
pointB = [azi(1)+swivelRadius, azi(2)-2, azi(3)+20];
aziAxisHandlesBit(end+1) = mArrow3(pointA,pointB,'stemWidth',0.1,'tipWidth',0.5,'color',[0 0 0],'FaceAlpha',0.5);

%% ELE
eleAxisHandlesBit = gobjects(0);
eleAxisHandlesVec = gobjects(0);

ele = sceneGeometry.eye.rotationCenters.ele;
eleAxisHandlesVec(end+1) = plot3([ele(1) ele(1)],[ele(2)-20 ele(2)+20],[ele(3) ele(3)],'-b');
S = quadric.scale(quadric.unitSphere,[cdr cdr cdr]);
S = quadric.translate(S,ele);
boundingBox = [ele(1)-cdr ele(1)+cdr ele(2)-cdr ele(2)+cdr ele(3)-cdr ele(3)+cdr];
eleAxisHandlesBit(end+1) = quadric.plotSurface(S, boundingBox, [0 0 1], 1);pointC = [ele(1), ele(2)+20, ele(3)];
pointB = [ele(1)-swivelRadius, ele(2)+20, ele(3)];
pointA = [ele(1), ele(2)+20, ele(3)+swivelRadius];
eleAxisHandlesVec(end+1) = plotArc3D(pointA, pointB, pointC, 50, 'b');
pointB = [ele(1)+swivelRadius, ele(2)+20, ele(3)];
eleAxisHandlesVec(end+1) = plotArc3D(pointA, pointB, pointC, 50, 'b');
pointA = [ele(1), ele(2)+20, ele(3)-swivelRadius];
eleAxisHandlesVec(end+1) = plotArc3D(pointB, pointA, pointC, 50, 'b');
pointB = [ele(1)-2, ele(2)+20, ele(3)-swivelRadius];
eleAxisHandlesBit(end+1) = mArrow3(pointA,pointB,'stemWidth',0.1,'tipWidth',0.5,'color',[0 0 1],'FaceAlpha',0.5);

view(53,31);
plot3(-25,-20,40,'xm')
xlim([-25 0]);
ylim([-20 30]);
zlim([-20 40]);
axis off


hidem(eleAxisHandlesVec);
hidem(aziAxisHandlesVec);
set(figHandle,'color','none');
fileName = ['~/Desktop/Figure1_rotCenterParams_model.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

showm(eleAxisHandlesVec);
showm(aziAxisHandlesVec);
hidem(eleAxisHandlesBit);
hidem(aziAxisHandlesBit);
hidem(eyeHandles);

set(figHandle,'color','white');
fileName = ['~/Desktop/Figure1_rotCenterParams_model.pdf'];
export_fig(figHandle,fileName,'-Painters');
close(figHandle)








[figHandle, eyeHandles] = plotOpticalSystem('surfaceSet',opticalSystem,'addLighting',true,'surfaceAlpha',0.1);
delete(eyeHandles);

% Add axes to indicate the centers of rotation
for scale = [0.75,1,1.25]
azi = sceneGeometry.eye.rotationCenters.azi.*scale;
plot3([azi(1) azi(1)],[azi(2) azi(2)],[azi(3)-20 azi(3)+20],':k','LineWidth',1);
hold on

end

% Add an arrow to indicate this variable 
plot3([-18 -10],[1 1],[25 25],'-r','LineWidth',2)

view(53,31);
plot3(-25,-20,40,'xm')
xlim([-25 0]);
ylim([-20 30]);
zlim([-20 40]);
axis off

set(figHandle,'color','white');
fileName = ['~/Desktop/Figure1_rotCenterParams_azi.pdf'];
export_fig(figHandle,fileName,'-Painters');
close(figHandle)


[figHandle, eyeHandles] = plotOpticalSystem('surfaceSet',opticalSystem,'addLighting',true,'surfaceAlpha',0.1);

% Fill in the stop
C = [-3.9,0,0] ;   % center of circle
R = 2. ;    % Radius of circle
theta=0:0.01:2*pi ;
y=C(2)+R*cos(theta);
z=C(3)+R*sin(theta) ;
x=C(1)+zeros(size(z)) ;
eyeHandles(end+1)=patch(x,y,z,'k','FaceAlpha',0.25);


% Add axes to indicate the centers of rotation
cdr = 0.5;
for scale = [0.75,1,1.25]
azi = sceneGeometry.eye.rotationCenters.azi.*scale;
S = quadric.scale(quadric.unitSphere,[cdr cdr cdr]);
S = quadric.translate(S,azi);
boundingBox = [azi(1)-cdr azi(1)+cdr azi(2)-cdr azi(2)+cdr azi(3)-cdr azi(3)+cdr];
quadric.plotSurface(S, boundingBox, [0 0 0], 0.25);
p = plot3([azi(1) azi(1)],[azi(2) azi(2)],[azi(3)-20 azi(3)+20],':k','LineWidth',1);
delete(p)

end


% Add an arrow to indicate this variable 
mArrow3([-18 1 25],[-20 1 25],'stemWidth',0.1,'tipWidth',0.5,'color','r','FaceAlpha',0.5);
mArrow3([-10 1 25],[-8 1 25],'stemWidth',0.1,'tipWidth',0.5,'color','r','FaceAlpha',0.5);

view(53,31);
plot3(-25,-20,40,'xm')
xlim([-25 0]);
ylim([-20 30]);
zlim([-20 40]);
axis off

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure1_rotCenterParams_azi.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');
close(figHandle)



%% ELE


[figHandle, eyeHandles] = plotOpticalSystem('surfaceSet',opticalSystem,'addLighting',true,'surfaceAlpha',0.1);
delete(eyeHandles);

% Add axes to indicate the centers of rotation
for scale = [0.75,1,1.25]

hold on

ele = sceneGeometry.eye.rotationCenters.ele.*scale;
plot3([ele(1) ele(1)],[ele(2)-20 ele(2)+20],[ele(3) ele(3)],':b','LineWidth',1);
end


% Add an arrow to indicate this variable 
plot3([-18 -10],[25 25],[0 0],'-r','LineWidth',2)

view(53,31);
plot3(-25,-20,40,'xm')
xlim([-25 0]);
ylim([-20 30]);
zlim([-20 40]);
axis off

set(figHandle,'color','white');
fileName = ['~/Desktop/Figure1_rotCenterParams_ele.pdf'];
export_fig(figHandle,fileName,'-Painters');
close(figHandle)


[figHandle, eyeHandles] = plotOpticalSystem('surfaceSet',opticalSystem,'addLighting',true,'surfaceAlpha',0.1);

% Fill in the stop
C = [-3.9,0,0] ;   % center of circle
R = 2. ;    % Radius of circle
theta=0:0.01:2*pi ;
y=C(2)+R*cos(theta);
z=C(3)+R*sin(theta) ;
x=C(1)+zeros(size(z)) ;
eyeHandles(end+1)=patch(x,y,z,'k','FaceAlpha',0.25);


% Add axes to indicate the centers of rotation
cdr = 0.5;
for scale = [0.75,1,1.25]

ele = sceneGeometry.eye.rotationCenters.ele.*scale;
S = quadric.scale(quadric.unitSphere,[cdr cdr cdr]);
S = quadric.translate(S,ele);
boundingBox = [ele(1)-cdr ele(1)+cdr ele(2)-cdr ele(2)+cdr ele(3)-cdr ele(3)+cdr];
quadric.plotSurface(S, boundingBox, [0 0 1], 0.25);pointC = [ele(1), ele(2)+20, ele(3)];
p = plot3([ele(1) ele(1)],[ele(2)-20 ele(2)+20],[ele(3) ele(3)],':b','LineWidth',1);
delete(p)
end


% Add an arrow to indicate this variable 
mArrow3([-18 25 0],[-20 25 0],'stemWidth',0.1,'tipWidth',0.5,'color','r','FaceAlpha',0.5);
mArrow3([-10 25 0],[-8 25 0],'stemWidth',0.1,'tipWidth',0.5,'color','r','FaceAlpha',0.5);

view(53,31);
plot3(-25,-20,40,'xm')
xlim([-25 0]);
ylim([-20 30]);
zlim([-20 40]);
axis off

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure1_rotCenterParams_ele.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');
close(figHandle)


