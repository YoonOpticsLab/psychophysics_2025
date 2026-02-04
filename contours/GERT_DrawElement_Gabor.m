function IMG = GERT_DrawElement_Gabor(params)

% IMG = GERT_DrawElement_Gabor(params)
%
% DESCRIPTION:
%  This function will draw a single Gabor stimulus onto a rectangular image
%  patch, according to the parameters defined. The parameters typically
%  manipulated are the OR of the grating, the SIGMA of the Gaussian
%  components, the FREQ of the Sinusoidal component, and the SIZE of the 
%  image patch, defined as the total width divided by two, minus one. All
%  these parameters are to be passed in pixel units.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- or ----------------- optional, default: 0
%      |                       1x1 double
%      |                       finite, real
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
%      |                       >=0 <=1finite, real
%      |
%      |- lum_scale  --------- optional, default: 'None'
%      |                       1x1 cell, containing char vector
%      |                       >=0 <=1, finite, real
%
% RETURNS:
%  IMG ----------------------- MxM double, where M=(size*2)+1
%
% DETAILS:
%  Setting LUM_BOUNDS allows the user to change the maximal, minimal and
%  background luminance values independently. For instance, [0 0.2 1]
%  will create a high-contrast Gabor against a dark gray background.
%  Note that assymmetrical lum_bounds will create non-Gabor luminance profiles.
%  To return a color image, pass a 3x3 matrix, with each row vector containing
%  the luminance bounds for that RGB layer. Luminance bounds must always be
%  passed as a 1x1 cell variable. LUM_SCALE allows further luminance rescaling
%  operations, and must be a 1x1 cell containing a char array. The default
%  'None' mode disables rescaling. 'SymmMax' will attempt to create a
%  maximal contrast through symmetrical rescaling around the background
%  value. For instance, this comes in handy when using a phase of pi/2,
%  since in that case often no pixel will have a 0 or 1 luminance even
%  though the amplitude is maximal (due to the Gaussian convolution).
%  Applying 'SymmMax' will then return a Gabor of maximal contrast.
%  'AsymmMax' is similar, but allows the rescaling to be assymmetrical. A
%  possible application is when the background luminance has to be dark
%  (e.g., during eye tracking the pupils have to remain large), yet high
%  contrast is needed. 'AsymmMax' will then maximize the contrast such that
%  the positive part of the Gabor is very clear, whereas the negative part
%  remains subtle.
%
% EXAMPLE: 
%  Create a large, high contrast odd Gabor against a dark gray background
%  gabel_params.or = 0;
%  gabel_params.sigma = 2.5;
%  gabel_params.size = 200;
%  gabel_params.freq = 0.1071;
%  gabel_params.phase = pi/2;
%  gabel_params.scale = 20;
%  gabel_params.lum_bounds = {[0 0.2 1]};
%  gabel_params.lum_scale = {'SymmMax'};
%
%  IMG = GERT_DrawElement_Gabor(gabel_params);
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
fnc_name = 'GERT_DrawElement_Gabor';

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
    p = addfield(p,'or', 0, @(x) ...
        GERT_Aux_ValidVec(x,'double',1));
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
    p = addfield(p,'lum_scale', {'None'}, @(x) ...
        isscalar(x) && isa(x,'cell'));

    p = parse(p,params);

    or = p.results.or;
    sigma = p.results.sigma;
    freq = p.results.freq;
    sz = p.results.size;
    phase = p.results.phase;
    amp = p.results.amp;
    scale = p.results.scale;
    lum_bounds = p.results.lum_bounds;
    lum_scale = p.results.lum_scale;

    if ~GERT_Aux_ValidVec(lum_scale{1},'char')
        msg = '''lum_scale'' must be 1x1 cell containing a char vector';
        GERT_ShowError(fnc_name,msg,3);
    end

    if ~any([strcmp(lum_scale{1},'None') strcmp(lum_scale{1},'SymmMax') strcmp(lum_scale{1},'AsymmMax')])
        msg = 'Unknown lum_scale mode.';
        GERT_ShowError(fnc_name,msg,3);
    end

% Do not check errors
else
   if isfield(params,'or'),or = params.or;else or = 0;end
   if isfield(params,'sigma'),sigma = params.sigma;else sigma = 2.5;end
   if isfield(params,'freq'),freq = params.freq;else freq = 0.1;end
   if isfield(params,'size'),sz = params.size;else sz = 10;end
   if isfield(params,'phase'),phase = params.phase;else phase = 0;end
   if isfield(params,'amp'),amp = params.amp;else amp = 1;end
   if isfield(params,'scale'),scale = params.scale;else scale = 1;end
   if isfield(params,'lum_bounds'),lum_bounds = params.lum_bounds;else lum_bounds = {[0 0.5 1]};end
   if isfield(params,'lum_scale'),lum_scale = params.or;else lum_scale = {'None'};end
end

%% Draw the Gabor
% Prepare meshgrid
[xgr ygr] = meshgrid(-sz:1:sz,-sz:1:sz);

% Gaussian
sigmasq = (sigma * scale) ^2 ;
gaussian = exp(-(xgr.^2+ygr.^2)./(2*sigmasq));

% Grating
omega = 2*pi*freq/scale;
slant = xgr*(omega*cos(or)) + ygr*(omega*sin(or));
grating = amp*cos(slant+phase);

% Combine!
gabor = gaussian.*grating;

%% Apply luminance bounding and scaling

global GERT_gab_scale_ids;

if size(lum_bounds{1},1) == 3
    
    % If color, use three layers
    IMG = repmat(gabor,[1 1 3]);
    for i = 1:3
        gablay = gabor;
        gablay(gablay<0) = gablay(gablay<0) * (lum_bounds{1}(i,2)-lum_bounds{1}(i,1));
        gablay(gablay>0) = gablay(gablay>0) * (lum_bounds{1}(i,3)-lum_bounds{1}(i,2));
        IMG(:,:,i) = lum_bounds{1}(i,2) + gablay;
    end
    
    % No scaling allowed yet for color images
    if strcmp(lum_scale{1},'None')
        % Do nothing
    else
        msg = 'Only the default scale mode is implemented for color images';
        GERT_ShowError(fnc_name, msg, 3);
    end
    
elseif size(lum_bounds{1},1) == 1
    
    % Grayscale
    gabor(gabor<0) = gabor(gabor<0) * (lum_bounds{1}(2)-lum_bounds{1}(1));
    gabor(gabor>0) = gabor(gabor>0) * (lum_bounds{1}(3)-lum_bounds{1}(2));
    IMG = lum_bounds{1}(2) + gabor;
    
    % Apply the relevant luminance scaling
    if strcmp(lum_scale{1},'None')
        % Do nothing
    elseif strcmp(lum_scale{1},'SymmMax')
        
        if any(any(diff(lum_bounds{1},1,2)<0))
            msg = '''lum_bounds'' is improperly structured for the luminance scaling mode ''SymmMax''. For grayscale images, a [LO MID HI] row vector is required, where LO<=MID<=HI. For color images, three such row vectors must be present.';
            GERT_ShowError(fnc_name,msg,3);
        end
        
        IMG = IMG - lum_bounds{1}(2);
        
        % There is no analytical solution to find the extrema of Gabor
        % functions, since the first derivative is of the form c1*x =
        % tan(c2*x) at 0. We will have to use approximation.
        
        % This is time-consuming when many elements are placed.
        % Therefore we have trick; we re-use the outcome of the
        % approximation across successive executions of this functions, if
        % possible.
        
        this_scale_id = GERT_Aux_UniqueID([sigma freq phase]);
        idx = [];
        
        if ~isempty(GERT_gab_scale_ids)
            idx = find(GERT_gab_scale_ids(:,1)==this_scale_id);
        end
        
        if ~isempty(idx)
            mnl = GERT_gab_scale_ids(idx,2);
            mxl = GERT_gab_scale_ids(idx,3);
        else
            gabdf = @(x) -x/sigma^2.*exp((-0.5*x.^2)/sigma^2).*cos(2*pi*freq*x+phase)-2*exp((-0.5*x.^2)/sigma^2).*sin(2*pi*freq*x+phase)*pi*freq;
            
            i=0;
            for step = linspace(-1/freq,1/freq,10)
                i = i+1;
                gabextr_x(i) = fzero(gabdf,step);
                gabextr_lum(i) = amp.*exp(-0.5*(gabextr_x(i).*gabextr_x(i)/(sigma*sigma))).*(cos((2*pi*freq*gabextr_x(i))+phase));
            end
            mxl = unique(max(gabextr_lum));
            mnl = unique(min(gabextr_lum));
            
            GERT_gab_scale_ids(size(GERT_gab_scale_ids,1)+1,:) = [this_scale_id mnl mxl];
        end
        
        mnl = mnl * (lum_bounds{1}(2)-lum_bounds{1}(1));
        mxl = mxl * (lum_bounds{1}(3)-lum_bounds{1}(2));
        
        % Rescale both the positive and the negative part of the image by
        % the same factor, such the no lum_bounds are exceeded
        maxsc = (1/mxl)*(lum_bounds{1}(3)-lum_bounds{1}(2));
        minsc = abs(1/mnl)*(lum_bounds{1}(2)-lum_bounds{1}(1));
        sc = min([maxsc(1) minsc(1)]);
        IMG = (IMG * sc) + lum_bounds{1}(2);
        
        % Account for possible slight approximation errors. I.e., the pixel
        % was even more extreme than the approximated extrema
        IMG(IMG>1) = 1;
        IMG(IMG<0) = 0;
        
    elseif strcmp(lum_scale{1},'AsymmMax')
        
        if any(any(diff(lum_bounds{1},1,2)<0))
            msg = '''lum_bounds'' is improperly structured for the luminance scaling mode ''AsymmMax''. For grayscale images, a [LO MID HI] row vector is required, where LO<=MID<=HI. For color images, three such row vectors must be present.';
            GERT_ShowError(fnc_name,msg,3);
        end
        
        IMG = IMG - lum_bounds{1}(2);
        
        this_scale_id = GERT_Aux_UniqueID([sigma freq phase]);
        idx = [];
        
        if ~isempty(GERT_gab_scale_ids)
            idx = find(GERT_gab_scale_ids(:,1)==this_scale_id);
        end
        
        if ~isempty(idx)
            mnl = GERT_gab_scale_ids(idx,2);
            mxl = GERT_gab_scale_ids(idx,3);
        else
            gabdf = @(x) -x/sigma^2.*exp((-0.5*x.^2)/sigma^2).*cos(2*pi*freq*x+phase)-2*exp((-0.5*x.^2)/sigma^2).*sin(2*pi*freq*x+phase)*pi*freq;
            
            i=0;
            for step = linspace(-1/freq,1/freq,10)
                i = i+1;
                gabextr_x(i) = fzero(gabdf,step);
                gabextr_lum(i) = amp.*exp(-0.5*(gabextr_x(i).*gabextr_x(i)/(sigma*sigma))).*(cos((2*pi*freq*gabextr_x(i))+phase));
            end
            mxl = unique(max(gabextr_lum));
            mnl = unique(min(gabextr_lum));
            
            GERT_gab_scale_ids(size(GERT_gab_scale_ids,1)+1,:) = [this_scale_id mnl mxl];
        end
        
        mnl = mnl * (lum_bounds{1}(2)-lum_bounds{1}(1));
        mxl = mxl * (lum_bounds{1}(3)-lum_bounds{1}(2));
        
        % Here we rescale the positive and the negative part separately, to
        % its lum_bounds
        maxsc = (1/mxl)*(lum_bounds{1}(3)-lum_bounds{1}(2));
        minsc = abs(1/mnl)*(lum_bounds{1}(2)-lum_bounds{1}(1));
        IMG(IMG>0) = (IMG(IMG>0) * maxsc) + lum_bounds{1}(2);
        IMG(IMG<=0) = (IMG(IMG<=0) * minsc) + lum_bounds{1}(2);
        
        IMG(IMG>1) = 1;
        IMG(IMG<0) = 0;
        
    else
        msg = 'This scale mode is not implemented for grayscale images';
        GERT_ShowError(fnc_name, msg, 3);
    end
end

%% All done