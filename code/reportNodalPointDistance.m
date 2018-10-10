function reportNodalPointDistance( dataRootDir, varargin )
% Calculates the nodal point distance for a set of scene geometries
%
% Syntax:
%  reportNodalPointDistance( dataRootDir )
%
% Description:
%   Given a directory, the routine will perform a recursive search through
%   sub-directories to find all files with the suffix "_sceneGeometry.mat".
%   Each of these files will be loaded, and the "eye" field of the
%   structure used to calculate the distance of the effective nodal point
%   of the eye from the posterior apex of the retina. These values are then
%   reported to the console.
%
%   Included local functions are subdir, by Kelly Kearney, and suptitle,
%   which is a MATLAB helper function.
%
% Inputs:
%   dataRootDir           - Full path to a directory that contains pupil
%                           data files, and/or subdirectories containing
%                           these files.
%
% Outputs:
%   none
%

%% input parser
p = inputParser;

% Required
p.addRequired('dataRootDir',@ischar);

% parse
p.parse(dataRootDir,varargin{:})


% Obtain the paths to all of the sceneGeometry data files within the
% specified directory, including within sub-drectories.
fileListStruct=subdir(fullfile(dataRootDir,'*_sceneGeometry.mat'));

% If we found at least one sceneGeometry file, then proceed.
if ~isempty(fileListStruct)
    
    % Get a list of the directories that contain a sceneGeometry file. 
    fileListCell=struct2cell(fileListStruct);
    uniqueDirNames=unique(fileListCell(2,:));
    
    % Create a list of name tags that are the unique character components
    % of the uniqueDirNames. We trim off all characters that are shared
    % across the full path of the dir names.
    nameTags = uniqueDirNames;
    stillTrimming = true;
    while stillTrimming
        thisChar=cell2mat(cellfun(@(x) double(x(1)),nameTags,'UniformOutput',false));
        if range(thisChar)==0
            nameTags=cellfun(@(x) x(2:end),nameTags,'UniformOutput',false);
        else
            stillTrimming=false;
        end
    end
    stillTrimming = true;
    while stillTrimming
        thisChar=cell2mat(cellfun(@(x) double(x(end)),nameTags,'UniformOutput',false));
        if range(thisChar)==0
            nameTags=cellfun(@(x) x(1:end-1),nameTags,'UniformOutput',false);
        else
            stillTrimming=false;
        end
    end
    
    % Replace file system delimeters with valid characters. That way, we
    % can use these name tags as filenames for the resulting plots.
    nameTags=cellfun(@(x) strrep(x,filesep,'_'),nameTags,'UniformOutput',false);
        
    % Loop through the set of sessions
    for ii = 1:length(uniqueDirNames)
        
        % Get the list of acqusition file names
        acqList = find(strcmp(fileListCell(2,:),uniqueDirNames{ii}));

        jj=1;
        
        % Obtain the path to this sceneGeometry file and load it
        fullFileName = fullfile(dataRootDir,fileListCell{1,acqList(jj)});
        dataLoad=load(fullFileName);
        sceneGeometry=dataLoad.sceneGeometry;
        clear dataLoad

        % Estimate the effective nodal point
        nodalPointCoord = calcEffectiveNodalPoint(sceneGeometry.eye,'air');
        
        % Obtain the coordinate of the posterior apex of the eye
        vitreousChamberRadii = quadric.radii(sceneGeometry.eye.retina.S);
        posteriorPoleCoord = quadric.center(sceneGeometry.eye.retina.S)-[vitreousChamberRadii(1); 0; 0];
        
        % Obtain Euclidean distance of nodal point from posterior apex
        distance = sqrt(sum((posteriorPoleCoord-nodalPointCoord).^2));
        
        % Report this value
        fprintf(['TOME_30' nameTags{ii} ': %2.2f mm nodal point distance\n'],distance);
    end
end

end % reportNodalPointDistance

%%% LOCAL FUNCTIONS



function hout=suptitleTT(str)
%SUPTITLE puts a title above all subplots.
%
%	SUPTITLE('text') adds text to the top of the figure
%	above all subplots (a "super title"). Use this function
%	after all subplot commands.
%
%   SUPTITLE is a helper function for yeastdemo.

%   Copyright 2003-2014 The MathWorks, Inc.

% Warning: If the figure or axis units are non-default, this
% function will temporarily change the units.

% Parameters used to position the supertitle.

% Amount of the figure window devoted to subplots
plotregion = .92;

% Y position of title in normalized coordinates
titleypos  = .95;

% Fontsize for supertitle
fs = get(gcf,'defaultaxesfontsize')+4;

% Fudge factor to adjust y spacing between subplots
fudge=1;

haold = gca;
figunits = get(gcf,'units');

% Get the (approximate) difference between full height (plot + title
% + xlabel) and bounding rectangle.

if ~strcmp(figunits,'pixels')
    set(gcf,'units','pixels');
    pos = get(gcf,'position');
    set(gcf,'units',figunits);
else
    pos = get(gcf,'position');
end
ff = (fs-4)*1.27*5/pos(4)*fudge;

% The 5 here reflects about 3 characters of height below
% an axis and 2 above. 1.27 is pixels per point.

% Determine the bounding rectangle for all the plots

h = findobj(gcf,'Type','axes');

oldUnits = get(h, {'Units'});
if ~all(strcmp(oldUnits, 'normalized'))
    % This code is based on normalized units, so we need to temporarily
    % change the axes to normalized units.
    set(h, 'Units', 'normalized');
    cleanup = onCleanup(@()resetUnits(h, oldUnits));
end

max_y=0;
min_y=1;
oldtitle = [];
numAxes = length(h);
thePositions = zeros(numAxes,4);
for i=1:numAxes
    pos=get(h(i),'pos');
    thePositions(i,:) = pos;
    if ~strcmp(get(h(i),'Tag'),'suptitle')
        if pos(2) < min_y
            min_y=pos(2)-ff/5*3;
        end
        if pos(4)+pos(2) > max_y
            max_y=pos(4)+pos(2)+ff/5*2;
        end
    else
        oldtitle = h(i);
    end
end

if max_y > plotregion
    scale = (plotregion-min_y)/(max_y-min_y);
    for i=1:numAxes
        pos = thePositions(i,:);
        pos(2) = (pos(2)-min_y)*scale+min_y;
        pos(4) = pos(4)*scale-(1-scale)*ff/5*3;
        set(h(i),'position',pos);
    end
end

np = get(gcf,'nextplot');
set(gcf,'nextplot','add');
if ~isempty(oldtitle)
    delete(oldtitle);
end
axes('pos',[0 1 1 1],'visible','off','Tag','suptitle');
ht=text(.5,titleypos-1,str);set(ht,'horizontalalignment','center','fontsize',fs,'Interpreter', 'none');
%set(gcf,'nextplot',np);
%axes(haold);
if nargout
    hout=ht;
end
end % suptitleTT


function resetUnits(h, oldUnits)
% Reset units on axes object. Note that one of these objects could have
% been an old supertitle that has since been deleted.
valid = isgraphics(h);
set(h(valid), {'Units'}, oldUnits(valid));
end


function varargout = subdir(varargin)
%SUBDIR Performs a recursive file search
%
% subdir
% subdir(name)
% files = subdir(...)
%
% This function performs a recursive file search.  The input and output
% format is identical to the dir function.
%
% Input variables:
%
%   name:   pathname or filename for search, can be absolute or relative
%           and wildcards (*) are allowed.  If ommitted, the files in the
%           current working directory and its child folders are returned
%
% Output variables:
%
%   files:  m x 1 structure with the following fields:
%           name:   full filename
%           date:   modification date timestamp
%           bytes:  number of bytes allocated to the file
%           isdir:  1 if name is a directory; 0 if no
%
% Example:
%
%   >> a = subdir(fullfile(matlabroot, 'toolbox', 'matlab', '*.mat'))
%
%   a =
%
%   67x1 struct array with fields:
%       name
%       date
%       bytes
%       isdir
%
%   >> a(2)
%
%   ans =
%
%        name: '/Applications/MATLAB73/toolbox/matlab/audiovideo/chirp.mat'
%        date: '14-Mar-2004 07:31:48'
%       bytes: 25276
%       isdir: 0
%
% See also:
%
%   dir

% Copyright 2006 Kelly Kearney


%---------------------------
% Get folder and filter
%---------------------------

narginchk(0,1);
nargoutchk(0,1);

if nargin == 0
    folder = pwd;
    filter = '*';
else
    [folder, name, ext] = fileparts(varargin{1});
    if isempty(folder)
        folder = pwd;
    end
    if isempty(ext)
        if isdir(fullfile(folder, name))
            folder = fullfile(folder, name);
            filter = '*';
        else
            filter = [name ext];
        end
    else
        filter = [name ext];
    end
    if ~isdir(folder)
        error('Folder (%s) not found', folder);
    end
end

%---------------------------
% Search all folders
%---------------------------

pathstr = genpath_local(folder);
pathfolders = regexp(pathstr, pathsep, 'split');  % Same as strsplit without the error checking
pathfolders = pathfolders(~cellfun('isempty', pathfolders));  % Remove any empty cells

Files = [];
pathandfilt = fullfile(pathfolders, filter);
for ifolder = 1:length(pathandfilt)
    NewFiles = dir(pathandfilt{ifolder});
    if ~isempty(NewFiles)
        fullnames = cellfun(@(a) fullfile(pathfolders{ifolder}, a), {NewFiles.name}, 'UniformOutput', false);
        [NewFiles.name] = deal(fullnames{:});
        Files = [Files; NewFiles];
    end
end

%---------------------------
% Prune . and ..
%---------------------------

if ~isempty(Files)
    [~, ~, tail] = cellfun(@fileparts, {Files(:).name}, 'UniformOutput', false);
    dottest = cellfun(@(x) isempty(regexp(x, '\.+(\w+$)', 'once')), tail);
    Files(dottest & [Files(:).isdir]) = [];
end

%---------------------------
% Output
%---------------------------

if nargout == 0
    if ~isempty(Files)
        fprintf('\n');
        fprintf('%s\n', Files.name);
        fprintf('\n');
    end
elseif nargout == 1
    varargout{1} = Files;
end

end % subdir

function [p] = genpath_local(d)
% Modified genpath that doesn't ignore:
%     - Folders named 'private'
%     - MATLAB class folders (folder name starts with '@')
%     - MATLAB package folders (folder name starts with '+')

files = dir(d);
if isempty(files)
    return
end
p = '';  % Initialize output

% Add d to the path even if it is empty.
p = [p d pathsep];

% Set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
dirs = files(isdir);  % Select only directory entries from the current listing

for i=1:length(dirs)
    dirname = dirs(i).name;
    if    ~strcmp( dirname,'.') && ~strcmp( dirname,'..')
        p = [p genpath(fullfile(d,dirname))];  % Recursive calling of this function.
    end
end

end % genpath_local
