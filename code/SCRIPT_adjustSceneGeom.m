


% Get the DropBox base directory
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxBaseDir,'TOME_processing');
pathParams.eyeTrackingDir = 'EyeTracking';

fileListStruct=dir(fullfile(dropboxBaseDir,'TOME_processing','session2_spatialStimuli','*','*','EyeTracking','*_sceneGeometry.mat'));

fileIdx = 0;
notDone = true;
while notDone
    choice = input(['\nPick a sceneGeometry from 1-' num2str(length(fileListStruct)) ', return to pick the next one, and q to quit:  '],'s');
    if isempty(choice)
        fileIdx = fileIdx+1;
    else
        if strcmp(choice,'q')
            fileIdx = [];
            notDone = false;
        else
            fileIdx = str2double(choice);
        end
    end
    
    if ~isempty(fileIdx)
        sceneGeometryFileName = fullfile(fileListStruct(fileIdx).folder,fileListStruct(fileIdx).name);
        x = estimateSceneParamsGUI(sceneGeometryFileName);
        fprintf(['***  ' num2str(fileIdx) '   ' sceneGeometryFileName '   [%0.2f; %0.2f; %0.2f; %0.2f]\n'],x(1),x(2),x(3),x(4));
    end    
end

