function contour = GERT_GenerateContour_FileTXT(fname,closed,delimiter)

% contour = GERT_GenerateContour_FileTXT(fname,closed,delimiter)
%
% DESCRIPTION:
%  This function reads in a file FNAME consisting of XY coordinates, one 
%  pair per line, delimited by a DELIMITER (default: space). The coordinates
%  need to be continuous along the contour, and the user should specify
%  whether the contour is to be regarded as CLOSED or not. The XY
%  coordinates should be in the first two columns, other columns will be
%  ignored.
%
% ARGUMENTS:
%  fname --------------------- required
%                              1xN char
%                              Valid file in the Matlab path
%
%  closed -------------------- optional, default: false
%                              1x1 logical
%             
%  delimiter ----------------- optional, default: ' '
%                              1xN char
%                              Valid delimiter to the 'textread' function
%
% RETURNS:
%  contour ------------------- 1x1 GContour
%
% DETAILS:
%  None.
%
% EXAMPLE: 
%  % Closed contour, space delimited
%  contour = GERT_GenerateContour_FileTXT('bear.txt',true,' ');
%
%
% ---
% Authors:  Maarten Demeyer (maarten.demeyer@ppw.kuleuven.be)
%           Bart Machilsen (bart.machilsen@ppw.kuleuven.be)
%
% From:     University of Leuven (K.U. Leuven)
%           Laboratory of Experimental Psychology
%           Leuven, BELGIUM
%
% This function is part of GERT, the Grouping Elements Rendering Toolbox
% Find GERT at: http://www.gestaltrevision.be/GERT/
%

GERT_Init;

%% Check arguments
fnc_name = 'GERT_GenerateContour_FileTXT';

% One to three arguments required
if nargin < 1 || nargin > 3
    msg = 'One to three input arguments required';
    GERT_ShowError(fnc_name,msg,3);
end

% 'fname' - required
if ~GERT_Aux_ValidVec(fname,'char')
    msg = 'Input argument ''fname'' must be a 1xN char';
    GERT_ShowError(fnc_name,msg,3);
end

if ~exist(fname,'file')
   msg = 'File could not be found';
   GERT_ShowError(fnc_name,msg,3);
end

% 'closed' - optional
if ~exist('closed','var')
    closed = false;
end

if ~isa(closed,'logical') || ~isscalar(closed)
     msg = 'Input argument ''closed'' must be a 1x1 logical';
     GERT_ShowError(fnc_name,msg,3);
end

% 'delimiter' - optional
if ~exist('delimiter','var')
    delimiter = ' ';
end

if ~ischar(delimiter) || size(delimiter,1)~=1 || size(delimiter,2)<1 || ndims(delimiter)~=2
    msg = 'Input argument ''delimiter'' must be a 1xN char';
    GERT_ShowError(fnc_name,msg,3);
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',fname,'IN_fname');
GERT_log = add(GERT_log,'var',closed,'IN_closed');
GERT_log = add(GERT_log,'var',delimiter,'IN_delimiter');
GERT_log = add(GERT_log,'file',fname, fname);

%% Read in the contour
global GERT_matlv;
contour = GContour;

if strcmp(GERT_matlv{1},'Matlab')
    [tmp{1:2}] = textread(deblank(fname),'%n%n%*[^\n]','delimiter',delimiter);
else
    [tmp{1} tmp{2}] = textread(which(fname),['%d' delimiter '%d']);
end
contour.x = double(tmp{1}');
contour.y = double(tmp{2}');
contour.closed = closed;
clear tmp;

%% Validate and compute properties
contour = rmid(contour);
contour = compute_cdist(contour);
contour = compute_lt(contour);
contour = validate(contour);

GERT_log = add(GERT_log,'var',contour,'OUT_contour');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done