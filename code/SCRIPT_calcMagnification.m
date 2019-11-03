% During Session 2 scanning of the TOME study, subjects maintained central
% fixation during presentation of a retinotopic mapping stimulus. Some
% subjects wore contact or spectacle lenses during the scan. For these
% subjects (all of whom had negative lenses for correction of myopia) the
% stimuli on the screen were therefore minified, subtending a smaller
% visual angle than subjects without corrective lenses. I calculate here
% the degree of magnification. This value is used to adjust the conversion
% of screen coordinates to visual angle coordinates in the retinotopic
% mapping analysis.




% Get the DropBox base directory
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir'); 

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxBaseDir,'TOME_processing');
pathParams.eyeTrackingDir = 'EyeTracking';

% Set parameters common to all analyses from this project
universalKeyValues = {};

% Load analysis parameters table
paramsFileName = 'eyeTrackingParams.xls';
opts = detectImportOptions(paramsFileName);
opts.VariableTypes(:)={'char'};
paramsTable = readtable(paramsFileName, opts);

% Obtain the list of projects
projectList = unique(paramsTable{:,1});
projectList = projectList(~strcmp(projectList,''));

% Pick session 2 (which contains the retinotopy)
pathParams.projectSubfolder=projectList{2};

% Obtain a list of subjects for this project
subjectList = unique(paramsTable{strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder),2});

% Loop through the subjects
for ss = 1:length(subjectList)
    
    % Assign this subject ID to the path params
    pathParams.subjectID = subjectList{ss};
    
    % Find all the sessions for this project and subject
    projectSubjectIntersection = find(strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder) .* ...
        strcmp(paramsTable.subjectID, pathParams.subjectID));
    sessionDateList = unique(paramsTable{projectSubjectIntersection,3});

    % Loop through the session dates
    for dd = 1: length(sessionDateList)
                
        % Find the list of acquisitions in the params table for this
        % project, subject, and session
        rowList = find(strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder) .* ...
            strcmp(paramsTable.subjectID, pathParams.subjectID) .* ...
            strcmp(paramsTable.sessionDate, sessionDateList{dd}));
        
        globalKeyValues = {};
        
        % Loop through the list of entries in the params table
        for ii = 1:length(rowList)
            % If the acqusition field for this row is empty, then the
            % parameters are global.
            if strcmp(paramsTable.acquisition(rowList(ii)),'')
                theseGlobalKeyValues = {};
                for keys = 5:length(paramsTable.Properties.VariableNames)-1
                    if ~strcmp(paramsTable{rowList(ii),keys},'')
                        theseGlobalKeyValues = {theseGlobalKeyValues{:} paramsTable.Properties.VariableNames{keys} eval(cell2mat(paramsTable{rowList(ii),keys}))};
                    end
                end
                globalKeyValues = {globalKeyValues{:} theseGlobalKeyValues{:}};
            end
        end
        
        % Calculate the magnification
        magnification = 1;
        
        sceneGeometry = createSceneGeometry(globalKeyValues{:});
                
        if isfield(sceneGeometry.refraction.retinaToCamera,'magnification')
            if isfield(sceneGeometry.refraction.retinaToCamera.magnification,'contact')
                magnification = sceneGeometry.refraction.retinaToCamera.magnification.contact;
            end
            if isfield(sceneGeometry.refraction.retinaToCamera.magnification,'spectacle')
                magnification = sceneGeometry.refraction.retinaToCamera.magnification.spectacle;
            end
        end
        
        % Report this value
        fprintf([subjectList{ss} ' - ' sessionDateList{dd} ' -  (screenMagnification),%2.2f\n'],magnification);
    
    
    end % loop over session dates
end % loop over subjects

