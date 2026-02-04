function d_cart = GERT_Transform_Rotate(cart, rot_ang, rot_point, custom_vals)

% d_cart = GERT_Transform_Rotate(cart, rotation_ang, rotation_point, custom_vals)
%
% DESCRIPTION:
%   This function will rotate a GContour or GElements collection of 
%   Cartesian coordinates around a specified point ROT_POINT, by an amount
%   ROT_ANG. ROT_POINT uses the same strings as GERT_Transform_Center,
%   and CUSTOM_VALS serves the same function as FROM_VALS in that function.
%
% ARGUMENTS:
%  cart ---------------------- required
%                              1x1 GContour or GElements
%
%  rot_ang ------------------- required
%                              1x1 double, finite, real
%
%  rot_point ----------------- optional, default: 'BoundingBox'
%                              1xM char
%                              'Median','Mean','Centroid','GeoMean','Custom','DispCenter','BoundingBox'
% 
%  custom_vals --------------- optional
%                              1x2 double, finite, real
%
% RETURNS:
%  d_cart -------------------- 1x1 GContour or GElements
%
% DETAILS:
%  None.
%
% EXAMPLE: 
%  (1) Rotate around the centroid by 90 degrees
%    cart = GERT_GenerateContour_RFP(params);
%    cart = GERT_Transform_Rotate(cart,pi/2,'Centroid');
%
%  (2) Rotate by 45 degrees around (20,20)
%    cart = GERT_PlaceElements_Background([],[],params);
%    cart = GERT_Transform_Rotate(cart,pi/4,'Custom',[20 20]);
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
fnc_name = 'GERT_Transform_Rotate';

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

% 'rot_ang' - required
if ~GERT_Aux_ValidVec(rot_ang,'double',1)
    msg = 'Input argument ''rot_ang'' must be a 1x1 double';
    GERT_ShowError(fnc_name,msg,3);
    
    if rot_ang < -2*pi || rot_ang > 2*pi
        msg = 'Argument ''rot_ang'' is outside the -2*pi to 2*pi range';
        GERT_ShowError(fnc_name,msg,1);
    end    
end

% 'rot_point' - optional, omit or pass '' to skip
if exist('rot_point','var') && ~isempty(rot_point) && ~GERT_Aux_ValidVec(rot_point,'char')
    msg = 'Input argument ''rot_point'' must be a character string';
    GERT_ShowError(fnc_name,msg,3);
    % The GERT_Transform_Center function handles the strcmp
elseif ~exist('rot_point','var')
    rot_point = '';
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
GERT_log = add(GERT_log, 'var',rot_ang,'IN_rot_ang');
GERT_log = add(GERT_log, 'var',rot_point,'IN_rot_point');
GERT_log = add(GERT_log, 'var',custom_vals,'IN_custom_vals');

%% Parse the input
% Check 'cart'
cart = validate(cart);

if cart.n == 0
   msg = 'No points found'; 
   GERT_ShowError(fnc_name,msg,3);
end

% The GERT_Transform_Center function handles a good deal of argument
% checking for us here.

%% Rotate
% Center the desired rotation point on (0,0)
[d_cart d ct] = GERT_Transform_Center(cart, [0,0], rot_point, custom_vals);

% Rotate
[th, r] = cart2pol(d_cart.x,d_cart.y);
th = th + rot_ang;
[d_cart.x, d_cart.y] = pol2cart(th,r);

% Undo the centering again
d_cart.x = d_cart.x + ct(1);
d_cart.y = d_cart.y + ct(2);

% Also change the local tangents
if isa(d_cart,'GContour') && ~isempty(d_cart.lt)
   d_cart.lt = d_cart.lt - rot_ang; 
end

%% Log the output
GERT_log = add(GERT_log,'var',d_cart,'OUT_d_cart');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done