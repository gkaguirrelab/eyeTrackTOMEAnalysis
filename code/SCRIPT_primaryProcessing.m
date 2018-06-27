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
fprintf('\t8. Scene-constrained pupil fitting and empirical Bayes smoothing (8-end)\n');
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
    case '9'
        skipStageByNumber = 1:8;
        lastStageByNumber = [];
        makeFitVideoByNumber = [];
        universalKeyValues = {};
end


% Ask the operator which project they would like to process
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

% Ask the operator which subject(s) they would like to process
choiceList = subjectList;
fprintf('\n\nSelect the subjects to process:\n')
for pp=1:length(choiceList)
    optionName=['\t' num2str(pp) '. ' choiceList{pp} '\n'];
    fprintf(optionName);
end
fprintf('\nYou can enter a single subject number (e.g. 4),\n  a range defined with a colon (e.g. 4:7),\n  or a list within square brackets (e.g., [4 5 7]):\n')
fprintf('If you select multiple subjects, all sessions and acquisitions will be run.\n');
choice = input('\nYour choice: ','s');

% This is an array of indices that refer back to the subjectList
subjectIndexList = eval(choice);

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
            globalKeyValues{:}, 'customKeyValues', customKeyValues);
        
    end % loop over session dates
end % loop over subjects

