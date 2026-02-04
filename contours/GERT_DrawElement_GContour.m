function IMG = GERT_DrawElement_GContour(params)

% IMG = GERT_DrawElement_GContour(params)
%
% DESCRIPTION:
%  This function will draw an element based on one or several GContour
%  objects, specified as CONTOUR, packed in a cell scalar. The contour 
%  will be scaled automatically so that its bounding box is at a distance
%  BORDER_DIST (default: 0.1 times the SIZE parameter, defined as the total
%  width divided by two, minus one) from the image patch border. Multiple 
%  polygons are drawn such that an overlap with the previously combined 
%  polygons becomes a hole, unless the UNION parameter is set to true.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- contour ------------ required
%      |                       1x1 cell
%      |                       Closed contours
%      |
%      |- border_dist -------- optional, default: 0.1 * size
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- union -------------- optional, default: false
%      |                       1x1 logical
%      |                       true or false
%      |
%      |- center ------------- optional, default: middle of bounding box
%      |                       1x2 double
%      |                       finite, real
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
%  The GContour will automatically be centered such that the middle of its
%  bounding box becomes the middle of the element. To adjust this, set the
%  optional CENTER parameter, expressed in the units of the original
%  GContour definition. Rotation through the OR parameter will also occur
%  around this middle point. Anti-aliasing is by default enabled, to disable
%  it change AA to 0. Setting LUM_BOUNDS allows the user to change the peak 
%  and background luminances separately. The first value is always the 
%  background luminance, even if the second is lower. To return a color
%  image, pass a 3x2 matrix, with each row vector containing the luminance
%  bounds for that RGB layer. Luminance bounds must always be passed as a 
%  1x1 cell variable. 
%
% EXAMPLE: 
%   (none)
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
fnc_name = 'GERT_DrawElement_GContour';

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
    p = addfield(p,'contour', false, @(x) ...
        isscalar(x) && isa(x,'cell'));
    p = addfield(p,'border_dist', [], @(x) ...
        isempty(x) || (GERT_Aux_ValidVec(x,'double',1) && x>0));
    p = addfield(p,'union', false, @(x) ...
        isscalar(x) && isa(x,'logical'));
    p = addfield(p,'center', [], @(x) ...
        isempty(x) || (GERT_Aux_ValidVec(x,'double',2)));
    p = addfield(p,'or', 0, @(x) ...
        GERT_Aux_ValidVec(x,'double',1));
    p = addfield(p,'size', 10, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0 && mod(x,1)==0);
    p = addfield(p,'scale', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'aa', 4, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && ismember(x,[0 2 4 8]));
    p = addfield(p,'lum_bounds', {[0.5 1]}, @(x) ...
        isscalar(x) && isa(x,'cell') && ndims(x)==2 && ...
        (all(size(x{1})==[1 2]) || all(size(x{1})==[3 2])) && all(x{1}(:)>=0) && all(x{1}(:)<=1) );

    p = parse(p,params);

    contour = p.results.contour{1};
    border_dist = p.results.border_dist;
    union = p.results.union;
    center = p.results.center;
    or = p.results.or;
    sz = p.results.size;
    scale = p.results.scale;
    aa = p.results.aa;
    lum_bounds = p.results.lum_bounds;

    if isempty(border_dist)
       border_dist = ceil(0.1 * sz); 
    end

    if ~GERT_Aux_ValidVec(contour,'GContour')
       msg = 'No valid contour found.';
       GERT_ShowError(fnc_name,msg,3);
    end
    
% No error checking
else
    
   if isfield(params,'contour'),contour = params.contour{1};else contour = false;end
   if isfield(params,'size'),sz = params.size;else sz = 10;end
   if isfield(params,'border_dist'),border_dist = params.border_dist;else border_dist = ceil(0.1 * sz);end
   if isfield(params,'union'),union = params.union;else union = false;end
   if isfield(params,'center'),center = params.center;else center = [];end
   if isfield(params,'or'),or = params.or;else or = 0;end
   if isfield(params,'aa'),aa = params.aa;else aa = 4;end
   if isfield(params,'scale'),scale = params.scale;else scale = 1;end
   if isfield(params,'lum_bounds'),lum_bounds = params.lum_bounds;else lum_bounds = {[0.5 1]};end
        
end

%% Find the bounding box
lbb = zeros(length(contour),4);
for i = 1:length(contour)
    contour(i) = validate(contour(i));
    if ~contour(i).closed
        msg = 'GContour used as an element is not closed';
        GERT_ShowError(fnc_name,msg,1);
    end  
    lbb(i,:) = [min(contour(i).x) max(contour(i).x) min(contour(i).y) max(contour(i).y)];
end   
lbb = [min(lbb(:,1)) max(lbb(:,2)) min(lbb(:,3)) max(lbb(:,4))];
maxdim = max([lbb(2)-lbb(1) lbb(4)-lbb(3)]);

%% Determine centroid and scale
if isempty(center)
    center = zeros(1,2);
    center(1) = mean([lbb(1) lbb(2)]);
    center(2) = mean([lbb(3) lbb(4)]);
end
destsize = ((sz*2)+1) - (2*border_dist);
scaletoimg = destsize/maxdim;

%% Draw
if ~aa
    aa = 1;
end
   
for i = 1:length(contour)     
    cy = (contour(i).x-center(1)) * scaletoimg * aa * scale;
    cx = ((contour(i).y-center(2)) * scaletoimg * aa * scale);
    
    [th, r] = cart2pol(cx,cy);
    th = th + or;
    [cx, cy] = pol2cart(th,r);

    cx = cx + aa*(sz+1);
    cy = cy + aa*(sz+1);

    thisimg = poly2mask(cx,cy,aa*((sz*2)+1),aa*((sz*2)+1));

    if i==1
        IMG = thisimg;
    elseif ~union
        idx = ~(IMG == thisimg);
        IMG(idx) = IMG(idx) | thisimg(idx);
        IMG(~idx) = false;
    else
        IMG = IMG & thisimg;
    end
end

IMG = double(IMG);

%% Anti-alias
global GERT_matlv;
if aa>1
    if strcmp(GERT_matlv{1},'Matlab')
        IMG = imresize(IMG,[sz*2+1 sz*2+1],'lanczos2');
    else
        IMG = imresize(IMG,[sz*2+1 sz*2+1],'linear');
    end
end

%% Apply lum_bounds
if size(lum_bounds{1},1) == 1
    if any(lum_bounds{1} - [0 1])
        IMG = (IMG * (lum_bounds{1}(2)-lum_bounds{1}(1))) + lum_bounds{1}(1);
    end
else
    if any(lum_bounds{1}(:) - [0 0 0 1 1 1]')
        IMG2 = zeros((sz*2)+1,(sz*2)+1,3);
        IMG2(:,:,1) = (IMG * (lum_bounds{1}(1,2)-lum_bounds{1}(1,1))) + lum_bounds{1}(1,1);
        IMG2(:,:,2) = (IMG * (lum_bounds{1}(2,2)-lum_bounds{1}(2,1))) + lum_bounds{1}(2,1);
        IMG2(:,:,3) = (IMG * (lum_bounds{1}(3,2)-lum_bounds{1}(3,1))) + lum_bounds{1}(3,1);
        IMG = IMG2;
    else
        IMG = repmat(IMG,[1 1 3]);
    end
end

%% All done