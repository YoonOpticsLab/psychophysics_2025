function IMG = GERT_DrawElement_RadialGabor(params)

% IMG = GERT_DrawElement_RadialGabor(params)
%
% DESCRIPTION:
%  This function will draw a radial Gabor stimulus onto a rectangular image
%  patch, according to the parameters defined. The parameters typically
%  manipulated are the SIGMA of the Gaussian components, the FREQ of the 
%  Sinusoidal component, and the SIZE of the image patch, defined as the 
%  total width divided by two, minus one. All these parameters are to be 
%  passed in pixel units.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- sigma -------------- optional, default: 2.5
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- freq --------------- optional, default = 0.1
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- size --------------- optional, default: 10
%      |                       1x1 double
%      |                       >0, integer value, finite, real
%      |
%      |- phase -------------- optional, default: 0
%      |                       1x1 double
%      |                       finite, real
%      |
%      |- amp ---------------- optional, default: 1
%      |                       1x1 double
%      |                       >=0, finite, real
%      |
%      |- scale -------------- optional, default: 1
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- lum_bounds --------- optional, default: [0 0.5 1]
%      |                       1x1 cell, containing 1x3 or 3x3 double
%      |                       >=0 <=1, finite, real
%
% RETURNS:
%  IMG ----------------------- MxM double, where M=(size*2)+1
%
% DETAILS:
%  The PHASE and AMPlitude of the sinusoidal component can also be set. 
%  Setting LUM_BOUNDS allows the user to change the maximal, minimal and
%  background luminance values independently. For instance, [0 0.2 1]
%  will create a radial Gabor against a dark gray background.
%  To return a color image, pass a 3x3 matrix, with each row vector containing
%  the luminance bounds for that RGB layer. Luminance bounds must always be
%  passed as a 1x1 cell variable. 
%
% EXAMPLE: 
%  Draw a large blue Radial Gabor
%  gabel_params.sigma = 2.5;
%  gabel_params.size = 200;
%  gabel_params.freq = 0.12;
%  gabel_params.phase = 0;
%  gabel_params.scale = 20;
%  gabel_params.lum_bounds = {[0 0.5 1; 0 0.3 0.8; 1 1 1]};
%
%  IMG = GERT_DrawElement_RadialGabor(gabel_params);
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
fnc_name = 'GERT_DrawElement_RadialGabor';

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
    % Check errors
    p = GStructParser;
    p = addfield(p,'sigma', 2.5, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'freq', 0.1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'size', 10, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0 && mod(x,1)==0);
    p = addfield(p,'phase', 0, @(x) ...
        GERT_Aux_ValidVec(x,'double',1));
    p = addfield(p,'amp', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>=0 && x<=1);
    p = addfield(p,'scale', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'lum_bounds', {[0 0.5 1]}, @(x) ...
        isscalar(x) && isa(x,'cell') && ndims(x{1})==2 && ...
        (all(size(x{1})==[1 3]) || all(size(x{1})==[3 3])) && all(x{1}(:)>=0) && all(x{1}(:)<=1) );

    p = parse(p,params);

    sigma = p.results.sigma;
    freq = p.results.freq;
    sz = p.results.size;
    phase = p.results.phase;
    amp = p.results.amp;
    scale = p.results.scale;
    lum_bounds = p.results.lum_bounds;

% Do not check errors
else
   if isfield(params,'sigma'),sigma = params.sigma;else sigma = 2.5;end
   if isfield(params,'freq'),freq = params.freq;else freq = 0.1;end
   if isfield(params,'size'),sz = params.size;else sz = 10;end
   if isfield(params,'phase'),phase = params.phase;else phase = 0;end
   if isfield(params,'amp'),amp = params.amp;else amp = 1;end
   if isfield(params,'scale'),scale = params.scale;else scale = 1;end
   if isfield(params,'lum_bounds'),lum_bounds = params.lum_bounds;else lum_bounds = {[0 0.5 1]};end
end

%% Draw the Gabor
% Prepare the meshgrid
[xgr ygr] = meshgrid(-sz:1:sz,-sz:1:sz);

% Create the Gabor
sigmasq = (sigma*scale)^2 ;
omega = 2*pi*freq/scale;
grid = (xgr.^2) + (ygr.^2);
gabor = amp*cos(phase + (omega*sqrt(grid))).*exp(-grid/(2*sigmasq));

if size(lum_bounds{1},1) == 3
    
    % If color, use three layers
    IMG = repmat(gabor,[1 1 3]);
    for i = 1:3
        gablay = gabor;
        gablay(gablay<0) = gablay(gablay<0) * (lum_bounds{1}(i,2)-lum_bounds{1}(i,1));
        gablay(gablay>0) = gablay(gablay>0) * (lum_bounds{1}(i,3)-lum_bounds{1}(i,2));
        IMG(:,:,i) = lum_bounds{1}(i,2) + gablay;
    end
    
elseif size(lum_bounds{1},1) == 1
    
    % Grayscale
    gabor(gabor<0) = gabor(gabor<0) * (lum_bounds{1}(2)-lum_bounds{1}(1));
    gabor(gabor>0) = gabor(gabor>0) * (lum_bounds{1}(3)-lum_bounds{1}(2));
    IMG = lum_bounds{1}(2) + gabor;
    
end

%% All done

