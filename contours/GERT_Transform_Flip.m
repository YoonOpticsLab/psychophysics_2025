function d_cart = GERT_Transform_Flip(cart, flip_axis, flip_point, custom_vals)

% d_cart = GERT_Transform_Flip(cart, flip_axis, flip_point, custom_vals)
%
% DESCRIPTION:
%   This function will flip a GContour or GElements collection of 
%   Cartesian coordinates around a specified flip point SCALE_POINT, and a
%   flip axis FLIP_AXIS. FLIP_POINT uses the same strings as GERT_Transform_Center,
%   and CUSTOM_VALS serves the same function as FROM_VALS in that function.
%
% ARGUMENTS:
%  cart ---------------------- required
%                              1x1 GContour or GElements
%
%  flip_axis ----------------- required
%                              1x1 double, finite, real
%
%  flip_point ---------------- optional, default: 'BoundingBox'
%                              1xM char
%                              'Median','Mean','Centroid','GeoMean','Custom','DispCenter', 'BoundingBox'
% 
%  custom_vals --------------- optional
%                              1x2 or 1x4 double, finite, real
%
% RETURNS:
%  d_cart -------------------- 1x1 GContour or GElements
%
% DETAILS:
%  None.
%
% EXAMPLE:
%  (1) Flip horizontally around the centroid
%    cart = GERT_GenerateContour_RFP(params);
%    cart = GERT_Transform_Flip(cart,0,'Centroid');
%
%  (2) Flip around the main axis of the object
%    [ma,pt] = main_axis(cart);
%    cart = GERT_Transform_Flip(cart,ma,'Custom',pt);
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
fnc_name = 'GERT_Transform_Flip';

% At least two arguments required
if nargin < 2 || nargin > 4
    msg = 'Between two and four input arguments needed';
    GERT_ShowError(fnc_name,msg,3);
end

% 'cart' - required
if (~isa(cart,'GContour') && ~isa(cart,'GElements')) || ~isscalar(cart)
    msg = 'Input argument ''cart'' must be a 1x1 GContour or GElements';
    GERT_ShowError(fnc_name,msg,3);
end

% 'flip_axis' - required
if ~GERT_Aux_ValidVec(flip_axis,'double',1)
    msg = 'Input argument ''flip_axis'' must be a 1x1 double';
    GERT_ShowError(fnc_name,msg,3);
    
    if flip_axis < -2*pi || flip_axis > 2*pi
        msg = 'Argument ''flip_axis'' is outside the -2*pi to 2*pi range';
        GERT_ShowError(fnc_name,msg,1);
    end    
end

% 'flip_point' - optional, omit or pass '' to skip
if exist('flip_point','var') && ~isempty(flip_point) && ~GERT_Aux_ValidVec(flip_point,'char')
    msg = 'Input argument ''flip_point'' must be a character string';
    GERT_ShowError(fnc_name,msg,3);
    % The GERT_Transform_Center function handles the strcmp
elseif ~exist('flip_point','var')
    flip_point = '';
end

% 'custom_vals' - optional, omit or pass [] to skip
if exist('custom_vals','var') && ~isempty(custom_vals) && ~GERT_Aux_ValidVec(custom_vals,'double')
    msg = 'Input argument ''custom_vals'' must be a ''double'' row vector';
    GERT_ShowError(fnc_name,msg,3);
    % Check the rest in the Center function
elseif ~exist('custom_vals','var')
    custom_vals = [];
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',cart,'IN_cart');
GERT_log = add(GERT_log,'var',flip_axis,'IN_flip_axis');
GERT_log = add(GERT_log,'var',flip_point,'IN_flip_point');
GERT_log = add(GERT_log,'var',custom_vals,'IN_custom_vals');

%% Parse the input
% Check 'cart'
cart = validate(cart);

if cart.n == 0
   msg = 'No points found'; 
   GERT_ShowError(fnc_name,msg,3);
end

% The GERT_Transform_Center function handles a good deal of argument
% checking for us here.

%% Do stuff
% First rotate to determine the flip axis
r_cart = GERT_Transform_Rotate(cart, flip_axis, flip_point, custom_vals);

% Center on 0
[r_cart, foo, ct] = GERT_Transform_Center(r_cart, [0,0], flip_point, custom_vals);

% Flip the axis now that everything is nicely horizontal and centered on (0,0)
r_cart.y = -r_cart.y;

% Restore the centering
r_cart.x = r_cart.x + ct(1);
r_cart.y = r_cart.y + ct(2);

% Restore the rotating
d_cart = GERT_Transform_Rotate(r_cart, -flip_axis, flip_point, custom_vals);

% Also change the local tangents
if isa (d_cart, 'GContour')
    d_cart.lt = d_cart.lt - 2*(d_cart.lt - flip_axis);
end

%% Log the output
GERT_log = add(GERT_log,'var',d_cart,'OUT_d_cart');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done