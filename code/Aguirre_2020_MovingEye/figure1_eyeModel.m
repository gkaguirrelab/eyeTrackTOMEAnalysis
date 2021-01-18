
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


viewNames = {'A','B','C','D'};
viewAngles = {[0,90],[0,0],[26,36],[10 50]};
alignPoint = {[-30 30 40],[-30 30 40],[-30 -30 40],[7.15 15 15]};
viewEle = [false,true,true,true];
viewAzi = [true,false,true,true];
xlim([-30 130]);
ylim([-30 30]);
zlim([-30 40]);
axis off

alignHandle = plot3(alignPoint{1}(1),alignPoint{1}(2),alignPoint{1}(3),'xm');

for vv = 1:length(viewNames)
    
    % Set the plot limits
    if vv == length(viewNames)
        xlim([-5 7.5]);
        ylim([-15 15]);
        zlim([-15 15]);
    end
    
    % Set the 3D view position
    view(viewAngles{vv}(1),viewAngles{vv}(2));
    
    % Display the alignPoint mark
    delete(alignHandle);
    alignHandle = plot3(alignPoint{vv}(1),alignPoint{vv}(2),alignPoint{vv}(3),'xm');
    
    % Save figure with rendered components
    showm(eyeHandles);
    showm(cameraHandles);
    hidem(rayHandles);
    hidem(scaleHandles);
    set(figHandle,'color','none');
    fileName = ['~/Desktop/Figure1_view' viewNames{vv} '.png'];
    export_fig(figHandle,fileName,'-r1200','-opengl');
    
    % Save figure with vector components
    hidem(eyeHandles);
    hidem(cameraHandles);
    showm(rayHandles);
    showm(scaleHandles);
    set(figHandle,'color','white');
    fileName = ['~/Desktop/Figure1_view' viewNames{vv} '.pdf'];
    export_fig(figHandle,fileName,'-Painters');
    
end


close(figHandle)

