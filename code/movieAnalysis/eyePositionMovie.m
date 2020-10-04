
% Obtain the cleaned data

% Load the cleaned data
gazeDataSave = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session2_spatialStimuli/pupilDataQAPlots_eyePose_MOVIE_July2020/gazeData_cleaned.mat';
load(gazeDataSave);

% These are the fields to process
fieldNames = {'tfMRI_MOVIE_AP_run01','tfMRI_MOVIE_AP_run02','tfMRI_MOVIE_PA_run03','tfMRI_MOVIE_PA_run04'};

% A suffix for the output avi
%fileSuffix = '_TOME_3017_model';
fileSuffix = '_allSubjects';

% The symbol to plot
plotSymbol = 'FilledCircle';

% Include eye

% The movie start times (in seconds) for each of the acquisitions
movieStartTimes = [1880, 2216, 892, 1228];

% Account for a quarter-second phase shift that appears to be present
% between the eye tracking and the movie
phaseCorrect = -0.25;

% How long a trail (in frames) do we leave behind each tracking circle?
nTrail = 0;

% Convert gaze coodinates and stop radius to screen coordinates
screenCoord = @(gazeCoord) (-gazeCoord).*(1080/20.8692) + [1920 1080]/2;
symbolRadius = @(relRad) (1+relRad) .* 25;

% Set up the video in
videoInFilePath = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_materials/StimulusFiles/PixarShorts.mov';
v = VideoReader(videoInFilePath);

% Define the filename out stem
dropboxBaseDir = getpref('movieGazeTOMEAnalysis','dropboxBaseDir');
fileOutStem = fullfile(dropboxBaseDir,'TOME_analysis','movieGazeTrack');

% Loop over the fieldNames
for ff = 1:length(fieldNames)
    
    % Get this cleaned matrix
    vqCleaned = gazeData.(fieldNames{ff}).vqCleaned;
        
    % Set up the timebase.
    timebaseSecs = (gazeData.timebase./1000) + movieStartTimes(ff) + phaseCorrect;
    
    % Set up the symbol colors
    nSubs = size(vqCleaned,1);
    colors = getDistinguishableColors(nSubs).*255;    

    % Which subs are we plotting?
    theSubs = 1:nSubs;
%    theSubs = 11;
    
    % If we have one subject, open the eye video to superimpose
    if length(theSubs)==1
%        videoEyeFilePath = [gazeData.(fieldNames{ff}).filePathStem{theSubs} '_gray.avi'];
        videoEyeFilePath = [gazeData.(fieldNames{ff}).filePathStem{theSubs} '_finalFit.avi'];
        ve = VideoReader(videoEyeFilePath);
        timeEyeFilePath = [gazeData.(fieldNames{ff}).filePathStem{theSubs} '_timebase.mat'];
        dataload = load(timeEyeFilePath);
        eyeTimebase = dataload.timebase;
        eyePhaseCorrect = eyeTimebase.values(1)/1000;
        clear dataload
    end
    
    % Set up the video out
    fileNameOut = fullfile(fileOutStem,[fieldNames{ff} '_gazeTrack' fileSuffix '.avi']);
    vo = VideoWriter(fileNameOut);
    
    % Set the frame rate for the output
    vo.FrameRate = 1/(timebaseSecs(2)-timebaseSecs(1));
    
    % Open the video out object
    open(vo);
    
    % Loop through the frames
    for tt = 1:length(timebaseSecs)
        v.CurrentTime=timebaseSecs(tt);
        f = readFrame(v);
        for ss = theSubs
            thisCoord = screenCoord(squeeze(vqCleaned(ss,1:2,tt)));
            thisRadius = symbolRadius(vqCleaned(ss,3,tt));
            if ~any(isnan([thisCoord thisRadius]))
                f = insertShape(f,plotSymbol,[thisCoord thisRadius],'LineWidth',3,'Color',colors(ss,:));
                for rr = 1:min([nTrail tt-1])
                    lineCoords = [screenCoord(squeeze(vqCleaned(ss,1:2,tt-rr+1))) ...
                        screenCoord(squeeze(vqCleaned(ss,1:2,tt-rr)))];
                    if ~any(isnan(lineCoords))
                        f = insertShape(f,'line',lineCoords,'LineWidth',5,'Color',colors(ss,:));
                    end
                end
            end
        end
        if length(theSubs)==1
            eyeTime = timebaseSecs(tt) - movieStartTimes(ff) - phaseCorrect - eyePhaseCorrect;
            ve.CurrentTime = eyeTime;
            fe = readFrame(ve);
            fe = imresize(fe,0.5);
            f(end-size(fe,1)+1:end,1:size(fe,2),:)=fe;
        end
        writeVideo(vo,f)
    end
    
    % Close and clear the video objects
    close(vo);
    clear vo
    
end

clear v
