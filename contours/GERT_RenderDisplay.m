function [IMG, pospix] = GERT_RenderDisplay(el_fnc, elements, el_params, img_params)

% [IMG, pospix] = GERT_RenderDisplay(el_fnc, elements, el_params, img_params)
%
% DESCRIPTION:
%  This function renders the stimulus image, using the EL_FNC function to
%  draw each element provided in the ELEMENTS object, according to a
%  fitting set of EL_PARAMS.
%
% ARGUMENTS:
%  elements ------------------ required
%                              1x1 GElements
%
%  el_fnc -------------------- required
%                              1x1 function handle
%                              must be compatible with el_params
%
%  el_params ----------------- required
%                              1x1 struct of 1x1 or 1xN fields
%                              el_fnc will check the fields
%
%  img_params ---------------- optional, skip to use default values
%      |                       1x1 struct
%      |
%      |- dims --------------- optional, default: elements.dims(2) and (4)
%      |                       1x2 double
%      |                       >1, integer value, finite, real
%      |
%      |- bg_lum ------------- optional, default: 0.5
%      |                       1x1 or 1x3 double
%      |                       >=0 <=1, finite, real
%      |
%      |- blend_mode --------- optional, default: 'none'
%      |                       1xM char array
%      |                       'MaxDiff' or 'None'
%      |
%      |- global_rendering --- optional, default: 'false'
%      |                       1x1 logical
%
% RETURNS:
%  IMG ----------------------- dims(2) x dims(4) double
%
%  pospix -------------------- 1x1 struct
%      |
%      |- x ------------------ 1xelements.n double
%      |
%      |- y ------------------ 1xelements.n double
%
% DETAILS:
%  The EL_PARAMS structure must consist of either scalars, or vectors with
%  the length equal to the number of elements. In the first case, all
%  elements will receive the same constant value for that parameter, in
%  the second case each element will receive its own parameter value.
%  These parameters must be compatible with the EL_FNC drawing function,
%  and will not be checked by this function.
%  DIMS are the pixel dimensions of the image. The dimensions of the
%  elements struct can be in any arbitrary units, and will automatically be
%  rescaled to these values. If DIMS is omitted, the elements struct
%  dimensions will be taken as pixel dimensions (if possible).
%  By default, BG_LUM will be set to 0.5, i.e. gray. Only one image layer
%  will then be created. If a 1x3 vector is used, a three-layered RGB image
%  will be created. However, EL_FNC must then also return three-layered
%  RGB image patches, through setting its parameters correctly
%  BLEND_MODE pertains to the method used to paste image patches into the
%  overall image. The default mode is 'None', meaning a simple paste on top
%  of what has already been generated before that element. 'MaxDiff' is
%  convenient when the image patches overlap slightly; when pasting, it
%  will retain the pixel value that is maximally different from BG_LUM. If
%  the image patches overlap by too much, this might result in strange
%  effects, however.
%  When GLOBAL_RENDERING is enabled, the function will store all patches
%  rendered in global space, to re-use should any next image have an
%  identical element.
%
% EXAMPLE: 
%  (1) Grayscale image of randomly placed and oriented Gabors
%    peb_params.dims = [1 500 1 500];
%    peb_params.min_dist = 25;
%    all_els = GERT_PlaceElements_Background([],[],peb_params);
%
%    gabel_params.sigma = 2.5;
%    gabel_params.amp = 1;
%    gabel_params.size = 10;
%    gabel_params.freq = 0.1071;
%    gabel_params.phase = 0;
%    gabel_params.scale = 1;
%    gabel_params.or = pi*rand(1,all_els.n);
%
%    IMG = GERT_RenderDisplay(@GERT_DrawElement_Gabor,all_els,gabel_params);
%    imshow(IMG);
%
% (2) Color image of orthogonally oriented elements
%   img_params.bg_lum = [0.5 0.5 0.5];
%   idx1 = 1:100; idx2 = 100:all_els.n;
%   gabel_params.or(idx1) = 0;
%   gabel_params.or(idx2) = pi/2;
%   gabel_params.lum_bounds = {[0.5 0 0; 0.5 0.5 0.5; 1 0.5 0.5]'};
%
%   IMG = GERT_RenderDisplay(@GERT_DrawElement_Gabor,all_els,gabel_params,img_params);
%   imshow(IMG);
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

%% Check all arguments
fnc_name = 'GERT_RenderDisplay';

% Three or four argments needed
if nargin ~= 3 && nargin ~= 4
    msg = 'At least three input arguments needed';
    GERT_ShowError(fnc_name,msg,3);
end

% 'el_fnc' - required
if ~isa(el_fnc, 'function_handle')
    msg = 'Input argument ''el_fnc'' must be a function handle';
    GERT_ShowError(fnc_name,msg,3);
end

% 'elements' - required
if ~isa(elements,'GElements') || ~isscalar(elements)
    msg = 'Input argument ''elements'' must be a 1x1 GElements';
    GERT_ShowError(fnc_name,msg,3);
end

% 'el_params' - required
if ~isstruct(el_params) || ~isscalar(el_params)
    msg = 'Input argument ''el_params'' must be a 1x1 struct';
    GERT_ShowError(fnc_name,msg,3);
end

% 'img_params' - optional
if ~exist('img_params','var')
    img_params.dims = [];
    img_params.bg_lum = 0.5;
    img_params.blend_mode = 'None';
    img_params.global_rendering = false;
end

if ~isstruct(img_params) || ~isscalar(img_params)
    msg = 'If provided, input argument ''img_params'' must be a 1x1 struct';
    GERT_ShowError(fnc_name,msg,3);
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',el_fnc,'IN_el_fnc');
GERT_log = add(GERT_log,'var',elements,'IN_elements');
GERT_log = add(GERT_log,'var',el_params,'IN_el_params');
GERT_log = add(GERT_log,'var',img_params,'IN_img_params');

%% Parse the input
% Parse 'elements'
elements = validate(elements);
el_n = elements.n;
if el_n == 0
    msg = 'No elements found in ''elements''.';
    GERT_ShowError(fnc_name,msg,3);
end

if isempty(elements.dims)
    msg = 'No display dimensions found in ''elements''.';
    GERT_ShowError(fnc_name,msg,3);
end

cdims = elements.dims;
el_x = elements.x;
el_y = elements.y;

% Process 'el_params' - a struct of 1xelement.n vectors and scalars
% We won't parse it or check its specific fields, that's up to the drawing
% function
elp_fields = fieldnames(el_params);
n_elp_fields = length(elp_fields);

for f = 1:n_elp_fields
    vec = el_params.(elp_fields{f});
    if (length(vec) ~= el_n && length(vec) ~= 1) || size(vec,1) ~= 1
        msg = strcat('The el_params struct should only contain 1x1 or 1xelement.n fields. E',...
            'lement parameter fields consisting of more than one value must be converted to a 1x1 cell scalar.');
        GERT_ShowError(fnc_name,msg,3);
    end
    
    if iscell(vec)
        for i = 1:length(vec)
            if iscell(vec{i})
                msg = '''el_param'' fields cannot be cells within cells.';
                GERT_ShowError(fnc_name,msg,3);
            elseif isstruct(vec{i})
                msg = '''el_param'' fields cannot themselves be structs.';
                GERT_ShowError(fnc_name,msg,3);
            end
        end
    else
        if isstruct(vec)
            msg = '''el_param'' fields cannot themselves be structs.';
            GERT_ShowError(fnc_name,msg,3);
        end
    end
end

% Parse 'img_params'
p = GStructParser;
p = addfield(p,'dims', [], @(x) isempty(x) || (GERT_Aux_ValidVec(x,'double',2) ...
    && all(mod(x,1)==0) && all(x>1) ));
p = addfield(p,'bg_lum', 0.5, @(x) (GERT_Aux_ValidVec(x,'double',1) || ...
    GERT_Aux_ValidVec(x,'double',3)) && all(x>=0) && all(x<=1));
p = addfield(p,'blend_mode', 'None',@(x) GERT_Aux_ValidVec(x,'char'));
p = addfield(p,'global_rendering', false,@(x) isscalar(x) && isa(x,'logical'));

p = parse(p,img_params);

% If no pixel dimensions are specified, try to use the element display
% dimensions. If those don't work, throw an error.
if isempty(p.results.dims)
    if cdims(1) == 1 && cdims(2)>1 && mod(cdims(2),1)==0 && cdims(3) == 1 && cdims(4)>1 && mod(cdims(4),1)==0
        pdims(1) = cdims(2);
        pdims(2) = cdims(4);
    else
        msg = 'The display dimensions of the ''elements'' struct are invalid as pixel dimensions. Please adapt them, or explicitly pass an ''img_params.dims'' argument to rescale from these dimensions.';
        GERT_ShowError(fnc_name,msg,3);
    end
else
    pdims = p.results.dims;
end

if ~strcmp(p.results.blend_mode,'MaxDiff') && ~strcmp(p.results.blend_mode,'None')
    msg = strcat('Unknown blend mode: ', p.results.blend_mode);
    GERT_ShowError(fnc_name,msg,3);
end

bg_lum = p.results.bg_lum;
blend_mode = p.results.blend_mode;
global_rendering = p.results.global_rendering;


%% Define the size of the drawing canvas
min_cpos_h = cdims(1);
min_cpos_v = cdims(3);
max_cpos_h = cdims(2);
max_cpos_v = cdims(4);
spread_cpos_h = max_cpos_h-(min_cpos_h-1);
spread_cpos_v = max_cpos_v-(min_cpos_v-1);

min_ppos_x = 1;
min_ppos_y = 1;
max_ppos_x = pdims(1);
max_ppos_y = pdims(2);
spread_ppos_x = max_ppos_x - (min_ppos_x-1);
spread_ppos_y = max_ppos_y - (min_ppos_y-1);

%% Prepare the image to a blank display
if size(bg_lum,2) == 3
    IMG = ones(spread_ppos_x,spread_ppos_y,3);
    IMG(:,:,1) = IMG(:,:,1) * bg_lum(1);
    IMG(:,:,2) = IMG(:,:,2) * bg_lum(2);
    IMG(:,:,3) = IMG(:,:,3) * bg_lum(3);
else
    IMG = ones(spread_ppos_x,spread_ppos_y)*bg_lum;
end

%% Construct the individual parameter structs, and hash them
el_ids = zeros(1,el_n);
el_ps = cell(1,el_n);

vecidx = [];
scalidx = [];
for f = 1:n_elp_fields
    vec = el_params.(elp_fields{f});
    
    if length(vec) == el_n
        vecidx = [vecidx f];
    else
        scalidx = [scalidx f];
    end
end

% First, hash the scalar values
if global_rendering
    hashtmp2 = zeros(1,length(scalidx));
    hashn = 0;
    for f = scalidx
        val = el_params.(elp_fields{f});
        hashn = hashn + 1;
        
        valt = val;
        if iscell(valt)
            valt = valt{1};
        end
        
        if isnumeric(valt)
            if size(valt,1)~=1
                valt = reshape(valt,1,[]);
            end
            hashtmp2(hashn) = GERT_Aux_UniqueID(valt);
        
        elseif ischar(valt)
            if size(valt,1)~=1
                valt = reshape(valt,1,[]);
            end
            hashtmp2(hashn) = GERT_Aux_UniqueID(valt);
            
        elseif isa(valt,'GContour')
            for i = 1:length(valt)
                hashtmp2(hashn) = hashtmp2(hashn) + hash(valt(i));
            end
            
        else
            msg = 'Variable type is not hashed, global rendering might not work.';
            GERT_ShowError(fnc_name,msg,1);          
        end
    end
    scal_id = sum(hashtmp2)/hashn;
    if isnan(scal_id)
        scal_id = 0;
    end
end

% Then, hash the variable parameters
vec = cell(1,n_elp_fields);
vecl = zeros(1,n_elp_fields);
defs = struct;
for f = 1:n_elp_fields
    vec{f} = el_params.(elp_fields{f});
    vecl(f) = length(vec{f});
    if vecl(f) == el_n && el_n>1
        defs.(elp_fields{f})=[];
    elseif vecl(f) == 1 
        defs.(elp_fields{f}) = vec{f};
    else
    	msg = strcat('The el_params struct should only contain 1x1 or 1xelement.n fields. E',...
       	'lement parameter fields consisting of more than one value must be converted to a 1x1 cell scalar.');
        	GERT_ShowError(fnc_name,msg,3);
    end
    
end
for i = 1:el_n
    
    % Construct the parameter struct for this element
    el_ps{i} = defs;
    
    % Run through the fields, retrieve what we need
    hashtmp = zeros(1,length(vecidx)+1);
    hashn = 0;
    for f = 1:n_elp_fields
        
        if vecl(f) ~= 1
            hashn = hashn + 1;
            val = vec{f}(i);
            
            if global_rendering
                valt = val;
                if iscell(valt)
                    valt = valt{1};
                end
                    
                if isnumeric(valt)
                    if size(valt,1)~=1
                        valt = reshape(valt,1,[]);
                    end
                    hashtmp(hashn) = GERT_Aux_UniqueID(valt);
                    
                elseif ischar(valt)
                    if size(valt,1)~=1
                        valt = reshape(valt,1,[]);
                    end
                    hashtmp(hashn) = GERT_Aux_UniqueID(valt);
                    
                elseif isa(valt,'GContour')
                    for j = 1:length(valt)
                        hashtmp(hashn) = hashtmp(hashn) + hash(valt(j));
                    end
                    
                else
                    msg = 'Variable type is not hashed, global rendering might not work.';
                    GERT_ShowError(fnc_name,msg,1);
                end
            end
            
            el_ps{i}.(elp_fields{f}) = val;
        end
        
    end
    
    if global_rendering
        hashtmp(hashn+1) = scal_id; % Add the scalar values
        el_ids(i) = sum(hashtmp)/(hashn+1);
        
        if isnan(el_ids(i))
            el_ids(i) = 0;
        end
    end
end

%% Render the image patches
global GERT_glob_el_ids;
global GERT_glob_el_patches;

if global_rendering
    % Find out which structs were unique
    [el_ids, foo, el_id_idx] = unique(el_ids);
    el_ps = el_ps(foo);
    
    glob_n = length(GERT_glob_el_ids);
    or_el_ids = el_ids;
    or_n = length(or_el_ids);
    
    % Detect which patches are truly new
    if glob_n
        [foo new_idx faa] = setxor(or_el_ids,GERT_glob_el_ids);
    else
        new_idx = 1:length(or_el_ids);
    end
    new_n = length(new_idx);
    
    % Find out what the indices are to the re-used patches
    [foo, all_idx] = ismember(or_el_ids, GERT_glob_el_ids );
    
    % Render the new patches
    el_patches = cell(1,glob_n + new_n);
    el_ids = zeros(1,glob_n+new_n);
    el_patches(1:glob_n) = GERT_glob_el_patches;
    el_ids(1:glob_n) = GERT_glob_el_ids;
    
    for i = 1:new_n
        el_patches(glob_n+i) = {el_fnc(el_ps{new_idx(i)})};
        el_ids(glob_n+i) = or_el_ids(new_idx(i));
        all_idx(new_idx(i)) = glob_n+i;
    end
    
    %msg = char(strcat({'Unique patches added: '},num2str(new_n), '/', num2str(el_n)));
    %GERT_Log_Add('msg',msg);
    %disp(msg);
    
    % Store the new patches in global space
    GERT_glob_el_patches = el_patches;
    GERT_glob_el_ids = el_ids;
    
    % Prepare the indices for drawing all elements
    el_id_idx = all_idx(el_id_idx);
    
else
    
    % Render every unique patch
    el_patches = cell(1,length(el_ps));
    el_id_idx = 1:length(el_ps);
    for i = el_id_idx
        el_patches(i) = {el_fnc(el_ps{i})};
    end
    
    %msg = char(strcat({'Unique image patches: '},num2str(length(el_ps)), '/', num2str(el_n)));
    %GERT_Log_Add('msg',msg);
    %disp(msg);
    
end

%% Now place them in the image
pospix.x = zeros(1,el_n);
pospix.y = zeros(1,el_n);
for i = 1:el_n
    % Retrieve the relevant image patch
    this_el_img = el_patches{el_id_idx(i)};
    
    % Convert from canvas coordinates to pixel ccordinates
    x_cpos = el_x(i);
    y_cpos = el_y(i);
    x_ppos = min_ppos_x + ((x_cpos-min_cpos_h)*((spread_ppos_x-1)/(spread_cpos_h-1)));
    y_ppos = min_ppos_y + ((y_cpos-min_cpos_v)*((spread_ppos_y-1)/(spread_cpos_v-1)));
    x_ppos = floor(x_ppos);
    y_ppos = floor(y_ppos);
    
    % Save the pixel coordinates
    pospix.x(i) = x_ppos;
    pospix.y(i) = y_ppos;
    
    if ~mod(size(this_el_img,1),2) || ~mod(size(this_el_img,2),2)
        msg = 'Element patch size must be uneven. Please adapt your drawing function accordingly.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    if size(bg_lum,2) ~= size(this_el_img,3)
        msg = 'Color/grayscale images require a corresponding color/grayscale output from the element drawing function.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    el_hsize_x = floor(size(this_el_img,1)/2);
    el_hsize_y = floor(size(this_el_img,2)/2);
    
    % Crop or drop if the element falls outside the image
    lc = x_ppos-el_hsize_x; rc = x_ppos+el_hsize_x;
    tc = y_ppos-el_hsize_y; bc = y_ppos+el_hsize_y;
    bnd = [lc max_ppos_x tc max_ppos_y] - [1 rc 1 bc];
    
    if any(bnd<0)
        
        cropby = abs(bnd).*(bnd<0);
        
        if any(cropby(1:2) > (el_hsize_x*2)+1) || any(cropby(3:4) > (el_hsize_y*2)+1)
            this_el_img = [];
        else
            lc = lc + cropby(1);
            rc = rc - cropby(2);
            tc = tc + cropby(3);
            bc = bc - cropby(4);
            
            this_el_img = this_el_img(1+cropby(1):end-cropby(2),1+cropby(3):end-cropby(4),:);
        end
        
        dropmsg = 'Some elements did not fit within the image, and have been cropped or dropped.';
    end
    
    % Color images
    if size(bg_lum,2) == 3 && ~isempty(this_el_img)
        if strcmp(blend_mode,'MaxDiff')
            
            old_image = IMG(lc:rc,tc:bc,:);
            sz(1) = size(this_el_img,1);
            sz(2) = size(this_el_img,2);
            thistmp = (abs(this_el_img(:,:,1)-bg_lum(1)) + abs(this_el_img(:,:,2)-bg_lum(2)) + abs(this_el_img(:,:,3)-bg_lum(3))/3);
            oldtmp = (abs(old_image(:,:,1)-bg_lum(1)) + abs(old_image(:,:,2)-bg_lum(2)) + abs(old_image(:,:,3)-bg_lum(3))/3);
            tmp = thistmp<oldtmp;
            idx = false(sz(1),sz(2),3);
            idx(:,:,1) = tmp; idx(:,:,2) = tmp; idx(:,:,3) = tmp;
            this_el_img(idx) = old_image(idx);           

        elseif strcmp(blend_mode,'None')
            % Do nothing
        else
            msg = char(strcat(blend_mode, {' is an unrecognized blend mode for color images.'}));
            GERT_ShowError(fnc_name,msg,3);
        end
        % Paste image patch into the overall image
        IMG(lc:rc,tc:bc,:) = this_el_img;
        
    %Greyscale images
    elseif size(bg_lum,2) == 1 && ~isempty(this_el_img)
        % Maxdiff blendmode
        
        if strcmp(blend_mode,'MaxDiff')
            old_image = IMG(lc:rc,tc:bc);
            idx = abs(this_el_img-bg_lum) < abs(old_image-bg_lum);
            this_el_img(idx) = old_image(idx);
        
        elseif strcmp(blend_mode,'None')
            % Do nothing
        else
            msg = char(strcat(blend_mode, {' is an unrecognized blend mode for greyscale images.'}));
            GERT_ShowError(fnc_name,msg,3);
        end
        
        % Paste image patch into the overall image
        IMG(lc:rc,tc:bc) = this_el_img;
    end
    
end

% Make the image correspond to the plots
oldIMG = IMG;
clear IMG;
for layer = 1:size(oldIMG,3)
    IMG(:,:,layer) = oldIMG(:,:,layer)';
    IMG(1:end,:,layer) = IMG(end:-1:1,:,layer);
end

% Clear the global variable GERT_gab_scale_ids
% Used by GERT_DrawElement_Gabor
clear global GERT_gab_scale_ids

% Give a warning if some elements did not fit into the image
if exist('dropmsg','var')
    GERT_ShowError(fnc_name,dropmsg,1);
    GERT_log = add(GERT_log,'msg',dropmsg);
end

%% Log the output
% We are not saving the image in the log
GERT_log = add(GERT_log,'var',pospix,'OUT_pospix');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done