%% eyeTOME_plotAverageEyeData
%
% This routine takes a list of subjects and loads the pupil and gaze data
% for each experiment and run and produces plots.


% Housekeeping
clearvars;
close all;

% Data thresholding settings
errorThreshold=50; % Discard time points above this pupil fit error
badGazeThreshold=300; % Discard time points with gaze values above this

% Discover user name and find the Dropbox directory
[~, userName] = system('whoami');
userName = strtrim(userName);
dropBoxRoot = ...
    fullfile('/Users', userName, ...
    '/Dropbox (Aguirre-Brainard Lab)/TOME_analysis');

% List the subjects to be analyzed
subjects={...
    %      'TOME_3001/081916/',...
    %      'TOME_3002/082616/',...
    %      'TOME_3003/091616/',...
    %      'TOME_3004/101416/',...
    %      'TOME_3005/100316/',...
    %      'TOME_3007/101716/',...
    %    'TOME_3009/102516/',...
    'TOME_3008/103116/',...
    'TOME_3011/012017/',...
    'TOME_3012/020317/',...
    'TOME_3013/011117/',...
    'TOME_3014/021717/'};

% Define the parameters of the analysis of each experiment
runAverageFlagSet=[true true false]; % Do we average the data across runs?

experimentNames={'flash','retinotopy','pixar movies'};

runNamesSet{1}={...
    'tfMRI_FLASH_AP_run01_response.mat',...
    'tfMRI_FLASH_PA_run02_response.mat'};

runNamesSet{2}={...
    'tfMRI_RETINO_PA_run01_response.mat',...
    'tfMRI_RETINO_PA_run02_response.mat',...
    'tfMRI_RETINO_AP_run03_response.mat',...
    'tfMRI_RETINO_AP_run04_response.mat'};

runNamesSet{3}={...
    'tfMRI_MOVIE_AP_run01_response.mat',...
    'tfMRI_MOVIE_AP_run02_response.mat',...
    'tfMRI_MOVIE_PA_run03_response.mat',...
    'tfMRI_MOVIE_PA_run04_response.mat'};

% Loop through the experiments
for ee=1:3
    runNames=runNamesSet{ee};
    runAverageFlag=runAverageFlagSet(ee);
    
    for ss=1:length(subjects)
        for rr=1:length(runNames)
            filename=fullfile(dropBoxRoot,'session2_spatialStimuli',subjects{ss},'EyeTracking',runNames{rr});
            if exist(filename, 'file') == 2
                load(filename)
                firstIdx=find(abs(response.timebase)<0.001);
                lastIdx=find(abs(response.timebase-342.1833)<0.001);
                dataLength=length(response.timebase(firstIdx:lastIdx));
                if rr==1
                    if ss==1
                        timebase=response.timebase(firstIdx:lastIdx);
                        if runAverageFlag
                            pupilSizeBySubject=nan(length(timebase),length(subjects),1);
                            gazeXBySubject=nan(length(timebase),length(subjects),1);
                            gazeYBySubject=nan(length(timebase),length(subjects),1);
                        else
                            pupilSizeBySubject=nan(length(timebase),length(subjects),length(runNames));
                            gazeXBySubject=nan(length(timebase),length(subjects),length(runNames));
                            gazeYBySubject=nan(length(timebase),length(subjects),length(runNames));
                        end
                    end
                    pupilSize=nan(length(timebase),length(runNames));
                    gazeX=nan(length(timebase),length(runNames));
                    gazeY=nan(length(timebase),length(runNames));
                    error=nan(length(timebase),length(runNames));
                end
                
                % Load the time-series, mean center, and convert the pupil data
                % to % change units.
                tmp=response.pupilSize(firstIdx:lastIdx);
                pupilSize(:,rr) = (tmp - nanmean(tmp))/nanmean(tmp);
                tmp=response.gazeX(firstIdx:lastIdx);
                gazeX(:,rr)=tmp-nanmean(tmp);
                tmp=response.gazeY(firstIdx:lastIdx);
                gazeY(:,rr)=tmp-nanmean(tmp);
                error(:,rr)=response.pupilError(firstIdx:lastIdx);
                
                % Clean the data to nan values with pupilFit error of greater
                % than threshold units
                badIdx=error(:,rr)> errorThreshold;
                pupilSize(badIdx,rr)=nan;
                gazeX(badIdx,rr)=nan;
                gazeY(badIdx,rr)=nan;
                
                % Clean the data within 2 sample units if the absolute gaze
                % value is above the badGazeThresold
                badIdx=(abs(gazeX(:,rr))> badGazeThreshold) | (abs(gazeY(:,rr))> badGazeThreshold);
                for x=-2:1:2
                    pupilSize(circshift(badIdx,x),rr)=nan;
                    gazeX(circshift(badIdx,x),rr)=nan;
                    gazeY(circshift(badIdx,x),rr)=nan;
                end
                
                % Clean the data to nan data values within 5 sample units of a
                % blink (detected as a nan value in the raw pupil size series)
                badIdx=isnan(pupilSize(:,rr));
                for x=-5:1:5
                    pupilSize(circshift(badIdx,x),rr)=nan;
                    gazeX(circshift(badIdx,x),rr)=nan;
                    gazeY(circshift(badIdx,x),rr)=nan;
                end
                
            else % check for the existence of the file
                fprintf('Missing scan\n');
            end
            
        end % loop over runs
        
        % Average across the runs if called for
        if runAverageFlag
            pupilSize=nanmean(pupilSize,2);
            gazeX=nanmean(gazeX,2);
            gazeY=nanmean(gazeY,2);
        end
        
        pupilSizeBySubject(:,ss,:)=pupilSize;
        gazeXBySubject(:,ss,:)=gazeX;
        gazeYBySubject(:,ss,:)=gazeY;
        
    end % loop over subjects
    
    avgPupil=nanmean(pupilSizeBySubject,2);
    semPupil=nanstd(pupilSizeBySubject,1,2)/sqrt(length(subjects));
    avgGazeX=nanmean(gazeXBySubject,2);
    stdGazeX=nanstd(gazeXBySubject,1,2);
    semGazeX=nanstd(gazeXBySubject,1,2)/sqrt(length(subjects));
    avgGazeY=nanmean(gazeYBySubject,2);
    semGazeY=nanstd(gazeYBySubject,1,2)/sqrt(length(subjects));
    figHandle=figure();
    if runAverageFlag
        plotRows=1;
        plotTitle={'Across run / subject average [±sem subject]'};
    else
        plotRows=length(runNames);
        plotTitle=runNames;
    end
    for pp=1:plotRows
        subplot(plotRows,2,pp*2-1);
        shadedErrorBar(timebase,medfilt1(avgGazeX(:,1,pp),100,'truncate'),medfilt1(semGazeX(:,1,pp),100,'truncate'),'-k',0.25)
        ylim([-300 300]);
        xlim([0 350]);
        xlabel('time [seconds]');
        ylabel('gaze position [mm]');
        title(plotTitle{pp},'Interpreter', 'none');
        pbaspect([2,1,1]);
        subplot(plotRows,2,pp*2);
        shadedErrorBar(timebase,nanfastsmooth(avgPupil(:,1,pp),50,3,1),nanfastsmooth(semPupil(:,1,pp),50,3,1),'-r',0.25)
        pbaspect([2,1,1]);
        ylim([-0.5 0.5]);
        xlim([0 350]);
        xlabel('time [seconds]');
        ylabel('% \Delta pupil diameter');
        title(plotTitle{pp},'Interpreter', 'none');
    end % plot the figures in rows
    figtitle(experimentNames{ee});
end % loop over experiments