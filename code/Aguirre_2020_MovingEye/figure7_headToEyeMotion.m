
% Plot the brain motion and eye motion parametes for

brainMotionStem = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_analysis/deriveCameraPositionFromHeadMotion/session2_spatialStimuli/';
eyeMotionStem = '/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session2_spatialStimuli/';

% The stage of pupil fitting that we will plot
fitStage = 'sceneConstrained';

%% Make some plots for an example subject
% TOME_3029, movie run 2

% Load the brain movement files for this subject
brainMotionFile = fullfile(brainMotionStem,'TOME_3029_tfMRI_MOVIE_AP_run2_Movement_Regressors.txt');
brainMotion = readmatrix(brainMotionFile);

% Reference the brainMotion to time zero
brainMotion = brainMotion - brainMotion(1,:);

% Create a timebase for the brain motion
nTRs = size(brainMotion,1);
timebaseBrain = 0:0.8:(nTRs-1)*0.8;

% Plot the brain translation
figHandle1 = figure('Position', [10 10 600 300]);
tiledlayout(2,1);

nexttile
colors = {[0.5 0.5 1],[1 0.5 0.5],[0.5 0.5 0.5]};
for tt = 1:3
    plot(timebaseBrain,brainMotion(:,tt),'.','Color',colors{tt})
    hold on
end
legend({'RL','AP','IS'},'Location','northwest');
ylim([-0.5 0.5]);
ylabel('displacement [mm]');
xlabel('time [secs]');

nexttile
colors = {[1 0.5 0.5],[0.5 0.5 0.5],[0.5 0.5 1]};
for tt = 1:3
    plot(timebaseBrain,brainMotion(:,tt+3),'.','Color',colors{tt})
    hold on
end
legend({'pitch','roll','yaw'},'Location','northwest');
ylim([-1 1]);
ylabel('displacement [deg]');
xlabel('time [secs]');

fileName = ['~/Desktop/Figure7_headMotionExample.pdf'];
saveas(figHandle1,fileName);
close(figHandle1);



% Load the relativeCameraPosition and glint files
load(fullfile(eyeMotionStem,'TOME_3029/120617/EyeTracking/tfMRI_MOVIE_AP_run02_relativeCameraPosition.mat'))
load(fullfile(eyeMotionStem,'TOME_3029/120617/EyeTracking/tfMRI_MOVIE_AP_run02_glint.mat'))
load(fullfile(eyeMotionStem,'TOME_3029/120617/EyeTracking/tfMRI_MOVIE_AP_run02_pupil.mat'))
load(fullfile(eyeMotionStem,'TOME_3029/120617/EyeTracking/tfMRI_MOVIE_AP_run02_timebase.mat'))

% Find the timebaseEye vector that is bounded by the TRs of the scan, at
% the scan resolution
[~,startFrame] = min(abs(timebase.values));
[~,endFrame] = min(abs(timebase.values-timebaseBrain(end)*1000));
timebaseEye = timebase.values/1000;

% Identify the bad frames as those without a glint, non-uniform perimeters,
% or bad ellipse fits (startFrame:endFrame)
clear testSet
testSet(1,:) = isnan(glintData.X);
testSet(2,:) = pupilData.(fitStage).ellipses.RMSE > 2;
testSet(3,:) = pupilData.radiusSmoothed.ellipses.uniformity < 0.75;
goodFrames = ~(testSet(1,:)|testSet(2,:)|testSet(3,:));

eyeFramesPerBrainFrame = 800/(timebase.values(2)-timebase.values(1));
eyeFrameIdx = round(startFrame:eyeFramesPerBrainFrame:(nTRs-1)*eyeFramesPerBrainFrame+startFrame);
eyeFrameIdxGood = eyeFrameIdx(goodFrames(eyeFrameIdx));


figHandle2 = figure('Position', [10 10 600 300]);

% Decide on the three dimensions of color
colors = {[0.5 0.5 1],[0.5 0.5 0.5],[1 0.5 0.5]};

for tt = 1:3
    plot(timebaseBrain,relativeCameraPosition.initial.values(tt,eyeFrameIdx),'.','Color',colors{tt})
    hold on
    if tt==3
        plot(timebaseEye(startFrame:endFrame),relativeCameraPosition.initial.values(3,startFrame:endFrame),'-','Color',colors{tt})
    end
end
legend({'+right','+up','+further'},'Location','northwest');
ylim([-2 2]);
xlim([0 360]);
ylabel('displacement [mm]');
xlabel('time [secs]');

fileName = ['~/Desktop/Figure7_eyeMotionExample.pdf'];
saveas(figHandle2,fileName);
close(figHandle2);





figHandle3 = figure('Position', [10 10 600 300]);
sColors = {[0 0 1],[0 0 0]};
for tt = 1:2
    
    h=scatter(timebaseBrain,relativeCameraPosition.initial.values(tt,eyeFrameIdx),5,sColors{tt});
    h.MarkerFaceAlpha = 0.15;
    h.MarkerEdgeAlpha = 0.25;
    h.MarkerEdgeColor = sColors{tt};
    h.MarkerFaceColor = [0 0 0];
    hold on
    
    meanDisplace = mean(relativeCameraPosition.initial.values(tt,eyeFrameIdx));
    yVals = relativeCameraPosition.(fitStage).values(tt,:);
    yVals = yVals - nanmean(yVals) + meanDisplace;
    p=plot(timebaseEye(goodFrames),yVals(goodFrames),'-','Color',sColors{tt},'LineWidth',0.5);
    %    p.Color(4) = 0.5;
    
    y1 = relativeCameraPosition.estimateSceneParams.values(tt,eyeFrameIdxGood);
    y2 = relativeCameraPosition.(fitStage).values(tt,eyeFrameIdxGood);
    
    corr(y1',y2','Rows','complete')
    
end
ylim([-2 2]);
xlim([0 360]);
ylabel('displacement [mm]');
xlabel('time [secs]');


fileName = ['~/Desktop/Figure7_fittedEyeMotionExample.pdf'];
saveas(figHandle3,fileName);
close(figHandle3);


%% Loop through all the subjects
% Summarize the correlation of head and eye motion


%% Obtain the scene analysis parameters
[videoStemName, frameSet, gazeTargets, eyeArgs, sceneArgs, torsDepth, kvals] = defineSubjectSceneParams_CrossValidation;

aziCorr = nan(45,4);
eleCorr = nan(45,4);
aziRange = nan(45,4);
eleRange = nan(45,4);
respRate = nan(45,4);
respR2 = nan(45,5);

movieFileNames = {'tfMRI_MOVIE_AP_run01','tfMRI_MOVIE_AP_run02','tfMRI_MOVIE_PA_run03','tfMRI_MOVIE_PA_run04'};

%% Loop over the subjectIdx

% Define some anonymous functions for fitting a Gaussian
fun=@(x,scale,mu,sd) scale/sqrt(2*pi*sd^2)*exp(-(x-mu).^2/(2*sd^2));

for ss = 1:45
    
    
    %% If there is nothing in the cell array for this subject, continue
    if isempty(videoStemName{ss})
        continue
    end
    
    
    %% Loop over the movie runs
    for mm = 1:4
        tmp=strsplit(videoStemName{ss}{mm},filesep);
        fileStem=fullfile(filesep,tmp{1:end-1},[movieFileNames{mm}]);
        
        if isfile([fileStem '_relativeCameraPosition.mat'])
            
            % Load the relativeCameraPosition and glint files
            load([fileStem '_relativeCameraPosition.mat'])
            load([fileStem '_glint.mat'])
            load([fileStem '_pupil.mat'])
            load([fileStem '_timebase.mat'])
            
            % Find the timebaseEye vector that is bounded by the TRs of the scan, at
            % the scan resolution
            [~,startFrame] = min(abs(timebase.values));
            [~,endFrame] = min(abs(timebase.values-timebaseBrain(end)*1000));
            timebaseEye = timebase.values/1000;
            
            % Identify the bad frames as those without a glint, non-uniform perimeters,
            % or bad ellipse fits (startFrame:endFrame)
            clear testSet
            testSet(1,:) = isnan(glintData.X);
            testSet(2,:) = pupilData.(fitStage).ellipses.RMSE > 2;
            testSet(3,:) = pupilData.radiusSmoothed.ellipses.uniformity < 0.75;
            testSet(4,:) = isnan(relativeCameraPosition.(fitStage).values(1,:));
            goodFrames = ~(testSet(1,:)|testSet(2,:)|testSet(3,:)|testSet(4,:));
            
            eyeFrameIdxGood = eyeFrameIdx(goodFrames(eyeFrameIdx));
            
            % Get the correlation and range for horizontal eye position
            if ~isempty(eyeFrameIdxGood)
                if length(eyeFrameIdxGood)>(0.25 * length(eyeFrameIdx))
                    y1 = relativeCameraPosition.initial.values(1,eyeFrameIdxGood);
                    y2 = relativeCameraPosition.(fitStage).values(1,eyeFrameIdxGood);
                    aziCorr(ss,mm) = corr(y1',y2','Rows','complete');
                    aziRange(ss,mm) = range(y1);
                    
                    % Get the correlation and range for horizontal eye position
                    y1 = relativeCameraPosition.initial.values(2,eyeFrameIdxGood);
                    y2 = relativeCameraPosition.(fitStage).values(2,eyeFrameIdxGood);
                    eleCorr(ss,mm) = corr(y1',y2','Rows','complete');
                    eleRange(ss,mm) = range(y1);
                    
                    %{
                    % Get the one-sided PSD of the full resolution data
                    x = timebase.values(goodFrames);
                    y = relativeCameraPosition.(fitStage).values(2,goodFrames);
                    evenStop = floor(length(x)/2)*2;
                    [psd, psdSupport] = calcOneSidedPSD( y(1:evenStop), x(1:evenStop) );

                    % Fit a Gaussian to the response in the range of 0.1 to
                    % 0.5 Hz and see if there is a respiratory signal.
                    [~,freqStart] = min(abs(psdSupport-0.1));
                    [~,freqStop] = min(abs(psdSupport-0.5));
                    x = psdSupport(freqStart:freqStop);
                    y = psd(freqStart:freqStop);
                    [maxY,idx]=max(y);
                    myObj = @(p) norm(y - fun(x,p(1),p(2),p(3)));
                    p = fminsearch(myObj,[maxY x(idx) 0.1]);
                    respRate(ss,mm) = p(2);
                    respR2(ss,mm) = corr(y',fun(x,p(1),p(2),p(3))');
                    %}
                    
                end
            end            
        end
    end
end



% Plot the relationship between head movement range and accuracy of recover
% of head movement
figHandle4 = figure('Position', [10 10 300 300]);

% Create a reciprocal fit line
myFit = @(x,p) 1 - p(1)./(x+p(2))+p(3);

x = [eleRange(:); aziRange(:)];
x = x(~isnan(x));
y = [eleCorr(:); aziCorr(:)];
y = y(~isnan(y));
myObj = @(p) norm(y - myFit(x,p),1)+sum(myFit(x,p)>1);
p=fminsearch(myObj,[0 0 0]);
xFit = min(x):0.01:max(x);
yFit = myFit(xFit,p);
plot(xFit,yFit,'-','Color',[1 0.25 0.25],'LineWidth',3);
ylim([-0.25 1.1]);
xlim([-0.25 5.5]);
xlabel('Range of movement [mm]');
ylabel('Correlation of brain with camera');
hold on

sColors = {[0 0 1],[0 0 0]};

scatter(eleRange(:),eleCorr(:),100,'o', ...
    'MarkerEdgeColor', sColors{2}, ...
    'MarkerEdgeAlpha', 0.25, ...
    'MarkerFaceAlpha', 0.15, ...
    'MarkerFaceColor', sColors{2});
scatter(aziRange(:),aziCorr(:),100,'o', ...
    'MarkerEdgeColor', sColors{1}, ...
    'MarkerEdgeAlpha', 0.25, ...
    'MarkerFaceAlpha', 0.15, ...
    'MarkerFaceColor', sColors{1});

% Make the 3029 example scan prominen
scatter(eleRange(29,2),eleCorr(29,2),100,'o', ...
    'MarkerEdgeColor', [1 0.25 0.25], ...
    'MarkerEdgeAlpha', 1, ...
    'LineWidth',1.5,...
    'MarkerFaceAlpha', 0.25, ...
    'MarkerFaceColor', sColors{2});
scatter(aziRange(29,2),aziCorr(29,2),100,'o', ...
    'MarkerEdgeColor', [1 0.25 0.25], ...
    'MarkerEdgeAlpha', 1, ...
    'LineWidth',1.5,...
    'MarkerFaceAlpha', 0.25, ...
    'MarkerFaceColor', sColors{1});


fileName = ['~/Desktop/Figure7_rangeVsCorrelation.pdf'];
saveas(figHandle4,fileName);
close(figHandle4);

