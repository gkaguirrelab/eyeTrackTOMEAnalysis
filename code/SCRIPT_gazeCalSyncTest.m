%% SCRIPT_gazeCalSyncTest

% Get the DropBox base directory
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxBaseDir,'TOME_processing');
pathParams.eyeTrackingDir = 'EyeTracking';

% Load analysis parameters table
paramsFileName = 'eyeTrackingParams.xls';
opts = detectImportOptions(paramsFileName);
opts.VariableTypes(:)={'char'};
paramsTable = readtable(paramsFileName, opts);

% Obtain the list of projects
projectList = unique(paramsTable{:,1});
projectList = projectList(~strcmp(projectList,''));

% This is only a meaningful activity for session 2
pathParams.projectSubfolder = projectList{2};

% Obtain a list of subjects for this project
subjectList = unique(paramsTable{strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder),2});

% Ask the operator which subject(s) they would like to process
choiceList = subjectList;
fprintf('\n\nSelect the subjects to process:\n')
for pp=1:length(choiceList)
    optionName=['\t' num2str(pp) '. ' choiceList{pp} '\n'];
    fprintf(optionName);
end
fprintf('\nYou can enter a single subject number (e.g. 4),\n  a range defined with a colon (e.g. 4:7),\n  or a list within square brackets (e.g., [4 5 7]):\n')
subjectChoice = input('\nYour choice: ','s');

% This is an array of indices that refer back to the subjectList
subjectIndexList = eval(subjectChoice);


% Loop through the selected subjects
for ss = 1:length(subjectIndexList)
    
    % Assign this subject ID to the path params
    pathParams.subjectID = subjectList{subjectIndexList(ss)};
    
    % Find all the sessions for this project and subject
    projectSubjectIntersection = find(strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder) .* ...
        strcmp(paramsTable.subjectID, pathParams.subjectID));
    sessionDateList = unique(paramsTable{projectSubjectIntersection,3});
    
    % Loop through the session dates
    for dd = 1: length(sessionDateList)
        
        % Assign this session date to the path params
        pathParams.sessionDate = sessionDateList{dd};
        
        % Find the set of gazeCal sceneGeometries for this session
        dirStem = fullfile(pathParams.dataOutputDirRoot,pathParams.projectSubfolder,pathParams.subjectID,pathParams.sessionDate,pathParams.eyeTrackingDir,'gazeCal*sceneGeometry.mat');
        gazeSceneGeomList = dir(dirStem);
        
        % If there is more than one GazeCal, let's get going
        if length(gazeSceneGeomList)>1
            
            % Loop through pairings of the sceneGeometry files
            for ga = 1:length(gazeSceneGeomList)
                for gb = 1:length(gazeSceneGeomList)
                    suffix = sprintf('_%d->%d',ga,gb);
                    
                    videoStemNameIn = fullfile(gazeSceneGeomList(ga).folder,strrep(gazeSceneGeomList(ga).name,'_sceneGeometry.mat',''));
                    videoStemNameOut = fullfile(gazeSceneGeomList(gb).folder,strrep(gazeSceneGeomList(gb).name,'_sceneGeometry.mat',''));
                    
                    syncSceneGeometry(videoStemNameIn, videoStemNameOut,'outputFileSuffix',suffix,'alignMethod','gazeCalTest');
                    
                end % Inner gazeCal loop
                
            end % Outer gazeCal loop
            
        end % We have more than one gazeCal
        
    end % loop over session dates
    
end % loop over subjects
