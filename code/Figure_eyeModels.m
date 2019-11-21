% Pick the eyes with the smallest and largest refractive error, and then
% create and figures of the eye models for each of these.

figureOutPath = '~/Desktop';

subjectTableFileName = fullfile(getpref('eyeTrackTOMEAnalysis','dropboxBaseDir'),'TOME_subject','TOME-AOSO_SubjectInfo.xlsx');

% Load the subject data table
opts = detectImportOptions(subjectTableFileName);
subjectTable = readtable(subjectTableFileName, opts);

% Find the most myopic and hyperopic eyes
[~,myopeIdx] = min(subjectTable.SE_OD);
[~,hyperopeIdx] = max(subjectTable.SE_OD);

% Create a model eye for the myope
myopeEye = createSceneGeometry(...
    'sphericalAmetropia',subjectTable.SE_OD(myopeIdx),...
    'axialLength',subjectTable.Axial_Length_OD(myopeIdx),...
    'measuredCornealCurvature',eval(subjectTable.modelEyeK_OD{myopeIdx}), ...
    'calcLandmarkFovea',true);
[outputRay,rayPath] = calcLineOfSightRay(myopeEye);
figHandle = figure;
plotOpticalSystem('surfaceSet',myopeEye.refraction.retinaToCamera, ...
    'newFigure', false, ...
    'rayPath',rayPath,'outputRay',outputRay,...
    'surfaceAlpha',0.15,'addLighting',true);
zlim manual
xlim manual
ylim manual
xlim([-30 5]);
ylim([-12.5 12.5]);
zlim([-12.5 12.5]);
set(figHandle,'color','white')
print(figHandle,fullfile(figureOutPath,'myopeEye.png'),'-dpng','-r600');
close(figHandle);

hyperopeEye = createSceneGeometry(...
    'sphericalAmetropia',subjectTable.SE_OD(hyperopeIdx),...
    'axialLength',subjectTable.Axial_Length_OD(hyperopeIdx),...
    'measuredCornealCurvature',eval(subjectTable.modelEyeK_OD{hyperopeIdx}), ...
    'calcLandmarkFovea',true);
[outputRay,rayPath] = calcLineOfSightRay(hyperopeEye);
figHandle = figure;
plotOpticalSystem('surfaceSet',hyperopeEye.refraction.retinaToCamera,...
    'newFigure', false, ...
    'rayPath',rayPath,'outputRay',outputRay,...
    'surfaceAlpha',0.25,'addLighting',true);
zlim manual
xlim manual
ylim manual
xlim([-30 5]);
ylim([-12.5 12.5]);
zlim([-12.5 12.5]);
set(figHandle,'color','white')
print(figHandle,fullfile(figureOutPath,'hyperopeEye.png'),'-dpng','-r600');
close(figHandle);

