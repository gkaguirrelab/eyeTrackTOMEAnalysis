function eyeTrackTOMEAnalysisLocalHook
%
% For use with the ToolboxToolbox.  Copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "Template" from the filename
%
% The thing that this does is add subfolders of the project to the path as
% well as define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Define project
projectName = 'eyeTrackTOMEAnalysis';

%% Clear out old preferences
if (ispref(projectName))
    rmpref(projectName);
end


% Obtain the Dropbox path
[~,hostname] = system('hostname');
hostname = strtrim(lower(hostname));

% handle hosts with custom dropbox locations
switch hostname
    case 'seele.psych.upenn.edu'
        dropboxBaseDir = '/Volumes/seeleExternalDrive/Dropbox (Aguirre-Brainard Lab)';
    case 'magi-1-melchior.psych.upenn.edu'
        dropboxBaseDir = '/Volumes/melchiorBayTwo/Dropbox (Aguirre-Brainard Lab)';
    case 'magi-2-balthasar.psych.upenn.edu'
        dropboxBaseDir = '/Volumes/balthasarExternalDrive/Dropbox (Aguirre-Brainard Lab)';
    otherwise
        [~, userName] = system('whoami');
        userName = strtrim(userName);
        dropboxBaseDir = ...
            fullfile('/Users', userName, ...
            'Dropbox (Aguirre-Brainard Lab)');
end

%% Set preferences for project output
setpref(projectName,'dropboxBaseDir',dropboxBaseDir); % main directory path 


%% Set preferences

% Find the project directory, add it to the path, save this as a
%  pref, and then make this the current directory
projectDir = fullfile(tbLocateProject(projectName));
addpath(genpath(projectDir));
setpref(projectName, 'projectDir', projectDir);


%% Check for required Matlab toolboxes
requiredAddOns = {...
    'Mapping Toolbox'...                  % optimization_toolbox
    };
% Given this hard-coded list of add-on toolboxes, we then check for the
% presence of each and issue a warning if absent.
V = ver;
VName = {V.Name};
warnState = warning();
warning off backtrace
for ii=1:length(requiredAddOns)
    if ~any(strcmp(VName, requiredAddOns{ii}))
        warnString = ['The Matlab ' requiredAddOns{ii} ' is missing. ' projectName ' may not function properly.'];
        warning('localHook:requiredMatlabToolboxCheck',warnString);
    end
end
warning(warnState);

end