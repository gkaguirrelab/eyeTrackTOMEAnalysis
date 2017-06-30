function raw2grayWrapper (dropboxDir,pathParams)

% define directories
dataDir = fullfile(dropboxDir,pathParams.projectFolder, pathParams.projectSubfolder, ...
    pathParams.subjectName,pathParams.sessionDate, pathParams.eyeTrackingDir);

processingDir = fullfile(dropboxDir,pathParams.outputDir, pathParams.projectSubfolder, ...
    pathParams.subjectName,pathParams.sessionDate, pathParams.eyeTrackingDir);
if ~exist(processingDir,'dir')
    mkdir(processingDir)
end 

% find raw videos
rawVideos = dir(fullfile(dropboxDir, pathParams.projectFolder, pathParams.projectSubfolder, ...
    pathParams.subjectName,pathParams.sessionDate,pathParams.eyeTrackingDir,'*.mov'));

% run raw2grey 
for rr = 1 :length(rawVideos) %loop in all video files
    fprintf ('\nProcessing video %d of %d\n',rr,length(rawVideos))
    if regexp(rawVideos(rr).name, regexptranslate('wildcard','*_raw.mov'))
        pathParams.runName = rawVideos(rr).name(1:end-8); %runs
    else
        pathParams.runName = rawVideos(rr).name(1:end-4); %calibrations
    end
    
    rawVideoName = fullfile(dataDir,rawVideos(rr).name);
    grayVideoName = fullfile(processingDir, [pathParams.runName '_gray.avi']);
    raw2gray(rawVideoName,grayVideoName, 'verbosity', 'full')
end