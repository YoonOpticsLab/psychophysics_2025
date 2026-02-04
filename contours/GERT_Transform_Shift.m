function d_cart = GERT_Transform_Shift(cart, d)

% d_cart = GERT_Transform_Shift(cart, d)
%
% DESCRIPTION:
%   This function will translate a GContour or GElements collection of 
%   Cartesian coordinates along a specified distance D.
%
% ARGUMENTS:
%  cart ---------------------- required
%                              1x1 GContour or GElements
%
%  d ------------------------- required
%                              1x2 double, finite, real
%
% RETURNS:
%  d_cart -------------------- 1x1 GContour or GElements
%
% DETAILS:
%  None.
%
% EXAMPLE:  
%  % Shift this contour 100 units in the horizontal direction
%  cart = GERT_GenerateContour_RFP(params);
%  cart = GERT_Transform_Shift(cart,[100 0]);
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
fnc_name = 'GERT_Transform_Shift';

% At least two arguments required
if nargin ~= 2
    msg = 'Two input arguments needed';
    GERT_ShowError(fnc_name,msg,3);
end

% 'cart' - required
if (~isa(cart,'GContour') && ~isa(cart,'GElements')) || ~isscalar(cart)
    msg = 'Input argument ''cart'' must be a 1x1 GContour or GElements';
    GERT_ShowError(fnc_name,msg,3);
end

% 'd' - required
if ~GERT_Aux_ValidVec(d,'double',2)
    msg = 'Input argument ''to_vals'' must be a 1x2 double';
    GERT_ShowError(fnc_name,msg,3);    
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',cart,'IN_cart');
GERT_log = add(GERT_log,'var',d,'IN_d');

%% Parse the input
cart = validate(cart);

if cart.n == 0
   msg = 'No points found to shift.'; 
   GERT_ShowError(fnc_name,msg,1);
end

%% Do the shift
d_cart = cart;
d_cart.x = cart.x + d(1);
d_cart.y = cart.y + d(2);

%% Log the output
GERT_log = add(GERT_log,'var',d_cart,'OUT_d_cart');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done