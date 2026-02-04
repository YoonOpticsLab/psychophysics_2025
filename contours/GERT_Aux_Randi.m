function ri = GERT_Aux_Randi(maxi,dims)

% ri = GERT_Aux_Randi(maxi,dims)
%
% DESCRIPTION:
%  This function will return random integers between 1 and MAXI, in a matrix
%  with dimensions DIMS. It was copied from PsychToolbox and given a custom
%  name to avoid interferences with other functions named 'randi'.
%
% ARGUMENTS:
%  maxi ---------------------- required
%                              1x1 double
%                              >0, integer value, finite, real
%
%  dims ---------------------- optional
%                              1xN double
%                              >0, integer value, finite, real
%
% RETURNS:
%  ri ------------------------ DIMS double
%
% DETAILS:
%  None.
%
% EXAMPLE:
%  None.
%
%
% ---
% Original author:  Denis Pelli (http://psychtoolbox.org)
%
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
fnc_name = 'GERT_Aux_Randi';

% One or two arguments required
if nargin ~= 1 && nargin ~= 2
    msg = 'One or two input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'maxi' - required
if ~GERT_Aux_ValidVec(maxi,'double',1) || mod(maxi,1)~=0 || maxi <1
    msg = 'Input argument ''maxi'' must be an positive integer value 1x1 double.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'dims' - optional
if ~exist('dims','var')
    dims = 1;
elseif ~GERT_Aux_ValidVec(dims,'double') || any(mod(dims(:),1)~=0) || any(dims(:)<1)
    msg = 'Input argument ''dims'' must be a positive integer value 1xN double.';
    GERT_ShowError(fnc_name,msg,3); 
end

%% Generate the random integers
ri = ceil(maxi*rand(dims));

%% All done