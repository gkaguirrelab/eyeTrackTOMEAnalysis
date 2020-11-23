figure
close all
clear

stlFileHead = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/_Papers/Aguirre_2020_movingEye/Figures/STL_files/human-head.stl';
fv = stlread(stlFileHead);



headObj = patch(fv,'FaceColor',       [210 161 140]./255, ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
headObj.FaceAlpha = 0.1;
direction = [0 0 1];
rotate(headObj,direction,90)


m = eye(4,4);
m(1,4) = -90;
m(2,4) = 32;
m(3,4) = -8;

t = hgtransform('Parent',gca);
set(headObj,'Parent',t)
set(t,'Matrix',m)




stlFileBrain = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/_Papers/Aguirre_2020_movingEye/Figures/STL_files/rh.pial.stl';
fv = stlread(stlFileBrain);

brainObj = patch(fv,'FaceColor',       [1.0 0.5 0.5], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.25);
brainObj.FaceAlpha = 0.1;
direction = [0 0 -1];
rotate(brainObj,direction,90)


m = eye(4,4);
m(1,4) = -25;
m(2,4) = 80;
m(3,4) = -8;

t = hgtransform('Parent',gca);
set(brainObj,'Parent',t)
set(t,'Matrix',m)



camlight
hold on
sceneGeometry = createSceneGeometry();
[~,p]=plotOpticalSystem('surfaceSet',sceneGeometry.refraction.retinaToCamera,'newFigure',false,'surfaceAlpha',0.75);


cameraHandles = addCameraIcon(sceneGeometry);


gazeTargets = [
    7     0     0    -7     7    -7    -7     7     0
    0     0     7    -7    -7     7     0     7    -7];
screenHandles = addScreenIcon(sceneGeometry,[0 -90],gazeTargets);
m = eye(4,4);
m(1,4) = -120;
m(2,4) = 32;
m(3,4) = -8;

t = hgtransform('Parent',gca);
set(screenHandles,'Parent',t)
set(t,'Matrix',m)


% Add the scanner bore
S = quadric.scale(quadric.unitSphere,[300 300 50000]);
S = quadric.translate(S,[-100 32 0]);
boundingBox = [-400 400 -400 400 -200 1000];
boreHandle = quadric.plotSurface(S, boundingBox, [0.5 0.5 1], 0.2);

