
clear
close all

%% Panel A

sceneGeometry=createSceneGeometry();
sceneGeometry.cameraPosition.glintSourceRelative = [-14 14; 0 0; 0 0];

figHandle = figure();

cameraHandles = addCameraIcon(sceneGeometry);
for ii = 1:length(cameraHandles)
    cameraHandles(ii).FaceAlpha = 1;
end
hold on

color = 'r';
%% Add a translation bar
plot3([120 130],[5 5],[25 25],'-', 'Color', color,'LineWidth',2);
mArrow3([120 5 25],[118 5 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([130 5 25],[132 5 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

plot3([125 125],[0 10],[25 25],'-', 'Color', color,'LineWidth',2);
mArrow3([125 0 25],[125 -2 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([125 10 25],[125 12 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

plot3([125 125],[5 5],[20 30],'-', 'Color', color,'LineWidth',2);
mArrow3([125 5 20],[125 5 18],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([125 5 30],[125 5 32],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);


view(-57,20);
axis off

xlim([100 135]);
ylim([-35 30]);
zlim([-20 40]);

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure3_cameraIllo_A.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

close(figHandle)



%% Panel B

sceneGeometry=createSceneGeometry();

figHandle = figure();

cameraHandles = addCameraIcon(sceneGeometry);
for ii = 1:length(cameraHandles)
    cameraHandles(ii).FaceAlpha = 1;
end
hold on

color = 'r';
%% Add a translation bar
plot3([120 130],[5 5],[25 25],'-', 'Color', color,'LineWidth',2);
mArrow3([120 5 25],[118 5 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([130 5 25],[132 5 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

plot3([125 125],[0 10],[25 25],'-', 'Color', color,'LineWidth',2);
mArrow3([125 0 25],[125 -2 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([125 10 25],[125 12 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

plot3([125 125],[5 5],[20 30],'-', 'Color', color,'LineWidth',2);
mArrow3([125 5 20],[125 5 18],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([125 5 30],[125 5 32],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);


view(-57,20);
axis off

xlim([100 135]);
ylim([-35 30]);
zlim([-20 40]);

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure3_cameraIllo_B.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

close(figHandle)




%% Panel C

sceneGeometry=createSceneGeometry();

figHandle = figure();

cameraHandles = addCameraIcon(sceneGeometry);
for ii = 1:length(cameraHandles)
    cameraHandles(ii).FaceAlpha = 1;
end
hold on

color = 'r';
%% Add a translation bar

plot3([125 125],[0 10],[25 25],'-', 'Color', color,'LineWidth',2);
mArrow3([125 0 25],[125 -2 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([125 10 25],[125 12 25],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);

plot3([125 125],[5 5],[20 30],'-', 'Color', color,'LineWidth',2);
mArrow3([125 5 20],[125 5 18],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
mArrow3([125 5 30],[125 5 32],'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);


view(-57,20);
axis off

xlim([100 135]);
ylim([-35 30]);
zlim([-20 40]);

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure3_cameraIllo_C.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');

close(figHandle)

