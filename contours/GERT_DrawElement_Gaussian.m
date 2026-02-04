function IMG = GERT_DrawElement_Gaussian(params)

% IMG = GERT_DrawElement_Gaussian(params)
%
% DESCRIPTION:
%  This function will draw a single Gaussian stimulus onto a rectangular image 
%  patch, according to the parameters defined. Important parameters 
%  are the OR of the grating, the SIGMA of the Gaussian components, and the 
%  SIZE of the image patch, defined as the total width divided by two, minus 
%  one. All these parameters are to be passed in pixel units.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- or ----------------- optional, default: 0
%      |                       1x1 double
%      |                       finite, real
%      |
%      |- sigmax ------------- optional, default: 2
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- sigmay ------------- optional, default: 2
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- size --------------- optional, default: 10
%      |                       1x1 double
%      |                       >0, integer value, finite, real
%      |
%      |- amp ---------------- optional, default: 1
%      |                       1x1 double
%      |                       >=0, finite, real
%      |
%      |- scale -------------- optional, default: 1
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- lum_bounds --------- optional, default: [0.5 1]
%      |                       1x1 cell, containing 1x2 or 3x2 double
%      |                       >=0 <=1, finite, real
%
% RETURNS:
%  IMG ----------------------- MxM double, where M=(size*2)+1
%
% DETAILS:
%  Setting LUM_BOUNDS allows the user to change the peak and background
%  luminances separately. The first value is always the background
%  luminance, even if the second is lower. To return a color image, pass a
%  3x2 matrix, with each row vector containing the luminance bounds for that 
%  RGB layer. Luminance bounds must always be passed as a 1x1 cell
%  variable. 
%
% EXAMPLE: 
%  Create an elongated blue Gaussian against a red background
%  gausel_params.or = 0;
%  gausel_params.sigmax = 2.5;
%  gausel_params.sigmay = 5.5;
%  gausel_params.size = 50;
%  gausel_params.scale = 5;
%  gausel_params.lum_bounds = {[1 0; 0 0; 0 1]};
%
%  IMG = GERT_DrawElement_Gaussian(gausel_params);
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
fnc_name = 'GERT_DrawElement_Gaussian';

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
    p = addfield(p,'or', 0, @(x) ...
        GERT_Aux_ValidVec(x,'double',1));
    p = addfield(p,'sigmax', 2, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'sigmay', 2', @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'size', 10, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0 && mod(x,1)==0);
    p = addfield(p,'amp', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>=0 && x<=1);
    p = addfield(p,'scale', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    p = addfield(p,'lum_bounds', {[0.5 1]}, @(x) ...
        isscalar(x) && isa(x,'cell') && ndims(x{1})==2 && ...
        (all(size(x{1})==[1 2]) || all(size(x{1})==[3 2])) && all(x{1}(:)>=0) && all(x{1}(:)<=1) );

    p = parse(p,params);

    or = p.results.or;
    sigmax = p.results.sigmax;
    sigmay = p.results.sigmay;
    sz = p.results.size;
    amp = p.results.amp;
    scale = p.results.scale;
    lum_bounds = p.results.lum_bounds;
    
% Do not check errors
else
   if isfield(params,'or'),or = params.or;else or = 0;end
   if isfield(params,'sigmax'),sigmax = params.sigmax;else sigmax = 2;end
   if isfield(params,'sigmay'),sigmay = params.sigmay;else sigmay = 2;end
   if isfield(params,'size'),sz = params.size;else sz = 10;end
   if isfield(params,'amp'),amp = params.amp;else amp = 1;end
   if isfield(params,'scale'),scale = params.scale;else scale = 1;end
   if isfield(params,'lum_bounds'),lum_bounds = params.lum_bounds;else lum_bounds = {[0.5 1]};end
end

%% Draw the Gaussian
% Prepare meshgrid
[xgr ygr] = meshgrid(-sz:1:sz,-sz:1:sz);

% Insert rotation
[th, r] = cart2pol(xgr,ygr);
xgr = r.*sin(th-or);
ygr = r.*cos(th-or);

% Gaussian
sigmasqx = (sigmax * scale) ^2 ;
sigmasqy = (sigmay * scale) ^2 ;

rho = 0;
p1 = -1/(2*(1-(rho^2)));
p2 = xgr.^2./(2*sigmasqx);
p3 = ygr.^2./(2*sigmasqy);
p4 = (2*rho.*xgr.*ygr)/(sigmax*sigmay);
gaussian =  amp * exp(p1*(p2+p3-p4));


%% Apply luminance bounding
if size(lum_bounds{1},1) == 3 
    % If color, use three layers
    gaussian = repmat(gaussian,[1 1 3]);
    for i = 1:3
       gauslay = gaussian(:,:,i);
       gauslay = gauslay * (lum_bounds{1}(i,2)-lum_bounds{1}(i,1));
       IMG(:,:,i) = lum_bounds{1}(i,1) + gauslay;
    end 
    
elseif size(lum_bounds{1},1) == 1
    % Grayscale
    gauslay = gaussian;
    gauslay = gauslay * (lum_bounds{1}(2)-lum_bounds{1}(1));
    IMG = lum_bounds{1}(1) + gauslay;
end

%% All done