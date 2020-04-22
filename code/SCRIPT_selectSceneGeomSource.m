

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
        
        % Find the set of gazeCal sceneGeometries for this session
        dirStem = fullfile(pathParams.dataOutputDirRoot,pathParams.projectSubfolder,pathParams.subjectID,pathParams.sessionDate,pathParams.eyeTrackingDir,'gazeCal*sceneGeometry.mat');
        gazeSceneGeomList = dir(dirStem);
        
        % Find the set of fMRI acquisitions for this session
        dirStem = fullfile(pathParams.dataOutputDirRoot,pathParams.projectSubfolder,pathParams.subjectID,pathParams.sessionDate,pathParams.eyeTrackingDir,'*fMRI*_gray.avi');
        fmriAcqList = dir(dirStem);
        
        % If there are decisions to make, let's get going
        if length(gazeSceneGeomList)>1 && ~isempty(fmriAcqList)
            
            % Make an invisible figure
            tmpFigHandle = figure('Visible','off');
            
            % Loop through the sceneGeometry files and identify the frame
            % corresponding to the fixation condition
            for gg = 1:length(gazeSceneGeomList)
                
                % Get the sceneGeometry for this gazeCal
                fileName = fullfile(gazeSceneGeomList(gg).folder,gazeSceneGeomList(gg).name);
                load(fileName,'sceneGeometry');
                
                % Which of the list of frames is the [0;0] fixation frame?
                idx = find((sceneGeometry.meta.estimateSceneParams.obj.gazeTargets(1,:)==0).*(sceneGeometry.meta.estimateSceneParams.obj.gazeTargets(2,:)==0));
                
                % Load in the video image for this frame.
                absIdx = sceneGeometry.meta.estimateSceneParams.obj.frameSet(idx);
                videoFileName = fullfile(gazeSceneGeomList(gg).folder,strrep(gazeSceneGeomList(gg).name,'_sceneGeometry.mat','_gray.avi'));
                videoFrame = makeMedianVideoImage(videoFileName,'startFrame',absIdx,'nFrames',1);
                
                % Activate the invisible figure
                set(0, 'CurrentFigure', tmpFigHandle)
                
                % Show the frame
                imshow(uint8(videoFrame),'Border', 'tight');
                
                % Empty the framesToMontage varable
                if gg==1
                    % Make it pixel-for-pixel
                    truesize(tmpFigHandle)
                    imSize = size(videoFrame);
                    dims = [imSize 3 4];
                    framesToMontage = uint8(zeros(dims)+128);
                end
                
                % Add cross-hairs
                hold on;
                plot([1 imSize(2)],[round(imSize(1)/2),round(imSize(1)/2)],'-b');
                plot([round(imSize(2)/2),round(imSize(2)/2)],[1 imSize(1)],'-b');
                
                % Add a text label to indicate the gazeCal
                text(40,40,gazeSceneGeomList(gg).name,'FontSize',24,'Color','y','Interpreter','none');
                
                % Add a text label to indicate the fVal
                str = sprintf('fVal = %2.4f',sceneGeometry.meta.estimateSceneParams.fVal);
                text(40,80,str,'FontSize',24,'Color','w','Interpreter','none');
                
                % Get the frame
                drawnow
                thisFrame=getframe(tmpFigHandle);
                
                % Store the frame
                framesToMontage(:,:,:,gg) = thisFrame.cdata;
            end
            
            % Get the montage image
            tmpHandle = montage(framesToMontage);
            
            % Save the montage image
            selectionMontage(:,:,:,1) = tmpHandle.CData;
            
            % Set up a figure that will display the selection montage, and
            % the acquisition to be matched
            figHandle = figure();
            
            % Loop over the acquisitions
            for aa = 1:length(fmriAcqList)
                
                % Get the timebase for this acquisition
                timebaseFileName = fullfile(fmriAcqList(aa).folder,strrep(fmriAcqList(aa).name,'_gray.avi','_timebase.mat'));
                load(timebaseFileName,'timebase');
                
                % We start by showing the frame that is 1000 msecs after
                % scan start
                targetTime = 1000;
                
                % Display the frame within a while loop, allowing the user
                % to click on the source image to move to a different frame
                stillSelecting = true;
                while stillSelecting
                    
                    % Find the frame at the target time.
                    [~, absIdx] = min(abs(timebase.values - targetTime));
                    
                    % Load in the video image for this frame.
                    videoFileName = fullfile(fmriAcqList(aa).folder,fmriAcqList(aa).name);
                    videoFrame = makeMedianVideoImage(videoFileName,'startFrame',absIdx,'nFrames',1);
                    
                    % Activate the invisible figure
                    set(0, 'CurrentFigure', tmpFigHandle)
                    
                    % Show the frame
                    imshow(uint8(videoFrame),'Border', 'tight');
                    
                    % Make it pixel-for-pixel
                    truesize(tmpFigHandle)
                    
                    % Add cross-hairs
                    hold on;
                    imSize = size(videoFrame);
                    plot([1 imSize(2)],[round(imSize(1)/2),round(imSize(1)/2)],'-b');
                    plot([round(imSize(2)/2),round(imSize(2)/2)],[1 imSize(1)],'-b');
                    
                    % Add a text label to name the acquisition
                    text(40,40,fmriAcqList(gg).name,'FontSize',24,'Color','y','Interpreter','none');
                    
                    % Add a text label to indicate the frame number
                    str = sprintf('frame = %d',absIdx);
                    text(40,80,str,'FontSize',24,'Color','w','Interpreter','none');
                    
                    % Get the frame
                    drawnow
                    thisFrame=getframe(tmpFigHandle);
                    
                    % Store the frame, 4x in size
                    selectionMontage(:,:,:,2) = imresize(thisFrame.cdata,[size(selectionMontage,1) size(selectionMontage,2)]);
                    
                    % Get the montage image
                    tmpHandle = montage(selectionMontage);
                    selectionImage = tmpHandle.CData;
                    
                    % Switch to the visible figure
                    figure(figHandle)
                    
                    % Show the selection image
                    imshow(selectionImage,'Border', 'tight');
                    
                    % Make it pixel-for-pixel
                    truesize(figHandle)
                    
                    % Prompt the user to select a gazeCal
                    selectImageSize = size(selectionImage);
                    roi = drawpoint();
                    
                    xFrame = ceil(roi.Position(1)/(selectImageSize(2)/4));
                    yFrame = ceil(roi.Position(2)/(selectImageSize(1)/2));
                    
                    % Handle while behavior depending upon the click
                    % position
                    switch xFrame
                        case {1,2}
                            % We have selected a frame
                            frameChoice = (yFrame-1)*2+xFrame;
                            if frameChoice <= length(gazeSceneGeomList)
                                stillSelecting = false;
                            end
                        case 3
                            % Move back in time
                            targetTime = targetTime - 100;
                        case 4
                            % Move forward in time
                            targetTime = targetTime + 100;
                    end
                    
                    % Delete the roi
                    delete(roi);
                    
                end
                
                % Report the selection
                str = [pathParams.subjectID '/' pathParams.sessionDate '/' fmriAcqList(aa).name ': customSceneGeometryFile {' strrep(gazeSceneGeomList(frameChoice).name,'_sceneGeometry.mat','') '}\n'];
                fprintf(str)
                
            end
            
        end
        
    end % loop over session dates
end % loop over subjects
