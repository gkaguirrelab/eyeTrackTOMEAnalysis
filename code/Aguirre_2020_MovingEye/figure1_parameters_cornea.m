
clear
close all
sceneGeometry=createSceneGeometry('sphericalAmetropia',-5,'spectacleLens',-5);

%% Show the cornea ellipsoid
figHandle = figure();
S = sceneGeometry.eye.cornea.S(2,:);
bb = sceneGeometry.eye.cornea.boundingBox(2,:);
bb_full = [ -40   -0.0062   -12   12   -12    12];
quadric.plotSurface(S,bb_full,'none',0.1,'k',[],0.1);
quadric.plotSurface(S,bb,'none',0.25,'b','b',1);
hold on

%% Add axis
r = quadric.radii(S);
plot3([-r(1)*2 0],[0 0],[0 0],'-r','LineWidth',2);
plot3([-r(1) -r(1)],[-r(2) r(2)],[0 0],'-r','LineWidth',2);
plot3([-r(1) -r(1)],[0 0],[-r(3) r(3)],'-r','LineWidth',2);

% Add axes to indicate the centers of rotation
swivelRadius = 3;
axisSet = {[1 2 3],[3 2 1],[1 3 2]};
cSet = {[-r(1) 0 r(3)+swivelRadius],[-r(1)*2-swivelRadius 0 0],[-r(1) -r(2)-swivelRadius 0]};
p1Set = {[-swivelRadius 0 0],[0 swivelRadius 0],[swivelRadius 0 0],[-swivelRadius 0 0]};
p2Set = {[0 swivelRadius 0],[swivelRadius 0 0],[0 -swivelRadius 0],[-swivelRadius -2 0]};
color = 'r';
for cc = 1:3
    for aa = 1:4
        p1 = cSet{cc}+p1Set{aa}(axisSet{cc});
        p2 = cSet{cc}+p2Set{aa}(axisSet{cc});
        if aa == 4
        else
            p = plotArc3D(p1, p2, cSet{cc}, 20,color);
            p.LineWidth = 2;
        end
    end
end
view(53,31);
plot3(-30,-15,15,'xm')
xlim([-35 0]);
ylim([-15 15]);
zlim([-15 15]);
axis off

set(figHandle,'color','white');
fileName = ['~/Desktop/Figure1_corneaParams.pdf'];
export_fig(figHandle,fileName,'-Painters');
close(figHandle)

figHandle = figure();
quadric.plotSurface(S,bb_full,[0.5 0.5 0.5],0.1);
quadric.plotSurface(S,bb,[0.5 0.5 1],0.25);


% Add axes to indicate the centers of rotation
swivelRadius = 3;
axisSet = {[1 2 3],[3 2 1],[1 3 2]};
cSet = {[-r(1) 0 r(3)+swivelRadius],[-r(1)*2-swivelRadius 0 0],[-r(1) -r(2)-swivelRadius 0]};
p1Set = {[-swivelRadius 0 0],[0 swivelRadius 0],[swivelRadius 0 0],[-swivelRadius 0 0]};
p2Set = {[0 swivelRadius 0],[swivelRadius 0 0],[0 -swivelRadius 0],[-swivelRadius -2 0]};
color = 'r';
for cc = 1:3
    for aa = 1:4
        p1 = cSet{cc}+p1Set{aa}(axisSet{cc});
        p2 = cSet{cc}+p2Set{aa}(axisSet{cc});
        if aa == 4
            mArrow3(p1,p2,'stemWidth',0.1,'tipWidth',0.5,'color',color,'FaceAlpha',0.5);
        else
        end
    end
end

camlight
lighting gouraud
view(53,31);
hold on
plot3(-30,-15,15,'xm')
xlim([-35 0]);
ylim([-15 15]);
zlim([-15 15]);
axis off

set(figHandle,'color','none');
fileName = ['~/Desktop/Figure1_corneaParams.png'];
export_fig(figHandle,fileName,'-r1200','-opengl');
close(figHandle)


