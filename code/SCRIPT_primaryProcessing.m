

% Turn off the warning regarding over-writing the control file, as we are
% not hand-editing this file in this project
warningState = warning;
warning('off','makeControlFile:overwrittingControlFile');


% set dropbox directory
[~,hostname] = system('hostname');
hostname = strtrim(lower(hostname));

% handle hosts with custom dropbox locations
switch hostname
    case 'seele.psych.upenn.edu'
        dropboxDir = '/Volumes/seeleExternalDrive/Dropbox (Aguirre-Brainard Lab)';
    case 'magi-1-melchior.psych.upenn.edu'
        dropboxDir = '/Volumes/melchiorBayTwo/Dropbox (Aguirre-Brainard Lab)';
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

% Set parameters common to all analyses from this project
universalKeyValues = {'intrinsicCameraMatrix',[2627.0 0 338.1; 0 2628.1 246.2; 0 0 1],...
    'radialDistortionVector',[-0.3517 3.5353],...
    'constraintTolerance',0.05,...
    'eyeLaterality','right',...
    'rankScaling',[10 1 1], ...
    'spectralDomain','nir', ...
    'catchErrors', false};

% Load analysis parameters table
paramsFileName = 'eyeTrackingParams.xls';
opts = detectImportOptions(paramsFileName);
opts.VariableTypes(:)={'char'};
paramsTable = readtable(paramsFileName, opts);

% Obtain the list of projects
projectList = unique(paramsTable{:,1});
projectList = projectList(~strcmp(projectList,''));

% Set a flag variable to empty
consoleSelectAcquisition = [];

% Ask the operator which stages they would like to execute
clc
fprintf('Select the stages you would like to execute:\n')
fprintf('\t0. Deinterlacing only (1)\n');
fprintf('\t1. Deinterlacing to initial ellipse fitting (1-6)\n');
fprintf('\t2. Skip deinterlacing, to initial ellipse fitting (2-6)\n');
fprintf('\t3. Create a stage 3 fit video\n');
fprintf('\t4. Make control file to initial ellipse fitting (4-6)\n');
fprintf('\t5. Initial ellipse fitting only (6)\n');
fprintf('\t6. Create a stage 6 fit video\n');
fprintf('\t7. Create default sceneGeometry (7)\n');
fprintf('\t8. Search to refine sceneGeometry (7)\n');
fprintf('\t9. Scene-constrained pupil fitting (8)\n');
fprintf('\t10. Empirical Bayes smoothing (9)\n');
fprintf('\t11. Generate timebase only (1)\n');
fprintf('\t12. Identify gaze cal frames and targets\n');
fprintf('\t13. Align timebase with liveTrack report\n');
fprintf('\t14. Create a stage 8 fit video\n');
fprintf('\t15. Create a final fit video (10)\n');
fprintf('\t16. Perimeter definition to end, including video (3-6, 8-10)\n');
fprintf('\t17. Control file to end, including video (4-6, 8-10)\n');
fprintf('\t18. Scene-constrained fitting to end, including video (8-10)\n');
fprintf('\t19. Glint selection and final fit video (2, 10)\n');
fprintf('\t20. Glint selection only (2)\n');

stageChoice = input('\nYour choice: ','s');
switch stageChoice
    case '0'
        skipStageByNumber = [];
        lastStageByNumber = 1;
        makeFitVideoByNumber = [];
    case '1'
        skipStageByNumber = [];
        lastStageByNumber = 6;
        makeFitVideoByNumber = [];
    case '2'
        skipStageByNumber = 1;
        lastStageByNumber = 6;
        makeFitVideoByNumber = [];
    case '3'
        skipStageByNumber = 1:3;
        lastStageByNumber = 3;
        makeFitVideoByNumber = 3;
    case '4'
        skipStageByNumber = 1:3;
        lastStageByNumber = 6;
        makeFitVideoByNumber = [];
    case '5'
        skipStageByNumber = 1:5;
        lastStageByNumber = 6;
        makeFitVideoByNumber = [];
    case '6'
        skipStageByNumber = 1:6;
        lastStageByNumber = 6;
        makeFitVideoByNumber = 6;
    case '7'
        skipStageByNumber = 1:6;
        lastStageByNumber = 7;
        makeFitVideoByNumber = [];
        universalKeyValues = [universalKeyValues, {'nBADSsearches',0}];
    case '8'
        skipStageByNumber = 1:6;
        lastStageByNumber = 7;
        universalKeyValues = [universalKeyValues, {'nBADSsearches',10}];
        makeFitVideoByNumber = [];
    case '9'
        skipStageByNumber = 1:7;
        lastStageByNumber = 8;
        makeFitVideoByNumber = [];
    case '10'
        skipStageByNumber = 1:8;
        lastStageByNumber = 9;
        makeFitVideoByNumber = [];
    case '11'
        skipStageByNumber = 1:10;
        lastStageByNumber = 11;
        makeFitVideoByNumber = [];
    case '12'
        skipStageByNumber = [];
        lastStageByNumber = 1;
        universalKeyValues = [universalKeyValues, ...
            {'videoTypeChoice','gazeCalInfo_HighResWithDotTimes', ...
            'targetDeg',7,'skipStageByName',{'deinterlaceVideo'}}];
        makeFitVideoByNumber = [];
        consoleSelectAcquisition = false;
        sceneGeometryFlag = false;
    case '13'
        skipStageByNumber = [];
        lastStageByNumber = 1;
        universalKeyValues = [universalKeyValues, ...
            {'videoTypeChoice','adjustTimeBase', ...
            'savePlot',true,...
            'skipStageByName',{'deinterlaceVideo'}}];
        makeFitVideoByNumber = [];
    case '14'
        skipStageByNumber = 1:8;
        lastStageByNumber = 8;
        makeFitVideoByNumber = 8;
    case '15'
        skipStageByNumber = 1:9;
        lastStageByNumber = 10;
        makeFitVideoByNumber = [];
    case '16'
        skipStageByNumber = [1:2,7];
        lastStageByNumber = 10;
        makeFitVideoByNumber = [];
    case '17'
        skipStageByNumber = [1:3,7];
        lastStageByNumber = 10;
        makeFitVideoByNumber = [];
    case '18'
        skipStageByNumber = 1:7;
        lastStageByNumber = 10;
        makeFitVideoByNumber = [];
    case '19'
        skipStageByNumber = [1,3:9];
        lastStageByNumber = 10;
        makeFitVideoByNumber = [];
    case '20'
        skipStageByNumber = [1];
        lastStageByNumber = 2;
        makeFitVideoByNumber = [];
end


%% Ask the operator which project they would like to process
choiceList = projectList;
fprintf('Select a project:\n')
for pp=1:length(choiceList)
    optionName=['\t' char(pp+96) '. ' choiceList{pp} '\n'];
    fprintf(optionName);
end
projectChoice = input('\nYour choice: ','s');
projectChoice = int32(projectChoice);
if projectChoice >= 97 && projectChoice <= 122
    % Assign the chosen project sub folder to the path params
    pathParams.projectSubfolder=choiceList{projectChoice-96};
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
subjectChoice = input('\nYour choice: ','s');

% This is an array of indices that refer back to the subjectList
subjectIndexList = eval(subjectChoice);

if eval(stageChoice)~=12
    %% Ask the operator which acquisitions they would like to process
    acquisitionStems = [];
    sceneGeometryFlag = false;
    if length(subjectIndexList) > 1
        fprintf('Select the stages you would like to execute:\n')
        fprintf('\t1. All videos (fMRI, structural, gaze cal, scale cal)\n');
        fprintf('\t2. All fMRI and gaze cal\n');
        fprintf('\t3. All structural\n');
        fprintf('\t4. All gaze cal\n');
        fprintf('\t5. All scale cal\n');
        fprintf('\t6. Only FLASH\n');
        fprintf('\t7. Only MOVIE\n');
        fprintf('\t8. Only RETINO\n');
        fprintf('\t9. Only REST\n');
        fprintf('\t10. Only the custom sceneGeometry source video\n');
        acqChoice = input('\nYour choice: ','s');
        switch acqChoice
            case '1'
                acquisitionStems = [];
            case '2'
                acquisitionStems = {'fMRI_','GazeCal'};
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
else
    acquisitionStems = {'GazeCal'};
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
        stageChoice = input('\nYour choice: ','s');
        sessionDateList = sessionDateList(eval(stageChoice));
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
            if isempty(csgIdx)
                % Check if the customSceneGeometry is defined as a custom
                % key value, and not a global key value
                acquisitionStems={};
                for cc=1:size(customKeyValues,1)
                    keyList = find(cellfun(@(x) ischar(x),customKeyValues{cc}));
                    csgIdx = find(contains(customKeyValues{cc}(keyList),'customSceneGeometry'));
                    if ~isempty(csgIdx)
                        tmpStem=customKeyValues{cc}{keyList(csgIdx)+1};
                        tmpStem=strsplit(tmpStem{1},'_sceneGeometry.mat');
                        acquisitionStems = [acquisitionStems{:} tmpStem(1)];
                    end
                end
            else
                acquisitionStems = globalKeyValues{keyList(csgIdx)+1};
                % Remove the "_sceneGeometry.mat" suffix
                tmpStem=strsplit(acquisitionStems{1},'_sceneGeometry.mat');
                acquisitionStems = tmpStem(1);
            end
            % Handle the case in which no custom scene geometry has been
            % defined for this subject/session.
            if isempty(acquisitionStems)
                continue
            end
        end
        
        % Handle here the special case that the user has selected to
        % estimate sceneGeometry, and iris diameter has been provided
        if strcmp(stageChoice,'7') || strcmp(stageChoice,'8')
            % Check if the maxIrisDiamPixels has been defined
            irisKeyIdx = strcmp(globalKeyValues,'maxIrisDiamPixels');
            if sum(irisKeyIdx)==1
                
                % Use the iris diameter to find the expected camera depth
                % mean and SD. This is then used to set bound on camera
                % translation.
                irisKeyIdx=find(irisKeyIdx);
                maxIrisDiamPixels = globalKeyValues{irisKeyIdx+1};
                sceneGeometry = createSceneGeometry(universalKeyValues{:},'skipEyeAxes',true);
                [cameraDepthMean, cameraDepthSD] = depthFromIrisDiameter( sceneGeometry, maxIrisDiamPixels );
                
                % estimateSceneGeometry takes bounds on the search. If x0
                % params have been set, then we want fairly tight bounds on
                % translation, as the x0 value was set by hand.
                transDelta = 0.25;
                
                % Check to see if the spreadsheet has specified an x0 value
                % for the sceneParams.
                sceneParamsX0 = strcmp(globalKeyValues,'sceneParamsX0');
                if sum(sceneParamsX0)==1
                    x0 = globalKeyValues{find(sceneParamsX0)+1};
                    switch length(x0)
                        case 4
                            sceneParamsLB = [-22.5; x0(2:3)-transDelta; x0(4)-cameraDepthSD*0.25; 0.5; 0.8];
                            sceneParamsLBp = [-11.25; x0(2:3)-transDelta/2; x0(4)-cameraDepthSD*0.125; 0.75; 0.9];
                            sceneParamsUBp = [11.25; x0(2:3)+transDelta/2; x0(4)+cameraDepthSD*0.125; 1.25; 1.1];
                            sceneParamsUB = [22.5; x0(2:3)+transDelta; x0(4)+cameraDepthSD*0.25; 1.5; 1.2];
                        case 5
                            sceneParamsLB = [x0(1)-10; x0(2:3)-transDelta; x0(4)-cameraDepthSD*0.25; x0(5)*0.9; 0.8];
                            sceneParamsLBp = [x0(1)-5; x0(2:3)-transDelta/2; x0(4)-cameraDepthSD*0.125; x0(5)*0.95; 0.9];
                            sceneParamsUBp = [x0(1)+5; x0(2:3)+transDelta/2; x0(4)+cameraDepthSD*0.125; x0(5)*1.05; 1.1];
                            sceneParamsUB = [x0(1)+10; x0(2:3)+transDelta; x0(4)+cameraDepthSD*0.25; x0(5)*1.1; 1.2];
                        case 6
                            sceneParamsLB = x0;
                            sceneParamsLBp = x0;
                            sceneParamsUBp = x0;
                            sceneParamsUB = x0;
                        otherwise
                            error('Not sure to handle that sceneParamsX0 length');
                    end
                else
                    % Assemble the scene parameter bounds. These are in the
                    % order of:
                    %   torsion, x, y, z, eyeRotationScalarJoint, eyeRotationScalerDifferential
                    % where torsion specifies the torsion of the camera with
                    % respect to the eye in degrees, [x y z] is the translation
                    % of the camera w.r.t. the eye in mm, and the
                    % eyeRotationScalar variables are multipliers that act upon
                    % the centers of rotation estimated for the eye.
                    sceneParamsLB = [-5; -5; -5; cameraDepthMean-cameraDepthSD*1; 0.75; 0.9];
                    sceneParamsLBp = [-3; -2; -2; cameraDepthMean-cameraDepthSD*0.5; 0.85; 0.95];
                    sceneParamsUBp = [3; 2; 2; cameraDepthMean+cameraDepthSD*0.5; 1.15; 1.05];
                    sceneParamsUB = [5; 5; 5; cameraDepthMean+cameraDepthSD*1; 1.25; 1.1];
                end
                
                % Add these sceneParams to the globalKeyValues
                globalKeyValues = [globalKeyValues,...
                    {'sceneParamsLB',sceneParamsLB,'sceneParamsLBp',sceneParamsLBp,...
                    'sceneParamsUBp',sceneParamsUBp,'sceneParamsUB',sceneParamsUB}];
            end
        end
        
        % If there is only one subject and one session, give the user the
        % option to select acquisitions to process. This is implemented by
        % setting a flag here that is passed to the pipeline wrapper.
        if isempty(consoleSelectAcquisition)
            if length(subjectIndexList)==1 && length(sessionDateList)==1
                consoleSelectAcquisition = true;
            else
                consoleSelectAcquisition = false;
            end
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

% Restore the warning state
warning(warningState);

