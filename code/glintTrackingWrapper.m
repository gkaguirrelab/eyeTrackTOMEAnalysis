function glintTrackingWrapper(dropboxDir,params)
% wrapper function to be used in the glint tracking script


% get run names
runs = dir(fullfile(dropboxDir, params.outputDir, params.projectSubfolder, ...
    params.subjectName,params.sessionDate,params.eyeTrackingDir,'*60hz.avi'));
for rr = 1 :length(runs) %loop in all video files
    fprintf ('\nProcessing video %d of %d\n',rr,length(runs))
    %get the run name
    params.runName = runs(rr).name(1:end-9); %runs
    if regexp(runs(rr).name, regexptranslate('wildcard','*Cal*'))
        continue
    else
        inputVideo = fullfile(dropboxDir,params.outputDir, params.projectSubfolder, ...
            params.subjectName,params.sessionDate,params.eyeTrackingDir, ...
            [params.runName '_60hz.avi']);
        
        [grayI] = prepareVideo(inputVideo, 'numberOfFrames',numberOfFrames);
        
        glintFileName = fullfile(dropboxDir,params.outputDir, params.projectSubfolder, ...
            params.subjectName,params.sessionDate,params.eyeTrackingDir, ...
            [params.runName '_glint.mat']);
        
        trackGlint(grayI, glintFileName);
    end
end

fprintf ('>> done!\n')