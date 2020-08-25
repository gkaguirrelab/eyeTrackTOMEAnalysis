

% Get the DropBox base directory
dropboxBaseDir = getpref('eyeTrackTOMEAnalysis','dropboxBaseDir');

% Anonymous functions that assemble the full path for a given subect /
% session.
videoStem = @(sub,date) fullfile(dropboxBaseDir,'TOME_processing','session2_spatialStimuli',sub,date,'EyeTracking');

% Load the cleaned gazeData
load('/Users/aguirre/Documents/MATLAB/projects/movieGazeTOMEAnalysis/data/gazeData_cleaned.mat')

subjectList = {...
    'TOME_3001',...
    'TOME_3002',...
    'TOME_3003',...
    'TOME_3005',...
    };

sessionList = {...
    '081916',...
    '082616',...
    '091616',...
    '100316',...
    };

acqList = {...
    'tfMRI_MOVIE_AP_run01',...
    'tfMRI_MOVIE_AP_run02',...
    'tfMRI_MOVIE_PA_run03',...
    'tfMRI_MOVIE_PA_run04',...
    };

% Loop through the sessions
for ss = 1:length(sessionList)
    
    % The path stem
    pathStem = videoStem(subjectList{ss},sessionList{ss});
    
    outlineVideo = ['videoStemName{' subjectList{ss}(end-1:end) '} = { ...\n'];
    outlineGaze = ['gazeTargets{' subjectList{ss}(end-1:end) '} = { ...\n'];
    outlineFrame = ['frameSet{' subjectList{ss}(end-1:end) '} = { ...\n'];
    
    % Loop through the acquisitions
    for aa = 1:length(acqList)
        
        % Load the timebase
        timebaseFile = fullfile(pathStem,[acqList{aa},'_timebase.mat']);
        load(timebaseFile,'timebase');
        
        % Load the pupil data
        pupilFile = fullfile(pathStem,[acqList{aa},'_pupil.mat']);
        load(pupilFile,'pupilData');
        
        % Find the frames in the pupil file that correspond to the time
        % points of frames of high agreement in the movie
        frameSetStandard = gazeData.(acqList{aa}).synthTargets.frameSet;
        timeStamps = gazeData.timebase(frameSet);
        
        thisFrameSet = [];
        for tt = 1:length(timeStamps)
            [~,thisFrameSet(tt)] = min(abs(timebase.values - timeStamps(tt)));
        end
        
        % Get the ellipsefit RMSE for these frames and keep just the good
        % ones.
        RMSE = pupilData.initial.ellipses.RMSE(thisFrameSet);
        goodIdx = and(~isnan(RMSE),RMSE<1.5);
        thisFrameSet = thisFrameSet(goodIdx);
        
        gazeTargets = gazeData.(acqList{aa}).synthTargets.gazeTargets(:,goodIdx);
        
        % Report the data in a form ready to go in the sceneSearch script
        switch aa
            case {1,2}
                outlineVideo = [outlineVideo, 'videoStemMovieAP(''' subjectList{ss} ''',''' sessionList{ss} ''', ' num2str(aa) '), ...\n'];
            case {3,4}
                outlineVideo = [outlineVideo, 'videoStemMoviePA(''' subjectList{ss} ''',''' sessionList{ss} ''', ' num2str(aa) '), ...\n'];
        end
        outlineGaze = [outlineGaze , '[ ' num2str(gazeTargets(1,:)) '; ' num2str(gazeTargets(1,:)) ' ], ...\n'];
        outlineFrame = [outlineFrame , '[ ' num2str(thisFrameSet) ' ], ...\n'];
    end
    outlineGaze = [outlineGaze,'};\n\n'];
    outlineFrame = [outlineFrame,'};\n\n'];
    outlineVideo = [outlineVideo,'};\n\n'];
    
    fprintf(outlineVideo);
    fprintf(outlineGaze);
    fprintf(outlineFrame);
    
end


