function d_cart = GERT_Transform_Scale(cart, scale_factor, scale_point, custom_vals)

% d_cart = GERT_Transform_Scale(cart, scale_factor, scale_point,custom_vals)
%
% DESCRIPTION:
%   This function will scale a GContour or GElements collection of 
%   Cartesian coordinates around a specified point SCALE_POINT, by an amount
%   SCALE_FACTOR. SCALE_POINT uses the same strings as GERT_Transform_Center,
%   and CUSTOM_VALS serves the same function as FROM_VALS in that function.
%
% ARGUMENTS:
%  cart ---------------------- required
%                              1x1 GContour or GElements
%
%  scale_factor -------------- required
%                              1x1 double
%                              finite, real
%
%  scale_point --------------- optional, default: 'BoundingBox'
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
% EXAMPLE 
%  (1) Scale down by a factor 2, keeping the centroid constant
%    cart = GERT_GenerateContour_RFP(params);
%    cart = GERT_Transform_Scale(cart,0.5,'Centroid');
%
%  (2) Scale up by a factor 2, keeping (20,20) constant
%    cart = GERT_PlaceElements_Background([],[],params);
%    cart = GERT_Transform_Scale(cart,2,'Custom',[20 20]);
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
fnc_name = 'GERT_Transform_Scale';

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

% 'scale_factor' - required
if ~GERT_Aux_ValidVec(scale_factor,'double',1)
    msg = 'Input argument ''scale_factor'' must be a 1x1 double';
    GERT_ShowError(fnc_name,msg,3);
    
    if scale_factor < 0
        msg = 'Argument ''scale_factor'' must be positive';
        GERT_ShowError(fnc_name,msg,3);
    end    
end

% 'scale_point' - optional, omit or pass '' to skip
if exist('scale_point','var') && ~isempty(scale_point) && ~GERT_Aux_ValidVec(scale_point,'char')
    msg = 'Input argument ''scale_point'' must be a character string';
    GERT_ShowError(fnc_name,msg,3);
    % The GERT_Transform_Center function handles the strcmp
elseif ~exist('scale_point','var')
    scale_point = '';
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
GERT_log = add(GERT_log,'var',scale_factor,'IN_scale_factor');
GERT_log = add(GERT_log,'var',scale_point,'IN_scale_point');
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

%% Scale
[d_cart, d, ct] = GERT_Transform_Center(cart, [0,0], scale_point, custom_vals);

d_cart.x = d_cart.x * scale_factor;
d_cart.y = d_cart.y * scale_factor;

% The scale_point stays fixed
d_cart.x = d_cart.x + ct(1);
d_cart.y = d_cart.y + ct(2);

% Also scale the cdist values
if isa(d_cart,'GContour')
   d_cart.cdist = d_cart.cdist * scale_factor; 
end

%% Log the output
GERT_log = add(GERT_log,'var',d_cart,'OUT_d_cart');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done