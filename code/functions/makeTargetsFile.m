function makeTargetsFile(targetsInfoFile,targetsFileName,varargin)
% prepares the targets file for gaze calibration)
% 
% Description:
%  This routine will extract the information about the location and timing
%  of the target during the fixation task necessary for gaze calibration.
% 
%  Notes on the gaze calibration file:
%  In the LiveTrack+VTop configuration there are 2 available gaze
%  calibration file types:
%  'livetrack'   - when the file is  generated by the standard LiveTrack
%                  calibration routine; this file has a variable lenght of
%                  target onset time (3-20 sec), depending on the ability
%                  of the LiveTrack to ensure good tracking for each target
%                  location. The LiveTrack calibration routine will provide
%                  NaN if the eye is not correctly tracked within 20
%                  seconds. No more that 1 NaN target is allowed to
%                  correctly build a target file.
%  '3secTarget'  - in case the LiveTrack standard calibration failed during
%                  data acquisition and the gaze calibration data in the
%                  format of the "3 second target" method, in which the
%                  target is presented for a fixed amount of time,
%                  regardless of the ability of the Livetrack to track the
%                  eye.
% 
% Input (required)
%  targetsInfoFile        - name of the file containing targets information
%  targetsFileName        - name of the targets file for saving the output
% 
% Optional key/value pairs (analysis)
%  'targetsInfoFileType' - type of file from which to pull the target
%                          info. If the file was generated by the standard
%                          LiveTrack calibration routine, input
%                          'livetrack'. If the calibration was acquired
%                          using the 3 second targets method, input
%                          '3secTarget'
%  'targetsLayout'       - description of the target layout. Currently
%                          only '3x3grid' option available
%  'viewingDistanceMm'   - frameRate of the raw video data
%  'targetsPositionUnits'- units in which the target position is expressed
% 
%
% Optional key/value pairs (display and I/O)
%  'verbosity'           - level of verbosity. [none, full]
%
% Optional key/value pairs (environment)
%  'tbSnapshot'          - This should contain the output of the
%                          tbDeploymentSnapshot performed upon the result
%                          of the tbUse command. This documents the state
%                          of the system at the time of analysis.
%  'timestamp'           - AUTOMATIC; The current time and date
%  'username'            - AUTOMATIC; The user
%  'hostname'            - AUTOMATIC; The host
% 
% Output (saved to file)
%   targets              - struct containing the following target info
%                               X
%                               Y
%                               sysClockSecsOnsets
%                               sysClockSecsOffsets
%                               viewingDistanceMm
%                               meta
% 

%% input parser

p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('LTdatFileName',@ischar);
p.addRequired('gazeDataFileName',@ischar);

% Optional analysis parameters
p.addParameter('targetsInfoFileType','LiveTrack', @ischar) % alternative '3secTarget'
p.addParameter('viewingDistanceMm', 1065, @isnumeric)
p.addParameter('targetsPositionUnits','mmOnScreen',@ischar);
p.addParameter('targetsLayout','3x3grid',@ischar);

% Optional display and I/O parameters
p.addParameter('verbosity','none', @ischar);

% Environment parameters
p.addParameter('tbSnapshot',[],@(x)(isempty(x) | isstruct(x)));
p.addParameter('timestamp',char(datetime('now')),@ischar);
p.addParameter('username',char(java.lang.System.getProperty('user.name')),@ischar);
p.addParameter('hostname',char(java.net.InetAddress.getLocalHost.getHostName),@ischar);

% parse
p.parse(targetsInfoFile,targetsFileName,varargin{:})


%% load the target info file
targetsInfo = load(targetsInfoFile);


%% pull the target data according to the type of target info file
switch p.Results.targetsInfoFileType
    case 'LiveTrack'
        targets.X = targetsInfo.targets(:,1); % mm on screen, screen center = 0
        targets.Y = targetsInfo.targets(:,2); % mm on screen, screen center = 0
        
        % if the livetrack failed to track one target, it will be a NaN. Replace
        % the NaN with the missing target location. NOTE THAT THIS ASSUMES THAT
        % ONLY ONE TARGET IS MISSING
        
        nanIDX = find(isnan(targets.X));
        if ~isempty(nanIDX)
            if length(nanIDX) > 1
                error ('There is more than one NaN target! Calibration might fail.')
            end
            % available targets locations
            highTRG = max(targetsInfo.targets(:,1));
            centerTRG = 0;
            lowTRG = min(targetsInfo.targets(:,1));
            
            allLocations = [...
                highTRG highTRG; ...
                highTRG centerTRG; ...
                highTRG lowTRG; ...
                centerTRG highTRG; ...
                centerTRG centerTRG; ...
                centerTRG lowTRG; ...
                lowTRG highTRG; ...
                lowTRG centerTRG; ...
                lowTRG lowTRG; ...
                ];
            
            % find value of the nan target (is the one missing when comparing the
            % targets to allLocations)
            missingTarget = find(~ismember(allLocations,[targets.X targets.Y], 'rows'));
            
            % replace NaN target value with missing value
            targets.X(nanIDX) = allLocations(missingTarget, 1);
            targets.Y(nanIDX) = allLocations(missingTarget, 2);
        end
        
        % get dot times (if available)
        if isfield(targetsInfo,'dotTimes')
            targets.sysClockSecsOnsets = targetsInfo.dotTimes(1:end-1)';
            targets.sysClockSecsOffsets = targetsInfo.dotTimes(2:end)';
        end
        
        
    case '3secTarget'
        % get targets location
        targets.X     = targetsInfo.targets(:,1); % mm on screen, screen center = 0
        targets.Y     = targetsInfo.targets(:,2); % mm on screen, screen center = 0
           
        % get targets times
        targets.sysClockSecsOnsets = targetsInfo.dotTimes(1:end-1)';
        targets.sysClockSecsOffsets = targetsInfo.dotTimes(2:end)';
        
    otherwise
        error('Unknown targetsInfoFileType')
end


% get viewing distance and layout
targets.viewingDistanceMm = p.Results.viewingDistanceMm;

%% add a meta field and save out the results

targets.meta = p.Results;

save(targetsFileName,'targets');
