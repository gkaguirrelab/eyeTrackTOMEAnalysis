%% Stages 1 - 6
%
% This script allows the user to select a project (i.e., Session 1 or
% Session 2 of the TOME study), then a set of subjects, and then submits
% that set of projects / subjects / sessions to analysis from the stage of
% initial de-interlacing of the pupil video to "stage 6", which is the
% initial ellipse fit.


% set dropbox directory
[~,hostname] = system('hostname');
hostname = strtrim(lower(hostname));

% handle hosts with custom dropbox locations
switch hostname
    case 'seele.psych.upenn.edu'
        dropboxDir = '/Volumes/seeleExternalDrive/Dropbox (Aguirre-Brainard Lab)';
    case 'magi-1-melchior.psych.upenn.edu'
        dropboxDir = '/Volumes/melchiorExternalDrive/Dropbox (Aguirre-Brainard Lab)';
    case 'magi-2-balthasar.psych.upenn.edu'
        dropboxDir = '/Volumes/balthasarExternalDrive/Dropbox (Aguirre-Brainard Lab)';
    otherwise
        [~, userName] = system('whoami');
        userName = strtrim(userName);
        dropboxDir = ...
            fullfile('/Users', userName, ...
            'Dropbox (Aguirre-Brainard Lab)');
end

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxDir,'TOME_data');
pathParams.dataOutputDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.controlFileDirRoot = fullfile(dropboxDir,'TOME_processing');
pathParams.eyeTrackingDir = 'EyeTracking';

% Load analysis parameters table
paramsFileName = 'eyeTrackingParams.xls';
opts = detectImportOptions(paramsFileName);
opts.VariableTypes(:)={'char'};
paramsTable = readtable(paramsFileName, opts);

% Obtain the list of projects
projectList = unique(paramsTable{:,1});
projectList = projectList(~strcmp(projectList,''));

% Ask the operator which stages they would like to execute
clc
fprintf('Select the stages you would like to execute:\n')
fprintf('\t1. Deinterlacing to initial ellipse fitting (1-6)\n');
fprintf('\t2. Skip deinterlacing, to initial ellipse fitting (2-6)\n');
fprintf('\t3. Create a stage 3 fit video\n');
fprintf('\t4. Make control file to initial ellipse fitting (4-6)\n');
fprintf('\t5. Create a stage 6 fit video\n');
fprintf('\t6. Create default sceneGeometry (7)\n');
fprintf('\t7. Search to refine sceneGeometry (7)\n');
fprintf('\t8. Scene-constrained pupil fitting to end (8-end)\n');
fprintf('\t8. Empirical Bayes smoothing to end (9-end)\n');
choice = input('\nYour choice: ','s');
switch choice
    case '1'
        skipStageByNumber = [];
        lastStageByNumber = 6;
        makeFitVideoByNumber = [];
        universalKeyValues = {};
    case '2'
        skipStageByNumber = 1;
        lastStageByNumber = 6;
        makeFitVideoByNumber = [];
        universalKeyValues = {};
    case '3'
        skipStageByNumber = 1:3;
        lastStageByNumber = 3;
        makeFitVideoByNumber = 3;
        universalKeyValues = {};
    case '4'
        skipStageByNumber = 1:3;
        lastStageByNumber = 6;
        makeFitVideoByNumber = [];
        universalKeyValues = {};
    case '5'
        skipStageByNumber = 1:6;
        lastStageByNumber = 6;
        makeFitVideoByNumber = 6;
        universalKeyValues = {};
    case '6'
        skipStageByNumber = 1:6;
        lastStageByNumber = 7;
        makeFitVideoByNumber = [];
        universalKeyValues = {'nBADSsearches',0};
    case '7'
        skipStageByNumber = 1:6;
        lastStageByNumber = 7;
        makeFitVideoByNumber = [];
        universalKeyValues = {};
    case '8'
        skipStageByNumber = 1:7;
        lastStageByNumber = [];
        makeFitVideoByNumber = [];
        universalKeyValues = {};
    case '9'
        skipStageByNumber = 1:8;
        lastStageByNumber = [];
        makeFitVideoByNumber = [];
        universalKeyValues = {};
end


%% Ask the operator which project they would like to process
choiceList = projectList;
fprintf('Select a project:\n')
for pp=1:length(choiceList)
    optionName=['\t' char(pp+96) '. ' choiceList{pp} '\n'];
    fprintf(optionName);
end
choice = input('\nYour choice: ','s');
choice = int32(choice);
if choice >= 97 && choice <= 122
    % Assign the chosen project sub folder to the path params
    pathParams.projectSubfolder=choiceList{choice-96};
end

% Obtain a list of subjects for this project
subjectList = unique(paramsTable{strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder),2});


%% Ask the operator which subject(s) they would like to process
choiceList = subjectList;
fprintf('\n\nSelect the subjects to process:\n')
for pp=1:length(choiceList)
    optionName=['\t' num2str(pp) '. ' choiceList{pp} '\n'];
    fprintf(optionName);
end
fprintf('\nYou can enter a single subject number (e.g. 4),\n  a range defined with a colon (e.g. 4:7),\n  or a list within square brackets (e.g., [4 5 7]):\n')
choice = input('\nYour choice: ','s');

% This is an array of indices that refer back to the subjectList
subjectIndexList = eval(choice);


%% Ask the operator which acquisitions they would like to process
acquisitionStems = [];
sceneGeometryFlag = false;
if length(subjectIndexList) > 1
fprintf('Select the stages you would like to execute:\n')
fprintf('\t1. All videos (fMRI, structural, gaze cal, scale cal)\n');
fprintf('\t2. All fMRI\n');
fprintf('\t3. All structural\n');
fprintf('\t4. All gaze cal\n');
fprintf('\t5. All scale cal\n');
fprintf('\t6. Only FLASH\n');
fprintf('\t7. Only MOVIE\n');
fprintf('\t8. Only RETINO\n');
fprintf('\t9. Only REST\n');
fprintf('\t10. Only the custom sceneGeometry source video\n');
choice = input('\nYour choice: ','s');
switch choice
    case '1'
        acquisitionStems = [];
    case '2'
        acquisitionStems = {'fMRI_'};
    case '3'
        acquisitionStems = {'T1_','T2_','dMRI_'};
    case '4'
        acquisitionStems = {'GazeCal'};
    case '5'
        acquisitionStems = {'ScaleCal'};
    case '6'
        acquisitionStems = {'tfMRI_FLASH_'};
    case '7'
        acquisitionStems = {'tfMRI_MOVIE_'};
    case '8'
        acquisitionStems = {'tfMRI_RETINO_'};
    case '9'
        acquisitionStems = {'rfMRI_REST_'};
    case '10'
        % This is not the name of a acquistion file, but a flag to later
        % code to replace this stem with the identity of the sceneGeometry
        % input acquisition.
        sceneGeometryFlag = true;
        acquisitionStems = {''};
end
    
end

% Loop through the selected subjects
for ss = 1:length(subjectIndexList)
    
    % Assign this subject ID to the path params
    pathParams.subjectID = subjectList{subjectIndexList(ss)};
    
    % Find all the sessions for this project and subject
    projectSubjectIntersection = find(strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder) .* ...
        strcmp(paramsTable.subjectID, pathParams.subjectID));
    sessionDateList = unique(paramsTable{projectSubjectIntersection,3});
    
    if length(subjectIndexList)==1 && length(sessionDateList)>1
        choiceList = sessionDateList;
        fprintf('\n\nSelect the sessions to process:\n')
        for pp=1:length(choiceList)
            optionName=['\t' num2str(pp) '. ' choiceList{pp} '\n'];
            fprintf(optionName);
        end
        fprintf('\nYou can enter a single session number (e.g. 1),\n  a range defined with a colon (e.g. 1:2),\n  or a list within square brackets (e.g., [1 2]):\n')
        fprintf('If you select multiple sessions, all acquisitions will be run.\n');
        choice = input('\nYour choice: ','s');
        sessionDateList = sessionDateList(eval(choice));
    end

    % Loop through the session dates
    for dd = 1: length(sessionDateList)
        
        % Assign this session date to the path params
        pathParams.sessionDate = sessionDateList{dd};
        
        % Find the list of acquisitions in the params table for this
        % project, subject, and session
        rowList = find(strcmp(paramsTable.projectSubfolder, pathParams.projectSubfolder) .* ...
            strcmp(paramsTable.subjectID, pathParams.subjectID) .* ...
            strcmp(paramsTable.sessionDate, pathParams.sessionDate));
        
        % Define some variables that will hold global and
        % acquisition-specific, custom key values for the analysis of the
        % videos from this session
        globalKeyValues = universalKeyValues;
        customKeyValues = {};
        
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
            else
                % The table VariableNames are the keys for the key-value
                % pairs, with the exception of the first four variables
                % (which are project, subject, session, acquisition) and
                % the last variable (which is notes)
                theseAcqKeyValues = {};
                theseAcqKeyValues{1} = paramsTable.acquisition{rowList(ii)};
                for keys = 5:length(paramsTable.Properties.VariableNames)-1
                    if ~strcmp(paramsTable{rowList(ii),keys},'')
                        theseAcqKeyValues = {theseAcqKeyValues{:} paramsTable.Properties.VariableNames{keys} eval(cell2mat(paramsTable{rowList(ii),keys}))};
                    end
                end
                customKeyValues{end+1,1}=theseAcqKeyValues;
            end
        end
        
        % Handle here the special case that the user wishes to only process
        % those acquisitions which have been identified as being the source
        % of a custom sceneGeometry input
        if sceneGeometryFlag
            foo=1;
            keyList = find(cellfun(@(x) ischar(x),globalKeyValues));
            csgIdx = find(contains(globalKeyValues(keyList),'customSceneGeometry'));
            acquisitionStems = globalKeyValues{keyList(csgIdx)+1};
            % There should only be one acqusition stem now. Remove the
            % "_sceneGeometry.mat" suffix
            tmpStem=strsplit(acquisitionStems{1},'_sceneGeometry.mat');
            acquisitionStems = tmpStem(1);
        end
        
        % If there is only one subject and one session, give the user the
        % option to select acquisitions to process. This is implemented by
        % setting a flag here that is passed to the pipeline wrapper.
        if length(subjectIndexList)==1 && length(sessionDateList)==1
            consoleSelectAcquisition = true;
        else
            consoleSelectAcquisition = false;
        end
        
        % Execute the pipeline for this project / session / subject, using
        % the global and custom key values
        pupilPipelineWrapper(pathParams, ...
            'lastStageByNumber', lastStageByNumber, ...
            'skipStageByNumber', skipStageByNumber, ...
            'makeFitVideoByNumber',makeFitVideoByNumber, ...
            'consoleSelectAcquisition',consoleSelectAcquisition, ...
            'acquisitionStems',acquisitionStems,...
            globalKeyValues{:}, 'customKeyValues', customKeyValues);
        
    end % loop over session dates
end % loop over subjects

