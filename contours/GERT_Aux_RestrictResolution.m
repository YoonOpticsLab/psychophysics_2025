function vals = GERT_Aux_RestrictResolution(vals, precision)

% vals = GERT_Aux_RestrictResolution(vals, precision)
%
% DESCRIPTION:
%  This function will discretize the values in VALS, to a given PRECISION.
%
% ARGUMENTS:
%  vals ---------------------- required
%                              double
%                              finite, real
%
%  precision ----------------- required
%                              1x1 double
%                              >0, finite, real
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
fnc_name = 'GERT_Aux_RestrictResolution';

% Two arguments required
if nargin ~= 2
    msg = 'Two input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'vals' - required
if ~all(isfinite(vals(:))) || ~isa(vals,'double') || any(imag(vals(:)))
    msg = 'Input argument ''vals'' must be a double.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'precision' - required
if ~GERT_Aux_ValidVec(precision,'double',1) || precision <= 0
    msg = 'Input argument ''precision'' must be a positive 1x1 double.';
    GERT_ShowError(fnc_name,msg,3); 
end

%% Do the computation
vals = precision * round(vals/precision);

%% All done
