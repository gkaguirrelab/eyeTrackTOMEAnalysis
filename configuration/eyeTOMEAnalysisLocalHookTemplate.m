function eyeTOMEAnalysisLocalHook
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

%% Say hello
fprintf('* Running eyeTOMEAnalysisLocalHook...');

%% Set preferences

% Find the project directory, add it to the path, save this as a
%  pref, and then make this the current directory
projectDir = fullfile(tbLocateProject('eyeTOMEAnalysis'));
addpath(genpath(projectDir));
setpref('eyeTOMEAnalysis', 'projectDir', projectDir);

