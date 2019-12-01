% Creation of fixation target array for non-fixation sceneGeometry
%
% Description:
%   For most sessions, one or more gazeCalibration videos were recorded
%   during which subjects fixated locations of known visual angle. For some
%   early sessions, this measurement was not made. We here synthesize a set
%   of fixation targets for a scene geometry source video. These
%   non-gazeCal source videos were recorded while subjects watched a movie
%   (either WallE during the dMRI anatomical scans, or pixar shorts during
%   the tMRI "movie" scans).

rmseThresh = 5;

% Identify a sceneGeometry file
[sceneGeometryInName,sceneGeometryInPath] = uigetfile(fullfile('.','*_sceneGeometry.mat'),'Choose a sceneGeometry file');
sceneGeometryFileNameToSync = fullfile(sceneGeometryInPath,sceneGeometryInName);

% Load the sceneGeometry variable into memory
dataLoad=load(sceneGeometryFileNameToSync);
sceneGeometryIn=dataLoad.sceneGeometry;
clear dataLoad

% Get the ellipseArrayList
ellipseArrayList = sceneGeometryIn.meta.estimateSceneParams.ellipseArrayList;

% Get the filename stem for this sceneGeometry file, so that we can use it
% to load other, associated files
tmp = strsplit(sceneGeometryInName,'_sceneGeometry.mat');
sceneGeometryInStem = tmp{1};

% Load the pupil data file associated with the sceneGeometry
tmp = fullfile(sceneGeometryInPath,[sceneGeometryInStem,'_pupil.mat']);
load(tmp,'pupilData');

% Check that we have a radiusSmoothed field
if ~isfield(pupilData,'radiusSmoothed')
    warning('This sceneGeometry pupilData file does not contain a radiusSmoothed field; returning')
    return
end

% Find the frames in which the RMSE ellipse fit is less than a threshold
% (and is not nan)
goodIdx = logical(double(pupilData.radiusSmoothed.ellipses.RMSE < rmseThresh) .* ...
    double(~isnan(pupilData.radiusSmoothed.ellipses.RMSE)));

% We assume that gaze positions during the watching of the movie are evenly
% distributed around the center of the screen.
medianEyePose = median(pupilData.radiusSmoothed.eyePoses.values(goodIdx,:));
fixZeroX = medianEyePose(1);
fixZeroY = medianEyePose(2);

% Get the "fixation" positions of the ellipseArrayList, which are
% essentially the eye rotation values centered by the center of the
% distribution of all eye rotations.
xTargetDegrees = [];
yTargetDegrees = [];
for ii=1:length(ellipseArrayList)
    eyePose = pupilProjection_inv(pupilData.sceneConstrained.ellipses.values(ellipseArrayList(ii),:), ...
    sceneGeometryIn,'x0',pupilData.sceneConstrained.eyePoses.values(ellipseArrayList(ii),:));
    xTargetDegrees(ii) = eyePose(1) - fixZeroX;
    yTargetDegrees(ii) = eyePose(2) - fixZeroY;
end

% Remove any targets which have nan values
goodTargets = ~isnan(xTargetDegrees);
ellipseArrayList = ellipseArrayList(goodTargets);
xTargetDegrees = xTargetDegrees(goodTargets);
yTargetDegrees = yTargetDegrees(goodTargets);

% Generate a msg with these values
outLine1='ellipseArrayList: [ ';
outLine2='target array deg: [ ';
outLine3=' ';
for ii=1:length(ellipseArrayList)
    outLine1 = [outLine1 num2str(ellipseArrayList(ii))];
    outLine2 = [outLine2 num2str(xTargetDegrees(ii))];
    outLine3 = [outLine3 num2str(yTargetDegrees(ii))];
    if ii ~= length(ellipseArrayList)
        outLine1 = [outLine1 ', '];
        outLine2 = [outLine2 ', '];
        outLine3 = [outLine3 ', '];
    end
end
outLineB = [outLine1 ' ]'];
outLineC = [outLine2 ' ;' outLine3 ']'];

sceneGeometryFileNameToSync
fprintf([outLineB ' \n']);
fprintf([outLineC ' \n']);

% Plot the synthesized fixation locations on the screen
figure
h = scatter(pupilData.radiusSmoothed.eyePoses.values(goodIdx,1)-fixZeroX, ...
    pupilData.radiusSmoothed.eyePoses.values(goodIdx,2)-fixZeroY,50, ...
    [1 0 0],'filled','o','MarkerFaceAlpha',0.01);
xlim([-10 10]);
ylim([-10 10]);
hold on
plot(xTargetDegrees,yTargetDegrees,'xb')

