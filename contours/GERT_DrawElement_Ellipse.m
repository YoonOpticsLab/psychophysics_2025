function IMG = GERT_DrawElement_Ellipse(params)

% IMG = GERT_DrawElement_Ellipse(params)
%
% DESCRIPTION:
%  This function will draw a single ellipse patch, according to the
%  parameters defined. Important parameters are the WIDTH and the HEIGHT
%  defining the ellipse its OR, and the SIZE of the image patch, defined 
%  as the total width divided by two, minus one. All these parameters are 
%  to be passed in pixel units.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- size --------------- optional, default: 10
%      |                       1x1 double
%      |                       >0, integer value, finite, real
%      |
%      |- width -------------- optional, default: 5
%      |                       1x1 double
%      |                       >0, < size*2, finite, real
%      |
%      |- height ------------- optional, default: width
%      |                       1x1 double
%      |                       >0, < size*2, finite, real
%      |
%      |- or ----------------- optional, default: 0
%      |                       1x1 double
%      |                       finite, real
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
%  Anti aliasing is by default enabled, to disable it change AA to 0. 
%  Setting LUM_BOUNDS allows the user to change the peak and background
%  luminances separately. The first value is always the background
%  luminance, even if the second is lower. To return a color image, pass a
%  3x2 matrix, with each row vector containing the luminance bounds for that 
%  RGB layer. Luminance bounds must always be passed as a 1x1 cell
%  variable. 
%
% EXAMPLE: 
%  % Create a blue circle against a red background
%  circle_params.width = 6;
%  circle_params.scale = 3;
%  circle_params.size = 20;
%  circle_params.lum_bounds = {[1 0; 0 0; 0 1]};
%
%  IMG = GERT_DrawElement_Ellipse(circle_params);
%
%
% ---
% Authors:  Maarten Demeyer (maarten.Demeyer@ppw.kuleuven.be)
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
fnc_name = 'GERT_DrawElement_Ellipse';

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
    p = addfield(p,'width', 5, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'height', 'creq', @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'or', 0, @(x) ...
        GERT_Aux_ValidVec(x,'double',1));
    p = addfield(p,'size', 10, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0 && ~mod(x,1));
    p = addfield(p,'scale', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'aa', 4, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && ismember(x,[0 2 4 8]));
    p = addfield(p,'lum_bounds', {[0.5 1]}, @(x) ...
        isscalar(x) && isa(x,'cell') && ndims(x)==2 && ...
        (all(size(x{1})==[1 2]) || all(size(x{1})==[3 2])) && all(x{1}(:)>=0) && all(x{1}(:)<=1) );

    p = parse(p,params);

    width = p.results.width;
    height = p.results.height;
    or = p.results.or;
    sz = p.results.size;
    scale = p.results.scale;
    aa = p.results.aa;
    lum_bounds = p.results.lum_bounds;

    if strcmp(height,'creq')
        height = width;
    end

    if any([width height] > sz*2)
       msg = 'Width and height should not exceed the size of the image.';
       GERT_ShowError(fnc_name,msg,3);
    end
    
% Don't check errors
else
    
   if isfield(params,'width'),width = params.width;else width = 5;end
   if isfield(params,'height'),height = params.height;else height = width;end
   if isfield(params,'size'),sz = params.size;else sz = 10;end
   if isfield(params,'or'),or = params.or;else or = 0;end
   if isfield(params,'aa'),aa = params.aa;else aa = 4;end
   if isfield(params,'scale'),scale = params.scale;else scale = 1;end
   if isfield(params,'lum_bounds'),lum_bounds = params.lum_bounds;else lum_bounds = {[0.5 1]};end
    
end

%% Define the ellipse and anti-alias
if ~aa
    aa = 1;
end

[xm,ym] = meshgrid(-sz*aa:sz*aa,-sz*aa:sz*aa);
[th,r] = cart2pol(xm,ym);
th = th+or;
er = ((width/2)*(height/2)) ./ sqrt((((height/2)*cos(th)).^2)+(((width/2)*sin(th)).^2));
er = er * scale * aa;
IMG = double(r < er);
global GERT_matlv;
if (aa>1)
    if strcmp(GERT_matlv{1},'Matlab') 
        if GERT_matlv{2}>=7 && GERT_matlv{3}>=4
            IMG = imresize(IMG,[sz*2+1 sz*2+1],'lanczos2');
        else
            IMG = imresize(IMG,[sz*2+1 sz*2+1],'bilinear');
        end
    else
        IMG = imresize(IMG,[sz*2+1 sz*2+1],'linear');
    end
end

%% Apply the luminance bounds / colors
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

%% All done!