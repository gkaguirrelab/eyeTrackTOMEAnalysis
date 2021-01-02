% Creates a 3D plot of the scanner bore, head, eye, and screen

%% Housekeeping
close all
clear
figHandle = figure ();


%% Head
% Source:
%   Human Head (NURBS) by grozny
%   Creative Commons - Attribution - Share Alikelicense.
%   https://www.thingiverse.com/thing:172348

% File name
stlFileHead = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/_Papers/Aguirre_2020_movingEye/Figures/STL_files/human-head.stl';

% Load the faces and vertices. Using a shadowed versoin of stlread. I had
% to make a local copy and modify it to get this to load properly
fv = stlread(stlFileHead);

% Plot the object, and set the rotation and transparency
headObj = patch(fv,'FaceColor',       [210 161 140]./255, ...
    'EdgeColor',       'none',        ...
    'FaceLighting',    'gouraud',     ...
    'AmbientStrength', 0.15);
headObj.FaceAlpha = 0.1;
direction = [0 0 1];
rotate(headObj,direction,90)

% Translate the the head so that the front surface of the right eye is at
% coordinate [0 0 0]
m = eye(4,4);
m(1,4) = -90;
m(2,4) = 32;
m(3,4) = -8;

t = hgtransform('Parent',gca);
set(headObj,'Parent',t)
set(t,'Matrix',m)


%% Brain
% Source:
%   Human Brain, Full Scale by MiloMiis
%   Creative Commons - Attribution - Share Alikelicense.
%   https://www.thingiverse.com/thing:371899

% File name
stlFileBrain = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/_Papers/Aguirre_2020_movingEye/Figures/STL_files/rh.pial.stl';

% Load the faces and vertices
fv = stlread(stlFileBrain);

% Plot the object, and set the rotation and transparency
brainRightObj = patch(fv,'FaceColor',       [1.0 0.85 0.85], ...
    'EdgeColor',       'none',        ...
    'EdgeAlpha',       0,        ...
    'SpecularStrength',   0.5, ...
    'FaceLighting',    'gouraud',     ...
    'FaceAlpha',    0.1,     ...
    'AmbientStrength', 0.55);
direction = [0 0 -1];
rotate(brainRightObj,direction,90)

% Translate the brain to be in the proper position in the head
m = makehgtform('translate',[-25 80 -8],'zrotate',deg2rad(-2));
t = hgtransform('Parent',gca);
set(brainRightObj,'Parent',t)
set(t,'Matrix',m)


% Make a copy of the brain, mirror reverse it, trnaslate
brainLeftObj = copyobj(brainRightObj,gca);
set(brainLeftObj, 'YData', -1*get(brainLeftObj,'YData'));
m = makehgtform('translate',[-25 -15 -8]);
t = hgtransform('Parent',gca);
set(brainLeftObj,'Parent',t)
set(t,'Matrix',m)


% Set the lighting
camlight
hold on


%% Eye
% Create the default sceneGeometry
sceneGeometry = createSceneGeometry();

% Plot the optical system
[~,eyeHandles]=plotOpticalSystem('surfaceSet',sceneGeometry.refraction.retinaToCamera,'newFigure',false,'surfaceAlpha',0.75);


%% Camera
cameraHandles = addCameraIcon(sceneGeometry);


%% Screen
% define some gaze targets and plot the screen
%{
gazeTargets = [
    7     0     0    -7     7    -7    -7     7     0
    0     0     7    -7    -7     7     0     7    -7];
screenHandles = addScreenIcon(sceneGeometry,[0 -90],gazeTargets);

% Need to move the screen around as it is being viewed through a mirror
m = eye(4,4);
m(1,4) = 0;
m(2,4) = 32;
m(3,4) = -8;

t = hgtransform('Parent',gca);
set(screenHandles,'Parent',t)
set(t,'Matrix',m)
%}


%% Mirror
% There is a cold mirror positioned at a 45° angle above the head

X = [120 120 80 80];
Y = [40 -40 -40 40];
Z = [-20 -20 20 20];

mirrorHandle = patch(X,Y,Z,[0.5 0.5 0.5]);
mirrorHandle.FaceAlpha = 0.25;


%% Eye translation arrows
arrowHandles = gobjects(0);
lineHandles = gobjects(0);
color = 'r';

c = [0 0 0];
l = 20;
a = 20;
sw = 0.5;
tw = 2.5;

lineHandles(end+1)=plot3([c(1)-l c(1)+l],[c(2) c(2)],[c(3) c(3)],'-', 'Color', color,'LineWidth',sw);
arrowHandles(end+1)=mArrow3(c-[l 0 0],c-[l+a 0 0],'stemWidth',sw,'tipWidth',tw,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3(c+[l 0 0],c+[l+a 0 0],'stemWidth',sw,'tipWidth',tw,'color',color,'FaceAlpha',0.5);

lineHandles(end+1)=plot3([c(1) c(1)],[c(2)-l c(2)+l],[c(3) c(3)],'-', 'Color', color,'LineWidth',sw);
arrowHandles(end+1)=mArrow3(c-[0 l 0],c-[0 l+a 0],'stemWidth',sw,'tipWidth',tw,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3(c+[0 l 0],c+[0 l+a 0],'stemWidth',sw,'tipWidth',tw,'color',color,'FaceAlpha',0.5);

lineHandles(end+1)=plot3([c(1) c(1)],[c(2) c(2)],[c(3)-l c(3)+l],'-', 'Color', color,'LineWidth',sw);
arrowHandles(end+1)=mArrow3(c-[0 0 l],c-[0 0 l+a],'stemWidth',sw,'tipWidth',tw,'color',color,'FaceAlpha',0.5);
arrowHandles(end+1)=mArrow3(c+[0 0 l],c+[0 0 l+a],'stemWidth',sw,'tipWidth',tw,'color',color,'FaceAlpha',0.5);


%% Scanner Bore
%{
S = quadric.scale(quadric.unitSphere,[300 300 50000]);
S = quadric.translate(S,[-100 32 0]);
boundingBox = [-400 400 -400 400 -200 1000];
boreHandle = quadric.plotSurface(S, boundingBox, [0.5 0.5 1], 0.2);
%}


%% Align mark
%alignHandle = plot3(-400,100,220,'xm');


%% Clean up
view(56,16);
xlim([-306.6659  130.0000]);
ylim([ -128.0000  238.6659]);
zlim([-166.6659  200.0000]);
box off
axis off


%% Save figure

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure7_scannerIlloEyeMoves.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

%% Close the figure
close(figHandle);