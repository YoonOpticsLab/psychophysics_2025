function all_elements = GERT_PlaceElements_Background(fixed_points, region, params)

% all_elements = GERT_PlaceElements_Background(fixed_points, region, params)
%
% DESCRIPTION:
%  This function will randomly place background elements around a series of
%  existing FIXED_POINTS, respecting a MIN_DIST from other elements. If
%  it is a GElements object, these elements will be added to ALL_ELEMENTS;
%  if it is a Gcontour object, they will not. A REGION defined as one or
%  more closed GContour objects can also be passed, to restrict the region
%  inside which elements should be placed.
%
% ARGUMENTS:
%  fixed_points -------------- pass [] to skip, default: empty fields
%                              1xN GElements, GContour or cell
%
%  region -------------------- pass [] to skip, default: empty fields
%                              1xM GContour or cell
%
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- min_dist ----------- required
%      |                       1x1 or 1xN+1 double
%      |                        >=0, finite, real
%      |
%      |- dims --------------- optional, can be taken from fixed_points
%      |                       1x4 double
%      |                       (1)<(3)&&(2)<(4), finite, real
%      |
%      |- bg_n --------------- optional, default: minus 1
%      |                       1x1 double
%      |                       >0 or minus 1, integer value, finite, real
%      |
%      |- timeout ------------ optional, default: 60
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- batch_size --------- optional, default: 200
%      |                       1x1 double
%      |                       >0, integer value, finite, real
%      |
%      |- border_dist -------- optional, default: min_dist+1
%      |                       1x1 double
%      |                       >=0 <dims/2, finite, real
%      |
%      |- in_region ---------- optional, default: true
%      |                       1x1 logical
%      |                       true or false
%      |
%      |- resolution --------- optional, default: 500
%                              1x1 double
%                              >1, integer value, finite, real
%
% RETURNS:
%  all_elements -------------- 1x1 GElements
%
% DETAILS:
%  By default, element placement will continue until the display is filled
%  with elements. A hard limit to the number of elements added can be set
%  using the BG_N parameter. The function will also stop when a TIMEOUT
%  is reached (default: 60s). To change the distance kept from the border
%  of the display, set BORDER_DIST to a value other than the default
%  MIN_DIST+1.
%  If more than one MIN_DIST value is provided, these will refer to the
%  various distances kept from the FIXED_POINTS positions. If only one
%  value is provided, the same distance will be kept from other background
%  points as is kept from the FIXED_POINTS.
%  The DIMS variable uses arbitrary units; however whenever
%  feasible, the most accurate results will be obtained when the canvas
%  dimensions used here correspond to the final pixel dimensions, due to
%  possible rounding errors.
%  Performance is negatively affected by the RESOLUTION at which element
%  placement operates, i.e. the number of possible positions on the largest
%  dimension. This parameter defaults to 500. Up to a point, increasing the 
%  BATCH_SIZE of the number of elements placed at once will increase 
%  performance. The ideal value depends on the other parameters, but values 
%  between 50 and 250 are good for most purposes (default: 200).
%
% EXAMPLE: 
% 1) With fixed elements
%   contour = GERT_GenerateContour_RFP(params);
%   cont_els = GERT_PlaceElements_Contour(contour, pec_params);
%   peb_params.dims = [-45 45 -45 45];
%   peb_params.min_dist = 1.5;
%   all_els = GERT_PlaceElements_Background(cont_els,[],peb_params);
%
% 2) Without fixed elements, and a bg_n limit
%   peb_params.dims = [-45 45 -45 45];
%   peb_params.min_dist = 1.5;
%   peb_params.bg_n = 500;
%   all_els = GERT_PlaceElements_Background([],[],peb_params);
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
global GERT_matlv;
b_ml = strcmp(GERT_matlv{1},'Matlab');

%% Check the arguments
fnc_name = 'GERT_PlaceElements_Background';

% Three arguments required
if nargin ~= 3
    msg = 'Three input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'fixed_points' - optional, pass [] to skip
if ~isempty(fixed_points) && ~GERT_Aux_ValidVec(fixed_points,'GElements') && ...
      ~GERT_Aux_ValidVec(fixed_points,'GContour') && ... 
      ~GERT_Aux_ValidVec(fixed_points,'cell') 
    msg = 'Input argument ''fixed_points'' must be a 1xN GElements, GContour or cell object.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'region' - optional, pass [] to skip
if ~isempty(region) && ~GERT_Aux_ValidVec(region,'GContour') && ~GERT_Aux_ValidVec(region,'cell')
    msg = 'Input argument ''region'' must be a 1xN GContour or cell object.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'params' - required
if ~isstruct(params) || ~isscalar(params)
    msg = 'Input argument ''params'' must be a 1x1 struct.';
    GERT_ShowError(fnc_name,msg,3);
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',fixed_points,'IN_fixed_points');
GERT_log = add(GERT_log,'var',region,'IN_region');
GERT_log = add(GERT_log,'var',params,'IN_params');

%% Parse the input
% Parse 'fixed_points'
if ~isempty(fixed_points)
    for i = 1:length(fixed_points)
        if iscell(fixed_points(i))
            fixed_points{i} = validate(fixed_points{i});
        else
            fixed_points(i) = validate(fixed_points(i));
        end
    end
end

% Parse 'region'
if ~isempty(region)
    for i = 1:length(region)
        if iscell(region)
            region{i} = validate(region{i});
        else
            region(i) = validate(region(i));
        end
    end
end

% Parse 'params'
p = GStructParser;
p = addfield(p,'dims', [], @(x) isempty(x) || GERT_Aux_ValidVec(x,'double',4));
p = addfield(p,'min_dist', 'req', @(x) GERT_Aux_ValidVec(x,'double') && ...
    all(x>=0));
p = addfield(p,'bg_n', -1, @(x) GERT_Aux_ValidVec(x,'double',1) && ...
    (x>0 || x==-1) && mod(x,1)==0);
p = addfield(p,'timeout', 60, @(x) GERT_Aux_ValidVec(x,'double',1) && x>0);
p = addfield(p,'border_dist', [], @(x) isempty(x) || ...
    (GERT_Aux_ValidVec(x,'double',1) && x>=0));
p = addfield(p,'batch_size', 200, @(x) GERT_Aux_ValidVec(x,'double',1) && ...
    x>1 && mod(x,1)==0);
p = addfield(p,'in_region',true, @(x) isscalar(x) && isa(x,'logical') );
p = addfield(p,'resolution', 500, @(x) ...
    GERT_Aux_ValidVec(x,'double',1) && x>1);

p = parse(p,params);

if ~isscalar(p.results.min_dist) && length(p.results.min_dist) ~= length(fixed_points)+1
    msg = '''min_dist'' must be scalar or of size 1xN+1, where N is the number of ''fixed_points'' objects.';
    GERT_ShowError(fnc_name,msg,3);
end

dims = p.results.dims;
res = p.results.resolution;
bg_n = p.results.bg_n;
min_dist = p.results.min_dist;
border_dist = p.results.border_dist;
batch_size = p.results.batch_size;
in_region = p.results.in_region;
timeout = p.results.timeout;

%% Initialize everything
% This is where the generated points will end up
bg_elements = GElements;

% Set border_dist to default if not specified
if isempty(border_dist)
    border_dist = min_dist(1)+1;
end

% Determine dims 
if isempty(dims) && ~isempty(fixed_points)
    for i = 1:length(fixed_points)
        if isa(fixed_points,'cell')
            tmp = fixed_points{i};
        else
            tmp = fixed_points(i);
        end
        
        if tmp.n && isa(tmp,'GElements')
           if isempty(dims) && ~isempty(tmp.dims)
                dims = tmp.dims;
           end
        end
    end
end

if isempty(dims)
    msg = '''Dims'' must be specified either in ''fixed_points'' or ''args2{2}''';
    GERT_ShowError(fnc_name,msg,3);
end

% Leave out the border region, we will add it back in at the end
h_or = dims(2) - (dims(1)-1) - (2*border_dist);
v_or = dims(4) - (dims(3)-1) - (2*border_dist);

% Make sure we have a pool to fill
if h_or <= 0 || v_or <=0
    msg = 'Effective display size is 0 or negative. Adjust ''params.dims'' or ''params.border_dist''';
    GERT_ShowError(fnc_name,msg,3);
end

% Scale the largest dimension to equal 'params.resolution'
if h_or >= v_or
    h_res = res;
    v_res = round((v_or/h_or) * res);
else
    v_res = res;
    h_res = round((h_or/v_or) * res);
end

% Convert the minimum distance between elements
min_dist = ceil(min_dist*(h_res/h_or));

% Convert the fixed element coordinates, separately for contour and
% element objects
fc_idx = []; fe_idx = [];
fc.x = []; fc.y = []; fc.tag = [];
fe.x = []; fe.y = []; fe.tag = [];
fe_or = GElements;
if ~isempty(fixed_points)
    
    for i = 1:length(fixed_points)
        
        if isa(fixed_points,'cell')
            tmp = fixed_points{i};
        else
            tmp = fixed_points(i);
        end
        
        if tmp.n && isa(tmp,'GElements')
            
            if ~isempty(p.results.dims)
               tmp.dims = []; %Avoid irrelevant warning message when merging
            end
            
            if fe_or.n
                fe_or = GERT_MergeElements({fe_or tmp});
            else
                fe_or = tmp;
            end
            
            fe.x = [fe.x 1+floor(abs((tmp.x-dims(1)-border_dist)*((h_res-1)/(h_or-1))))];
            fe.y = [fe.y 1+floor(abs((tmp.y-dims(3)-border_dist)*((v_res-1)/(v_or-1))))];
            fe.tag = [fe.tag ones(1,length(tmp.x))*(i+1)];
            fe_idx(end+1) = i+1;
            
            if any(fe.x<1) || any(fe.x>h_res) || any(fe.y<1) ||any(fe.y>v_res)
                msg = 'Some fixed elements fall outside the display dimensions';
                GERT_ShowError(fnc_name,msg,3);
            end
            
        elseif isa(tmp,'GContour')
            
            fc.x = [fc.x 1+floor(abs((tmp.x-dims(1)-border_dist)*((h_res-1)/(h_or-1))))];
            fc.y = [fc.y 1+floor(abs((tmp.y-dims(3)-border_dist)*((v_res-1)/(v_or-1))))];
            fc.tag = [fc.tag ones(1,length(tmp.x))*(i+1)];
            fc_idx(end+1) = i+1;
            
        else
            msg = 'Invalid ''fixed_points'' type, or empty description';
            GERT_ShowError(fnc_name,msg,3);
        end
        
    end
end

% Handle the setting of bg_n
if bg_n > 0
    %  Do nothing
elseif bg_n == -1
    bg_n = 1 + (h_res*v_res);  % This limit will never be hit
else
    msg = '''params.bg_n'' is set to an invalid value. Set to a positive integer, or -1 to remove the limit to the number of elements';
    GERT_ShowError(fnc_name,msg,3);
end

% If region is a GContour, combine its inpolygon with the pool
if ~isempty(region)

    if in_region
        io = false(h_res,v_res);
    else
        io = true(h_res,v_res);
    end
    
    for i = 1:length(region)
        
        if iscell(region)
            reg = region{i};
        else
            reg = region(i);
        end
        
        if reg.n
            cont.y = 1+floor(abs((reg.x-dims(1)-border_dist)*((h_res-1)/(h_or-1))));
            cont.x = 1+floor(abs((reg.y-dims(3)-border_dist)*((v_res-1)/(v_or-1))));
            
            if in_region
               io = io | poly2mask(cont.x,cont.y,h_res,v_res);
            else
               io = io & ~poly2mask(cont.x,cont.y,h_res,v_res);
            end
        end
    end
end

% Starting pool of possible positions: no restrictions yet
try
    pool = true(h_res, v_res);
catch %ME
    msg = '''params.resolution'' exceeds system resources.';
    GERT_ShowError(fnc_name,msg,3);%4,ME);
end

% Combine with the regions
if ~isempty(region)
    pool = pool & io;
end

% Create a disk with a radius equal to min_dist
% to dilate white pixels in a binary image with
if b_ml
    dilate_disk = strel('disk',min_dist(1),0);
else
    [idx1,idx2] = meshgrid(-ceil(min_dist(1)):ceil(min_dist(1)));
    dilate_disk = sqrt((idx1.^2) + (idx2.^2)) < min_dist(1);   
end

try
    sel_points_pool = false(h_res, v_res);
catch %ME
    msg = '''params.resolution'' exceeds system resources.';
    GERT_ShowError(fnc_name,msg,3);%4,ME);
end

%% Place existing elements
if ~isempty(fe_idx)
    
    for i = 1:length(fe_idx)
        if isscalar(min_dist)
            if b_ml
                fp_disk = strel('disk',min_dist,0);
            else
                [idx1,idx2] = meshgrid(-ceil(min_dist):ceil(min_dist));
                fp_disk = sqrt((idx1.^2) + (idx2.^2)) < min_dist;   
            end
            fx = 1;
        else
            if b_ml
                fp_disk = strel('disk',min_dist(fe_idx(i)),0);
            else
                [idx1,idx2] = meshgrid(-ceil(min_dist(fe_idx(i))):ceil(min_dist(fe_idx(i))));
                fp_disk = sqrt((idx1.^2) + (idx2.^2)) < min_dist(fe_idx(i));
            end
            fx = fe_idx(i);
        end
        
        if b_ml
            % Mark the fixed elements with single white pixels in a sea of
            % black
            sel_points_pool(sub2ind([h_res v_res],fe.x(fe.tag==fe_idx(i)),fe.y(fe.tag==fe_idx(i)))) = true;
            % Dilate them using the disk with the min_dist radius
            sel_points_pool  = imdilate(sel_points_pool,fp_disk);
        else
            % For Octave, paste the disks onto the logical image manually
            idx = find(fe.tag == fe_idx(i));
            for j = idx
                lc = fe.x(j)-ceil(min_dist(fx));
                rc = fe.x(j)+ceil(min_dist(fx));
                tc = fe.y(j)-ceil(min_dist(fx));
                bc = fe.y(j)+ceil(min_dist(fx));
                bnd = [lc h_res tc v_res] - [1 rc 1 bc];
                this_disk = fp_disk;
                if any(bnd<0)
                    
                    cropby = abs(bnd).*(bnd<0);
                    
                    if any(cropby(1:2) > (ceil(min_dist(fx))*2)+1) || any(cropby(3:4) > (ceil(min_dist(fx))*2)+1)
                        this_disk = [];
                    else
                        lc = lc + cropby(1);
                        rc = rc - cropby(2);
                        tc = tc + cropby(3);
                        bc = bc - cropby(4);
                        
                        this_disk = this_disk(1+cropby(1):end-cropby(2),1+cropby(3):end-cropby(4),:);
                    end
                end
                
                sel_points_pool(lc:rc,tc:bc) = sel_points_pool(lc:rc,tc:bc) | this_disk;
            end
        end
        
        % Subtract them from the overall pool of possible positions
        pool = pool & ~sel_points_pool;
        sel_points_pool = false(h_res, v_res);
    end
    
end

%% Zone around existing contours
if ~isempty(fc_idx)
    
    for i = 1:length(fc_idx)
        
        if isscalar(min_dist)
            if b_ml
                fp_disk = strel('disk',min_dist,0);
            else
                [idx1,idx2] = meshgrid(-ceil(min_dist):ceil(min_dist));
                fp_disk = sqrt((idx1.^2) + (idx2.^2)) < min_dist;   
            end
            fx = 1;
        else
            if b_ml
                fp_disk = strel('disk',min_dist(fc_idx(i)),0);
            else
                [idx1,idx2] = meshgrid(-ceil(min_dist(fc_idx(i))):ceil(min_dist(fc_idx(i))));
                fp_disk = sqrt((idx1.^2) + (idx2.^2)) < min_dist(fc_idx(i));
            end
            fx = fc_idx(i);
        end
        
       if b_ml
            sel_points_pool(sub2ind([h_res v_res],fc.x(fc.tag==fc_idx(i)),fc.y(fc.tag==fc_idx(i)))) = true;
            sel_points_pool  = imdilate(sel_points_pool,fp_disk);
       else
            idx = find(fc.tag == fc_idx(i));
            for j = idx
                lc = fc.x(j)-ceil(min_dist(fx));
                rc = fc.x(j)+ceil(min_dist(fx));
                tc = fc.y(j)-ceil(min_dist(fx));
                bc = fc.y(j)+ceil(min_dist(fx));
                bnd = [lc h_res tc v_res] - [1 rc 1 bc];
                this_disk = fp_disk;
                if any(bnd<0)
                    
                    cropby = abs(bnd).*(bnd<0);
                    
                    if any(cropby(1:2) > (ceil(min_dist(fx))*2)+1) || any(cropby(3:4) > (ceil(min_dist(fx))*2)+1)
                        this_disk = [];
                    else
                        lc = lc + cropby(1);
                        rc = rc - cropby(2);
                        tc = tc + cropby(3);
                        bc = bc - cropby(4);
                        
                        this_disk = this_disk(1+cropby(1):end-cropby(2),1+cropby(3):end-cropby(4),:);
                    end
                end
                
                sel_points_pool(lc:rc,tc:bc) = sel_points_pool(lc:rc,tc:bc) | this_disk;
            end
        end
        
        % Subtract them from the overall pool of possible positions
        pool = pool & ~sel_points_pool;
        sel_points_pool = false(h_res, v_res);
    end
    
end

%% Start placing background points
tstart=tic; % Fasten your seatbelts
while bg_elements.n < bg_n
    % Determine which positions are still possible
    remaining_idx = find(pool);
    
    % Stop if none
    if isempty(remaining_idx)
        if p.results.bg_n > 0
            msg = strcat('The display is full. The target of ',num2str(bg_n),' elements was not reached.');
            GERT_ShowError(fnc_name,msg,1);
        end
        break;
    end
    
    % Stop if time-out has been exceeded
    if b_ml
        time_elapsed = toc(tstart);
    else
        time_elapsed = (double(tic) - double(tstart)) * 1e-6;
    end

    if time_elapsed > timeout
        msg = strcat('Timeout limit of ', num2str(timeout), ' seconds has been reached, quitting.');
        GERT_ShowError(fnc_name,msg,3);
        break;
    end
    
    % Don't sample too many points when we're near the params.bg_n limit
    batch_size = min([batch_size bg_n-bg_elements.n]);
    
    % Draw a batch of candidate points, keep only the unique ones
    cand_points = unique(remaining_idx( GERT_Aux_Randi(length(remaining_idx),[1 batch_size]) ));
    [cand_x,cand_y] = ind2sub([h_res v_res],cand_points);
    
    % Only go into Euclidean distances if there's more than one unique point
    if ~isscalar(cand_points)
        
        % Compute Euclidean distance between these candidate points
        dist_to_eachother = GERT_Aux_EuclDist(cand_x', cand_y', cand_x', cand_y');
        
        % Determine which points are too close to one another
        too_close = logical(dist_to_eachother<min_dist(1));
        
        % However we still want to keep as many points as possible
        % So we do the following: We only look at conflicts with the
        % previous candidate points. Therefore, we only retain what is
        % below the diagonal of the distance matrix.
        cand_n = size(dist_to_eachother,1);
        too_close = tril(too_close) & ~eye(cand_n);
        
        % Iterate over the candidates
        for i = 1:cand_n
            % If a point clashes with previous points, we won't keep it
            % So we can remove all of its clashes with the next points
            if any(too_close(i,:))
                too_close(:,i) = false;
            end
        end
        
        % Keep points that have no remaining clashes
        sel_points_idx = ~any(too_close,2)';
        
    else
        % If there is only one candidate point, we keep it of course
        sel_points_idx = true;
    end
    
    % Back to black, put the points, dilate, subtract
    if b_ml
        sel_points_pool(:) = false;
        sel_points_pool(cand_points(sel_points_idx)) = true;
        sel_points_pool = imdilate(sel_points_pool,dilate_disk);
    else
        % Octave: pasting
        sel_points_pool(:) = false;
        for j =find(sel_points_idx)
            lc = cand_x(j)-ceil(min_dist(1));
            rc = cand_x(j)+ceil(min_dist(1));
            tc = cand_y(j)-ceil(min_dist(1));
            bc = cand_y(j)+ceil(min_dist(1));
            bnd = [lc h_res tc v_res] - [1 rc 1 bc];
            this_disk = dilate_disk;
            if any(bnd<0)
                
                cropby = abs(bnd).*(bnd<0);
                
                if any(cropby(1:2) > (ceil(min_dist(1))*2)+1) || any(cropby(3:4) > (ceil(min_dist(1))*2)+1)
                    this_disk = [];
                else
                    lc = lc + cropby(1);
                    rc = rc - cropby(2);
                    tc = tc + cropby(3);
                    bc = bc - cropby(4);
                    
                    this_disk = this_disk(1+cropby(1):end-cropby(2),1+cropby(3):end-cropby(4),:);
                end
            end
            
            sel_points_pool(lc:rc,tc:bc) = sel_points_pool(lc:rc,tc:bc) | this_disk;
        end
    end

    pool = pool & ~sel_points_pool;
    
    % Save the new element positions
    old_n = bg_elements.n;
    new_n = sum(sel_points_idx);
    bg_elements.x(old_n+1:old_n+new_n) = cand_x(sel_points_idx);
    bg_elements.y(old_n+1:old_n+new_n) = cand_y(sel_points_idx);
end


%% Prepare the output struct  
% Undo effects of serial placement
[foo ix] = sort(rand(1,bg_elements.n));
bg_elements.x = bg_elements.x(ix);
bg_elements.y = bg_elements.y(ix);

% Set dims and n
if ~isempty(fe_idx)
    all_elements = fe_or;
    start_n = length(fe.x) + 1;
    stop_n = length(fe.x) + bg_elements.n;
else
    all_elements = GElements;
    start_n = 1;
    stop_n = bg_elements.n;
end
all_elements.dims = dims;

% Convert the results back to the original coordinate system
% Add the border simply by shifting the coordinates by border_dist
bg_or.x = ((bg_elements.x-1) * ((h_or-1)/(h_res-1)) ) + dims(1) + border_dist;
bg_or.y = ((bg_elements.y-1) * ((v_or-1)/(v_res-1)) ) + dims(3) + border_dist;

% Save all element coordinates
if bg_elements.n
    all_elements.x(start_n:stop_n) = bg_or.x;
    all_elements.y(start_n:stop_n) = bg_or.y;
    all_elements = settag(all_elements,'b',start_n:stop_n);
else
    msg = 'No elements were placed.';
    GERT_ShowError(fnc_name,msg,1);
end

%% Log the output
GERT_log = add(GERT_log,'var',all_elements,'OUT_all_elements');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done