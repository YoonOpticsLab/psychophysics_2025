function IMG = GERT_DrawElement_Polygon(params)

% IMG = GERT_DrawElement_Polygon(params)
%
% DESCRIPTION:
%  This function will draw a single ploygon patch, according to the
%  parameters defined. Important parameters are the POINTS defining the
%  polygon, the OR of the polygon, and the SIZE of the image patch, defined 
%  as the total width divided by two, minus one. All these parameters are 
%  to be passed in pixel units.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- points ------------- required
%      |                       2xN double
%      |                       N>2 abs < size
%      |
%      |- or ----------------- optional, default: 0
%      |                       1x1 double
%      |                       finite, real
%      |
%      |- size --------------- optional, default: 10
%      |                       1x1 double
%      |                       >0, integer value, finite, real
%      |
%      |- scale -------------- optional, default: 1
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- aa ----------------- optional, default: 4
%      |                       1x1 double
%      |                       0,2,4,8, finite, real
%      |
%      |- lum_bounds --------- optional, default: [0.5 1]
%      |                       1x1 cell, containing 1x2 or 3x2 double
%      |                       >=0 <=1, finite, real
%
% RETURNS:
%  IMG ----------------------- MxM double, where M=(size*2)+1
%
% DETAILS:
%  The POINTS definition of the polygon must be centered around 0; the
%  function will then automatically center it around SIZE+1. Anti-aliasing
%  is by default enabled, to disable it change AA to 0. Setting 
%  LUM_BOUNDS allows the user to change the peak and background
%  luminances separately. The first value is always the background
%  luminance, even if the second is lower. To return a color image, pass a
%  3x2 matrix, with each row vector containing the luminance bounds for that 
%  RGB layer. Luminance bounds must always be passed as a 1x1 cell
%  variable. 
%
% EXAMPLE: 
%  % Create a blue hexagon against a red background
%  poly_params.points = [1 2 1 -1 -2 -1; 2 0 -2 -2 0 2];
%  poly_params.or = 0;
%  poly_params.scale = 5;
%  poly_params.size = 20;
%  poly_params.lum_bounds = {[1 0; 0 0; 0 1]};
%
%  IMG = GERT_DrawElement_Polygon(poly_params);
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

%% Check the arguments
fnc_name = 'GERT_DrawElement_Polygon';

global GERT_elerrcheck;
if GERT_elerrcheck
    
    GERT_Init;
    
    % One argument required
    if nargin ~= 1
        msg = 'One input argument needed.';
        GERT_ShowError(fnc_name,msg,3);
    end

    % 'params' - required
    if ~isstruct(params) || ~isscalar(params)
        msg = 'Input argument ''params'' must be a 1x1 struct.';
        GERT_ShowError(fnc_name,msg,3);
    end

    % Parse 'params'
    p = GStructParser;
    p = addfield(p, 'points', 'req', @(x) ...
        size(x,1)==2 && size(x,2) > 2 && ndims(x) == 2 && isa(x,'double') ...
        && ~any(imag(x(:))) && all(isfinite(x(:))));
    p = addfield(p, 'or', 0, @(x) ...
        GERT_Aux_ValidVec(x,'double',1));
    p = addfield(p, 'size', 10, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0 && mod(x,1)==0);
    p = addfield(p, 'scale', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p, 'aa', 4, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && ismember(x,[0 2 4 8]));
    p = addfield(p, 'lum_bounds', {[0.5 1]}, @(x) ...
        isscalar(x) && isa(x,'cell') && ndims(x)==2 && ...
        (all(size(x{1})==[1 2]) || all(size(x{1})==[3 2])) && all(x{1}(:)>=0) && all(x{1}(:)<=1) );

    p = parse(p, params);

    points = p.results.points;
    or = p.results.or;
    sz = p.results.size;
    scale = p.results.scale;
    aa = p.results.aa;
    lum_bounds = p.results.lum_bounds;

    if any(abs(points) > sz)
       msg = 'No ''points'' should not exceed the size of the image.';
       GERT_ShowError(fnc_name,msg,3);
    end
else
    
   if isfield(params,'points'),points = params.points;else points=[];end
   if isfield(params,'size'),sz = params.size;else sz = 10;end
   if isfield(params,'or'),or = params.or;else or = 0;end
   if isfield(params,'aa'),aa = params.aa;else aa = 4;end
   if isfield(params,'scale'),scale = params.scale;else scale = 1;end
   if isfield(params,'lum_bounds'),lum_bounds = params.lum_bounds;else lum_bounds = {[0.5 1]};end
    
end

%% Draw the polygon
% Scale
points = points * scale;

% Rotate
[th, r] = cart2pol(points(1,:),points(2,:));
th = th + or;
[points(1,:), points(2,:)] = pol2cart(th,r);

% Center on psize
points(1,:) = points(1,:)+sz+1;
points(2,:) = points(2,:)+sz+1;

global GERT_matlv;
if (aa)
    
    % First create at a higher resolution 
    IMG = poly2mask(aa*points(1,:),aa*points(2,:),aa*((sz*2)+1),aa*((sz*2)+1));
    IMG = double(IMG);
    
    % Then rescale with Lanczos interpolation
    if strcmp(GERT_matlv{1},'Matlab') 
        if GERT_matlv{2}>=7 && GERT_matlv{3}>=4
            IMG = imresize(IMG,[sz*2+1 sz*2+1],'lanczos2');
        else
            IMG = imresize(IMG,[sz*2+1 sz*2+1],'bilinear');
        end
    else
        IMG = imresize(IMG,[sz*2+1 sz*2+1],'linear');
    end

else
    % If no anti-aliasing, just do the inpolygon
    IMG = poly2mask(points(1,:),points(2,:),((sz*2)+1),((sz*2)+1));
    IMG = double(IMG);
end

% Apply the luminance bounds / colors
if size(lum_bounds{1},1) == 1
    if any(lum_bounds{1} - [0 1])
        IMG = (IMG * (lum_bounds{1}(2)-lum_bounds{1}(1))) + lum_bounds{1}(1);
    end
else
    if any(lum_bounds{1}(:) - [0 0 0 1 1 1]')
        IMG2 = zeros(sz*2 + 1,sz*2 + 1,3);
        IMG2(:,:,1) = (IMG * (lum_bounds{1}(1,2)-lum_bounds{1}(1,1))) + lum_bounds{1}(1,1);
        IMG2(:,:,2) = (IMG * (lum_bounds{1}(2,2)-lum_bounds{1}(2,1))) + lum_bounds{1}(2,1);
        IMG2(:,:,3) = (IMG * (lum_bounds{1}(3,2)-lum_bounds{1}(3,1))) + lum_bounds{1}(3,1);
        IMG = IMG2;
    end
end

%% All done