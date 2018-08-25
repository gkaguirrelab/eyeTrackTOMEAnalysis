function alignTimebaseWithLTData(timebaseFileName,glintFileName,ltReportFileName,varargin)
% Adjust the pupil and glint timebase to match scanner timing
%
% Description:
%   this function is to be used with the LiveTrack+VTop setup and assignes
%   a timebase to the raw data by aligning the tracked glint position
%   obtained with the livetrack (which includes the TR times information)
%   and the tracked glint position obtained with the custom tracking
%   algorithm. Note that this step is only necessary because raw data
%   acquired with the LiveTrack+VTop setup lacks syncing information with
%   the scanner TRs.
%   As the X glint position is on average the best tracking results that
%   the livetrack algorithm can provide, we cross-correlate that timeseries
%   with our own tracked glint X position and determine the delay (in
%   frames) between the start of the datastream from the VTop device with
%   respect to the LiveTrack datastream.
%
%   Note that if no TR information is found in the LiveTrack Report file
%   (i.e. for anatomical runs), the alignment with the scanner data is not
%   possible.
%
% Input (required)
%   glintFileName       - full path to the matFile with the glint tracking
%                         results.
%   ltReportFileName    - full path to the livetrack generated "report file"
%
% Optional key/value pairs (analysis)
%   'timebaseFileName'  - full path to the file that will contain the
%                         timebase information.
%   'maxLag'            - max lag allowed between the two glint timeseries
%   'numTRs'            - number of expeted TR for this run. This is used
%                         only for sanity check purposes. In principle,
%                         just a single TTL syncing signal is enough to
%                         align a full run.
%   'rawVidFrameRate'   - framerate of the raw video in units of frames per
%                         second (fps).
%   'ltDataThreshold'   - threshold to clean up the livetrack signal before
%                         cross correlation.
%   'reportSanityCheck' - if true, a sanity check on the livetrack report
%                         will be performed before starting the alignment.
%                         The sanity check verifies that the livetrack
%                         framecount is progressive and that the registered
%                         TR correspond to the expected amount.
%   'plotAlignment'     - if set to true, a plot to verify the alignement
%                         will be generated.
%
% Optional key/value pairs (environment)
%  'tbSnapshot'         - This should contain the output of the
%                         tbDeploymentSnapshot performed upon the result
%                         of the tbUse command. This documents the state
%                         of the system at the time of analysis.
%  'timestamp'          - AUTOMATIC; The current time and date
%  'username'           - AUTOMATIC; The user
%  'hostname'           - AUTOMATIC; The host
%
% Output
%	timebase            - structure with fields that contain the timebase
%                         information in milliseconds, and a meta field.
%
% Examples:
%{
    glintFileName='/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session1_restAndStructure/TOME_3003/090216/EyeTracking/rfMRI_REST_AP_run01_glint.mat';
    timebaseFileName='/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session1_restAndStructure/TOME_3003/090216/EyeTracking/rfMRI_REST_AP_run01_timebase.mat';
    ltReportFileName='/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_data/session1_restAndStructure/TOME_3003/090216/EyeTracking/rfMRI_REST_AP_run01_report.mat';
    alignTimebaseWithLTData(timebaseFileName,glintFileName,ltReportFileName);
%}

%% input parser

p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('timebaseFileName',@ischar);
p.addRequired('glintFileName',@ischar);
p.addRequired('ltReportFileName',@ischar);

% Optional analysis parameters
p.addParameter('maxLag',500, @isnumeric);
p.addParameter('deinterlaceFlag',true,@islogical);
p.addParameter('ltDataThreshold',0.1, @isnumeric);
p.addParameter('savePlot',true, @islogical);
p.addParameter('fixedFrameDelay',[],@(x)(isempty(x) | isnumeric(x)));

% Optional display and I/O parameters
p.addParameter('verbosity','none', @ischar);

% Environment parameters
p.addParameter('tbSnapshot',[],@(x)(isempty(x) | isstruct(x)));
p.addParameter('timestamp',char(datetime('now')),@ischar);
p.addParameter('username',char(java.lang.System.getProperty('user.name')),@ischar);
p.addParameter('hostname',char(java.net.InetAddress.getLocalHost.getHostName),@ischar);

% parse
p.parse(timebaseFileName,glintFileName,ltReportFileName, varargin{:})


%% load data
try
    dataLoad = load(timebaseFileName);
    timebase = dataLoad.timebase;
    clear dataLoad
    dataLoad = load(glintFileName);
    glintData = dataLoad.glintData;
    clear dataLoad
    dataLoad = load(ltReportFileName);
    liveTrack.Report = dataLoad.Report;
    clear dataLoad
catch
    fprintf('One or more identified files are not available.\n');
    return
end

%% get the deltaT
tmpDiff = diff(timebase.values);
deltaT = tmpDiff(1);


%% Prepare data for alignment
% pick the right livetrack sampling data, based on whether the raw video
% was deinterlaced
if p.Results.deinterlaceFlag
    % use all Report samples
    ct = 0;
    for ii = 1:length(liveTrack.Report)
        % First field
        ct = ct + 1;
        ltSignal(ct) = liveTrack.Report(ii).Glint1CameraX_Ch01;
        allTTLs(ct) = liveTrack.Report(ii).Digital_IO1;
        % Second field
        ct = ct + 1;
        ltSignal(ct) = liveTrack.Report(ii).Glint1CameraX_Ch02;
        allTTLs(ct) = liveTrack.Report(ii).Digital_IO2;
    end
else
    % average the two channels, output is at 30Hz
    ltSignal = mean([[liveTrack.Report.Glint1CameraX_Ch01];...
        [liveTrack.Report.Glint1CameraX_Ch02]]);
    % Just use channel one
    allTTLs = liveTrack.Report.Digital_IO1;
end

% extract glint X position
glintSignal = glintData.X;

%% Cross correlate the signals to compute the delay
% cross correlation doesn't work with NaNs, so we change them to zeros
ltCorr = ltSignal;
glintCorr = glintSignal;
ltCorr(isnan(ltSignal)) = 0;
glintCorr(isnan(glintSignal)) = 0;

% set vectors to be the same length (zero pad the END of the shorter one)
if length(glintCorr) > length(ltCorr)
    ltSignal = [ltSignal,zeros(1,(length(glintCorr) - length(ltCorr)))];
    ltCorr = [ltCorr,zeros(1,(length(glintCorr) - length(ltCorr)))];
else
    glintSignal = [glintSignal; zeros((length(ltCorr) - length(glintCorr)),1)];
    glintCorr = [glintCorr; zeros((length(ltCorr) - length(glintCorr)),1)];
end

if isempty(p.Results.fixedFrameDelay)
    % calculate cross correlation and lag array
    [r,lag]  = xcorr(ltCorr,glintCorr,p.Results.maxLag);
    
    % when cross correlation of the signals is max the lag equals the delay
    [~,I] = max(r);
    delay = lag(I); % unit = [number of samples]
    delay = max([delay 0]);
else
    delay = p.Results.fixedFrameDelay;
end

% shift the signals by the 'delay' and replace the nans
ltAligned = ltSignal; % lt is not shifted
ltAligned(ltAligned==0) = nan;
glintAligned = [zeros(delay,1);glintSignal(1:end-delay)];
glintAligned(glintAligned==0) = nan;

% The corrected timebase is aligned with the LT timeseries, and has the
% first TTL set as time zero
firstTTLframe = find(allTTLs,1);
timebase.values = timebase.values + (delay - firstTTLframe)*deltaT;

% Add the TTLs
timebase.TTLs = zeros(size(timebase.values));
timebase.TTLs(find(allTTLs)-delay)=1;

% Add meta data
timebase.meta.alignTimebaseWithLTData = p.Results;
timebase.meta.alignTimebaseWithLTData.delayInFrames = delay;
save(timebaseFileName,'timebase');

%% Save a plot of the cross correlation results for quick review
if p.Results.savePlot
    
    figH = figure('visible','off');
    set(gcf,'PaperOrientation','landscape');
    set(figH, 'Units','inches')
    height = 6;
    width = 18;
    set(figH, 'Position',[25 5 width height],...
        'PaperSize',[width height],...
        'PaperPositionMode','auto',...
        'Color','w',...
        'Renderer','painters'...
        );
    
    % before alignment
    subplot(2,1,1)
    plot(ltSignal - nanmedian(ltSignal), 'b', 'LineWidth',1);
    hold on;
    plot(glintSignal - nanmedian(glintSignal), 'r', 'LineWidth',1)
    grid on
    ylabel('glint X (zero centered)')
    xlabel('Frames (first quarter of the video)')
    ylim([-50 50])
    xlim([0 length(ltSignal)/4])
    legend ('liveTrack','transparentTrack')
    title ('Before alignment')
    % after alignment
    subplot(2,1,2);
    plot(ltAligned - nanmedian(ltAligned), 'b', 'LineWidth',1);
    hold on;
    plot(glintAligned - nanmedian(glintAligned), 'r','LineWidth',1)
    grid on
    ylabel('glint X (zero centered)')
    xlabel('Frames (first quarter of the video)')
    ylim([-50 50])
    xlim([0 length(ltSignal)/4])
    legend ('liveTrack','transparentTrack')
    title(['After alignment (shift = ' num2str(delay) ' frames)']);
    
    % save figure
    timebasePlotName = [p.Results.timebaseFileName(1:end-4) '_QA.pdf'];
    saveas(figH,timebasePlotName)
    close(figH)
    
end



end % main function
