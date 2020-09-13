
clear
close all
sceneGeometry=createSceneGeometry('sphericalAmetropia',-5,'spectacleLens',-5);

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


% Define an eye pose
eyePose = [0 0 0 2];

rayHandles = gobjects(0);


%% Ray trace from stop to pupil
args = {sceneGeometry.cameraPosition.translation, ...
    sceneGeometry.eye.rotationCenters, ...
    sceneGeometry.refraction.stopToMedium.opticalSystem, ...
    sceneGeometry.refraction.mediumToCamera.opticalSystem};
stopPoint = [sceneGeometry.eye.stop.center(1),2,0];
[~, R] = findPupilRay( stopPoint, eyePose, args{:} );
[R, rayPath] = rayTraceQuadrics(R, sceneGeometry.refraction.stopToMedium.opticalSystem);
% Add this ray to the optical system plot
[~,tmpHandles]=plotOpticalSystem('newFigure',false,...
    'rayColor','green','outputRayColor','green',...
    'outputRay',R,'rayPath',rayPath);
rayHandles = [rayHandles,tmpHandles];
[R, rayPath] = rayTraceQuadrics(R, sceneGeometry.refraction.mediumToCamera.opticalSystem);
% Add this ray to the optical system plot
[~,tmpHandles]=plotOpticalSystem('newFigure',false,...
    'rayColor','green','outputRayColor','green',...
    'outputRay',R,'rayPath',rayPath,...
    'outputRayScale',sceneGeometry.cameraPosition.translation(3)-R(1,1));
rayHandles = [rayHandles,tmpHandles];


%% Ray trace from IR LED to camera for glint

% The position of the glint source in world coordinates
glintSourceWorld = sceneGeometry.cameraPosition.translation + ...
    sceneGeometry.cameraPosition.glintSourceRelative;

% Assemble the args for the glint ray trace
args = {sceneGeometry.cameraPosition.translation, ...
    sceneGeometry.eye.rotationCenters, ...
    sceneGeometry.refraction.cameraToMedium.opticalSystem, ...
    sceneGeometry.refraction.glint.opticalSystem, ...
    sceneGeometry.refraction.mediumToCamera.opticalSystem};

% Perform the computation using the passed function handle
[~, initialRay] = ...
    findGlintRay(glintSourceWorld, eyePose, args{:});

% Ray trace from the light source to the peri-eye medium
[R, rayPath] = rayTraceQuadrics(initialRay', sceneGeometry.refraction.cameraToMedium.opticalSystem);
[~,tmpHandles]=plotOpticalSystem('newFigure',false,...
    'rayColor','red','outputRayColor','red',...
    'outputRay',R,'rayPath',rayPath);
rayHandles = [rayHandles,tmpHandles];

% From the medium to the eye to the medium
[R, rayPath] = rayTraceQuadrics(R, sceneGeometry.refraction.glint.opticalSystem);
[~,tmpHandles]=plotOpticalSystem('newFigure',false,...
    'rayColor','red','outputRayColor','red',...
    'outputRay',R,'rayPath',rayPath);
rayHandles = [rayHandles,tmpHandles];

% From the medium to the camera
[R, rayPath] = rayTraceQuadrics(R, sceneGeometry.refraction.mediumToCamera.opticalSystem);
[~,tmpHandles]=plotOpticalSystem('newFigure',false,...
    'rayColor','red','outputRayColor','red',...
    'outputRay',R,'rayPath',rayPath,...
    'outputRayScale',sceneGeometry.cameraPosition.translation(3)-R(1,1));
rayHandles = [rayHandles,tmpHandles];


%% Add a camera
cameraHandles = addCameraIcon(sceneGeometry);

%% Add a 1 cm scale bar
scaleHandles = gobjects(0);
scaleHandles(end+1)=plot3([-30 -30],[-20 -20],[-20 -10],'-k');
scaleHandles(end+1)=plot3([-30 -30],[-20 -10],[-20 -20],'-k');
scaleHandles(end+1)=plot3([-30 -20],[-20 -20],[-20 -20],'-k');


viewNames = {'A','B','C'};
viewAngles = {[0,90],[0,0],[26,36]};
alignPoint = {[-30 30 40],[-30 30 40],[-30 -30 40]};
viewEle = [false,true,true];
viewAzi = [true,false,true];
xlim([-30 130]);
ylim([-30 30]);
zlim([-30 40]);
axis off

alignHandle = plot3(alignPoint{1}(1),alignPoint{1}(2),alignPoint{1}(3),'xm');

for vv = 1:length(viewNames)
    
    % Set the 3D view position
    view(viewAngles{vv}(1),viewAngles{vv}(2));
    
    % Display the alignPoint mark
    delete(alignHandle);
    alignHandle = plot3(alignPoint{vv}(1),alignPoint{vv}(2),alignPoint{vv}(3),'xm');    
    
    % Hide or show the ele and azi rotation components depending on the
    % view
    hidem(aziAxisHandlesVec)
    hidem(eleAxisHandlesVec)
    if viewEle(vv)
        showm(eleAxisHandlesBit);
    else
        hidem(eleAxisHandlesBit);
    end
    if viewAzi(vv)
        showm(aziAxisHandlesBit);
    else
        hidem(aziAxisHandlesBit);
    end
    
    % Save figure
    showm(eyeHandles);
    showm(cameraHandles);
    hidem(rayHandles);
    hidem(scaleHandles);
    set(figHandle,'color','none');
    fileName = ['~/Desktop/Figure1_view' viewNames{vv} '.png'];
    export_fig(figHandle,fileName,'-r1200','-opengl');
        
    % Hide or show the ele and azi rotation components depending on the
    % view
    hidem(aziAxisHandlesBit)
    hidem(eleAxisHandlesBit)
    if viewEle(vv)
        showm(eleAxisHandlesVec);
    else
        hidem(eleAxisHandlesVec);
    end
    
    if viewAzi(vv)
        showm(aziAxisHandlesVec);
    else
        hidem(aziAxisHandlesVec);
    end
    
    hidem(eyeHandles);
    hidem(cameraHandles);
    showm(rayHandles);
    showm(scaleHandles);
    set(figHandle,'color','white');
    fileName = ['~/Desktop/Figure1_view' viewNames{vv} '.pdf'];
    export_fig(figHandle,fileName,'-Painters');
    
end

close(figHandle)



function [h] = plotArc3D(from, to, center, count, color)

center = center(:); from = from(:); to = to(:);

% Start, stop and normal vectors
start = from - center; rstart = norm(start);
stop = to - center; rstop = norm(stop);
angle = atan2(norm(cross(start,stop)), dot(start,stop));
normal = cross(start, stop); normal = normal / norm(normal);

% Compute intermediate points by rotating 'start' vector
% toward 'end' vector around 'normal' axis
% See: http://inside.mines.edu/fs_home/gmurray/ArbitraryAxisRotation/
phiAngles = linspace(0, angle, count);
r = linspace(rstart, rstop, count) / rstart;
intermediates = zeros(3, count);
a = center(1); b = center(2); c = center(3);
u = normal(1); v = normal(2); w = normal(3);
x = from(1); y = from(2); z = from(3);
for ki = 1:count
    phi = phiAngles(ki);
    cosp = cos(phi); sinp = sin(phi);
    T = [(u^2+(v^2+w^2)*cosp)  (u*v*(1-cosp)-w*sinp)  (u*w*(1-cosp)+v*sinp) ((a*(v^2+w^2)-u*(b*v+c*w))*(1-cosp)+(b*w-c*v)*sinp); ...
        (u*v*(1-cosp)+w*sinp) (v^2+(u^2+w^2)*cosp)   (v*w*(1-cosp)-u*sinp) ((b*(u^2+w^2)-v*(a*u+c*w))*(1-cosp)+(c*u-a*w)*sinp); ...
        (u*w*(1-cosp)-v*sinp) (v*w*(1-cosp)+u*sinp)  (w^2+(u^2+v^2)*cosp)  ((c*(u^2+v^2)-w*(a*u+b*v))*(1-cosp)+(a*v-b*u)*sinp); ...
        0                    0                      0                                1                               ];
    intermediate = T * [x;y;z;r(ki)];
    intermediates(:,ki) = intermediate(1:3);
end

% Draw the curved line
% Can be improved of course with hggroup etc...
X = intermediates(1,:);
Y = intermediates(2,:);
Z = intermediates(3,:);
h = line(X,Y,Z,'Color',color);
end