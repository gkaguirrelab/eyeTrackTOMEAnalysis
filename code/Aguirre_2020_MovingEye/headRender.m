figure
close all
clear

stlFileHead = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/_Papers/Aguirre_2020_movingEye/Figures/STL_files/human-head.stl';
fv = stlread(stlFileHead);



headObj = patch(fv,'FaceColor',       [0.8 0.8 1.0], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
headObj.FaceAlpha = 0.1;
direction = [0 0 1];
rotate(headObj,direction,90)

stlFileBrain = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/_Papers/Aguirre_2020_movingEye/Figures/STL_files/rh.pial.stl';
fv = stlread(stlFileBrain);

brainObj = patch(fv,'FaceColor',       [1.0 0.8 0.8], ...
         'EdgeColor',       'none',        ...
         'FaceLighting',    'gouraud',     ...
         'AmbientStrength', 0.15);
brainObj.FaceAlpha = 0.25;
direction = [0 0 -1];
rotate(brainObj,direction,90)


m = eye(4,4);
m(1,4) = -10;
m(2,4) = 20;
m(3,4) = 0;

t = hgtransform('Parent',gca);
set(brainObj,'Parent',t)
set(t,'Matrix',m)



camlight
hold on
sceneGeometry = createSceneGeometry();
[~,p]=plotOpticalSystem('surfaceSet',sceneGeometry.refraction.retinaToCamera,'newFigure',false,'surfaceAlpha',0.75);

m = eye(4,4);
m(1,4) = 90;
m(2,4) = -32;
m(3,4) = 8;

t = hgtransform('Parent',gca);
set(p,'Parent',t)
set(t,'Matrix',m)

ylim([-100 0]);
