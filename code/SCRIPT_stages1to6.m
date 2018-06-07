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
            '/Dropbox (Aguirre-Brainard Lab)');
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

% Ask the operator which project they would like to process
clc
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
fprintf('\n\nSelect the subjects to process (all sessions for the subject will be run):\n')
for pp=1:length(choiceList)
    optionName=['\t' num2str(pp) '. ' choiceList{pp} '\n'];
    fprintf(optionName);
end
fprintf('\nYou can enter a single subject number (e.g. 4),\n  a range defined with a colon (e.g. 4:7),\n  or a list within square brackets (e.g., [4 5 7]):\n')
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
        globalKeyValues = {};
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
        
        % Execute the pipeline for this project / session / subject, using
        % the global and custom key values
        pupilPipelineWrapper(pathParams, ...
            globalKeyValues{:}, ...
            'skipStageByName', {'deinterlaceVideo'}, 'makeFitVideoByNumber', [3 6],...
            'useLowResSizeCalVideo',true, ...
            'customKeyValues', customKeyValues);
        
    end % loop over session dates
end % loop over subjects

