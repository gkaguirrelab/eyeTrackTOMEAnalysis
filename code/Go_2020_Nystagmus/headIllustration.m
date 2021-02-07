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
stlFileHead = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/_Papers/Aguirre_2021_movingEye/Figures/STL_files/human-head.stl';

% Load the faces and vertices. Using a shadowed versoin of stlread. I had
% to make a local copy and modify it to get this to load properly
fv = stlread(stlFileHead);

% Plot the object, and set the rotation and transparency
headObj = patch(fv,'FaceColor',       [0.5 0.5 0.5], ...
    'EdgeColor',       'none',        ...
    'FaceLighting',    'gouraud',     ...
    'AmbientStrength', 0.9);
headObj.FaceAlpha = 1.0;
direction = [0 0 1];
rotate(headObj,direction,90)

camlight
hold on
box off
axis off

% Arrow properties
l = 80;
sw = 1;

% Rotation arrow around z
c = [0 0 350];
cArc = c + [0 0 -l*2.5];
[a,b] = addRotArrow(cArc,3,l/2,'r',sw);
delete(a(2));
delete(b);
view(-90,90);

% Save it here
set(figHandle,'color','none');
fileName = ['~/Desktop/Yaw.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');


% Remove the arrow
delete(a(1));

% Rotation arrow around y
c = [0 -75 0];
cArc = c + [0 l*2.5 0];
[a,b] = addRotArrow(cArc,2,l/2,'r',sw);
delete(a(2));
delete(b);
view(-180,0);

% Save it here
set(figHandle,'color','none');
fileName = ['~/Desktop/Pitch.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

% Remove the arrow
delete(a(1));

% Rotation arrow around x
c = [75 0 0];
cArc = c + [-l*2.5 0 0];
[a,b] = addRotArrow(cArc,1,l/2,'r',sw);
delete(a(2));
delete(b);
view(-90,0);

% Save it here
set(figHandle,'color','none');
fileName = ['~/Desktop/Roll.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');



%% Close the figure
close(figHandle);