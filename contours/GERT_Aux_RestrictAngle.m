function vals = GERT_Aux_RestrictAngle(vals, minv, maxv)

% vals = GERT_Aux_RestrictAngle(vals, minv, maxv)
%
% DESCRIPTION:
%  This function will restrict the values in VALS to lie between MIN and
%  MAX, assuming that multiples of MAX minus MIN are equivalent to one another.
%
% ARGUMENTS:
%  vals ---------------------- required
%                              double
%                              finite, real
%
%  minv ---------------------- required
%                              1x1 double
%                              finite, real
%
%  maxv ---------------------- required
%                              1x1 double
%                              >min, finite, real
%
% RETURNS:
%  vals ---------------------- double
%
% DETAILS:
%  None.
%
% EXAMPLE:
%  None.
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
fnc_name = 'GERT_Aux_RestrictAngle';

% Three arguments required
if nargin ~= 3
    msg = 'Three input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'vals' - required
if ~all(isfinite(vals(:))) || ~isa(vals,'double') || any(imag(vals(:)))
    msg = 'Input argument ''vals'' must be a double.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'minv' - required
if ~GERT_Aux_ValidVec(minv,'double',1)
    msg = 'Input argument ''minv'' must be a 1x1 double.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'maxv' - required
if ~GERT_Aux_ValidVec(maxv,'double',1)
    msg = 'Input argument ''maxv'' must be a 1x1 double.';
    GERT_ShowError(fnc_name,msg,3); 
end

%% Validate further
if minv >= maxv
    msg = 'Input argument ''minv'' must be smaller than input argument ''maxv''.';
    GERT_ShowError(fnc_name,msg,3);   
end

%% Do the computations
vals = vals - minv;
vals = mod(vals,maxv-minv);
vals = vals + minv;

%% All done