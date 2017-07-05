function pupilPipelineWrapper(pathParams)


%% hard coded parameters 
nFrames = 100; % number of frames to process (set to Inf to do all)
verbosity = 'full'; % Set to none to make the demo silent
TbTbProjectName = 'eyeTOMEAnalysis';

%% TbTb configuration
% We will suppress the verbose output, but detect if there are deploy
% errors and if so stop execution
tbConfigResult=tbUseProject(TbTbProjectName,'reset','full','verbose',false);
if sum(cellfun(@sum,extractfield(tbConfigResult, 'isOk')))~=length(tbConfigResult)
    error('There was a tb deploy error. Check the contents of tbConfigResult');
end
tbSnapshot=tbDeploymentSnapshot(tbConfigResult,'verbose',false);
clear tbConfigResult


% define full paths for input and output
pathParams.dataSourceDirFull = fullfile(pathParams.dataSourceDirRoot, pathParams.projectSubfolder, ...
        pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);
pathParams.dataOutputDirFull = fullfile(pathParams.dataOutputDirRoot, pathParams.projectSubfolder, ...
        pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);
pathParams.controlFileDirFull = fullfile(pathParams.controlFileDirRoot, pathParams.projectSubfolder, ...
        pathParams.subjectID, pathParams.sessionDate, pathParams.eyeTrackingDir);

% find raw videos
rawVideos = dir(fullfile(pathParams.dataSourceDirFull,'*.mov'));

% run the full pipeline on each raw video 
for rr = 1 :length(rawVideos) %loop in all video files
    fprintf ('\nProcessing video %d of %d\n',rr,length(rawVideos))
    if regexp(rawVideos(rr).name, regexptranslate('wildcard','*_raw.mov'))
        pathParams.runName = rawVideos(rr).name(1:end-8); %runs
    else
        pathParams.runName = rawVideos(rr).name(1:end-4); %calibrations
    end
    
    processVideoPipeline( pathParams, ...
    'nFrames',nFrames,'verbosity', verbosity,'tbSnapshot',tbSnapshot, 'useParallel',true);
    
end

end % function