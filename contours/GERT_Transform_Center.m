function [d_cart, d, ct] = GERT_Transform_Center(cart, to_vals, center_to, custom_vals)

% [d_cart, d, ct] = GERT_Transform_Center(cart, to_vals, center_to, custom_vals)
%
% DESCRIPTION:
%   This function will put the center of a GContour or GElements collection of 
%   Cartesian coordinates to a specified point TO_VALS. CENTER_TO describes 
%   the method used for determining which point should be moved there. By
%   default, the bounding box is used.
%
% ARGUMENTS:
%  cart ---------------------- required
%                              1x1 GContour or GElements
%
%  to_vals ------------------- optional, pass [] to skip, default: [0 0]
%                              1x2 double 
%                              finite, real
%
%  center_to ----------------- optional, omit or pass '' to skip, default: 'BoundingBox'
%                              1xM char
%                              'Median','Mean','Centroid','GeoMean','Custom','DispCenter', 'BoundingBox'
% 
%  custom_vals --------------- optional, omit to skip, default: [0 0]
%                              1x2 or 1x4 double
%                              finite, real
%
% RETURNS:
%  d_cart -------------------- 1x1 GContour or GElements
%
%  d ------------------------- 1x2 double
%
%  ct ------------------------ 1x2 double
%
% DETAILS:
%  The 'Mean' method will move the mean of all Cartesian coordinates in
%  CART to the point specified in TO_VALS. 'Median' analogously uses the
%  Median of those points. 'Centroid' will first compute the centroid using
%  GERT_Aux_Centroid. The points should then describe a continuous, closed
%  contour. 'GeoMean' uses the geometrical mean. 'Custom' will take the
%  value in CUSTOM_VALS and move it to TO_VALS. If omitted, (0,0) will be
%  used. 'DispCenter' will use the center of the display. In case of a
%  GContour object, or when GElements.dims is empty, the dimensions can be
%  specified in custom_vals. 'BoundingBox' will center the bounding box.
%  The displacement itself is returned as D. Please note that the display
%  dimensions will remain unaffected by this function. Through adding D to
%  them, they can be shifted as well.
%  The point from which the displacement was done (e.g., the centroid) is
%  returned as CT
%
% EXAMPLE 
%  (1) Move the median of this contour to point (300,300)
%    cart = GERT_GenerateContour_RFP(params);
%    cart = GERT_Transform_Center(cart,[300 300],'Median');
%
%  (2) Move the display center to (0,0), and shift the dims too
%    params.dims = [1 500 1 500]; params.min_dist = 10;
%    cart = GERT_PlaceElements_Background([],[],params);
%    [cart,d] = GERT_Transform_Center(cart,[0,0],'DispCenter');
%    cart.dims = [cart.dims(1)+d(1) cart.dims(2)+d(1) cart.dims(3)+d(2) cart.dims(4)+d(2)];
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
fnc_name = 'GERT_Transform_Center';

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

% 'to_vals' - optional, pass [] to skip
if ~isempty(to_vals) && ~GERT_Aux_ValidVec(to_vals,'double',2)
    msg = 'Input argument ''to_vals'' must be a 1x2 double';
    GERT_ShowError(fnc_name,msg,3);    
end

% 'center_to' - optional, omit or pass '' to skip
if exist('center_to','var') && ~isempty(center_to) && ~GERT_Aux_ValidVec(center_to,'char')
    msg = 'Input argument ''center_to'' must be a character string';
    GERT_ShowError(fnc_name,msg,3);
elseif ~exist('center_to','var')
    center_to = '';
end

% 'custom_vals' - optional, omit or pass [] to skip
if exist('custom_vals','var') && ~isempty(custom_vals) && ~GERT_Aux_ValidVec(custom_vals,'double')
    msg = 'Input argument ''custom_vals'' must be a ''double'' row vector';
    GERT_ShowError(fnc_name,msg,3);
    % Check the rest below
elseif ~exist('custom_vals','var')
    custom_vals = [];
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',cart,'IN_cart');
GERT_log = add(GERT_log,'var',to_vals','IN_to_vals');
GERT_log = add(GERT_log,'var',center_to,'IN_center_to');
GERT_log = add(GERT_log,'var',custom_vals,'IN_custom_vals');

%% Parse the input
% Check 'cart'
cart = validate(cart);

if cart.n < 2
   msg = 'At least two points are needed'; 
   GERT_ShowError(fnc_name,msg,3);
end

% Defaults & further checking
if isa(cart,'GContour') && isempty(to_vals)
	to_vals = [0,0];
end    

if isa(cart,'GElements')
    if isempty(to_vals) && isempty(cart.dims)
       to_vals = [0,0];
    elseif isempty(to_vals) && ~isempty(cart.dims)
       to_vals = [mean([cart.dims(1) cart.dims(2)]) mean([cart.dims(3) cart.dims(4)])]; 
    end
end    

if strcmp(center_to, '')
    center_to = 'BoundingBox';
    
elseif strcmp(center_to,'Custom')
    
    if isempty(custom_vals)
        custom_vals = [0,0];
    elseif size(custom_vals,1) ~=1 || size(custom_vals,2) ~=2
        msg = 'Input argument ''custom_vals'' must be a 1x2 vector when using the ''Custom'' method.';
        GERT_ShowError(fnc_name,msg,3);
    end

elseif strcmp(center_to,'DispCenter')
    
    if isa(cart,'GContour')
        if isempty(custom_vals)
            msg = 'Please provide a ''custom_vals'' argument when using this method on a GContour.';
            GERT_ShowError(fnc_name,msg,3);
        elseif size(custom_vals,1) ~=1 || size(custom_vals,2) ~=4
            msg = 'Input argument ''custom_vals'' must be a 1x4 vector when using the ''DispCenter'' method.';
            GERT_ShowError(fnc_name,msg,3);
        end
    end
    
    if isa(cart,'GElements')
        if isempty(custom_vals) && ~isempty(cart.dims)
            custom_vals = cart.dims;
        elseif isempty(custom_vals) && isempty(cart.dims)
            msg = 'No ''dims'' available in the ''cart'' argument, please provide a ''custom_vals'' argument';
            GERT_ShowError(fnc_name,msg,3);
        elseif size(custom_vals,1) ~=1 || size(custom_vals,2) ~=4
            msg = 'Input argument ''custom_vals'' must be a 1x4 vector when using the ''DisplayCenter'' method.';
            GERT_ShowError(fnc_name,msg,3);
        end
    end
    
    if custom_vals(1) >= custom_vals(2) || custom_vals(3) >= custom_vals(4)
        msg = 'Invalid display dimensions for method ''DispCenter''';
        GERT_ShowError(fnc_name,msg,3);
    end

elseif ~strcmp(center_to,'Mean') && ~strcmp(center_to,'GeoMean') && ...
        ~strcmp(center_to,'Median') && ~strcmp(center_to,'Centroid') && ...
        ~strcmp(center_to,'BoundingBox')
    
	msg = strcat('Unknown value for argument ''center_to''',center_to);
	GERT_ShowError(fnc_name,msg,3);
    
end

%% Do stuff
if strcmp(center_to, 'Median')
    ct_x = median(cart.x);
    ct_y = median(cart.y);
elseif strcmp(center_to, 'Mean')
    ct_x = mean(cart.x);
    ct_y = mean(cart.y);
elseif strcmp(center_to, 'Centroid')
   [ct_x, ct_y] = GERT_Aux_Centroid(cart.x,cart.y);
elseif strcmp(center_to, 'GeoMean')
    ct_x = geomean(cart.x);
    ct_y = geomean(cart.y);
elseif strcmp(center_to, 'Custom')
    ct_x = custom_vals(1);
    ct_y = custom_vals(2);
elseif strcmp(center_to, 'DispCenter') 
    ct_x = mean([custom_vals(1) custom_vals(2)]);
    ct_y = mean([custom_vals(3) custom_vals(4)]);
elseif strcmp(center_to, 'BoundingBox') 
    ct_x = min(cart.x) + ((max(cart.x)-min(cart.x))/2);
    ct_y = min(cart.y) + ((max(cart.y)-min(cart.y))/2);
end

ct = [ct_x ct_y];

% Center to this point
d_cart = cart;
d_cart.x = d_cart.x - ct_x + to_vals(1);
d_cart.y = d_cart.y - ct_y + to_vals(2);

d = [-ct_x+to_vals(1) -ct_y+to_vals(2)];

%% Log the output
GERT_log = add(GERT_log,'var',d_cart,'OUT_d_cart');
GERT_log = add(GERT_log,'var',d,'OUT_d');
GERT_log = add(GERT_log,'var',ct,'OUT_ct');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done