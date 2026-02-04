function [res, resv] = GERT_CheckCue_LocalDensity(elements, idx1, idx2, params)

% [res, resv] = GERT_CheckCue_LocalDensity(elements, idx1, idx2, params)
%
% DESCRIPTION:
%  This function checks for an average local density cue in the display, 
%  and returns the result of a statistical significance test. The default
%  method is to compute surface areas of the cells in a Voronoi diagram, 
%  and perform a Monte Carlo permutation test to determine whether these 
%  surface areas differ significantly between contour element and background
%  elements. However other methods are also available, both for measuring
%  local density and for performing the statistical test. If a second output
%  argument is provided, a density variability cue will be computed as well.
%
% ARGUMENTS:
%  elements ------------------ required
%                              1x1 GElements
%       
%  idx1 ---------------------- required
%                              1xM double
%                              M>1, >0, integer value, finite, real
%       
%  idx2 ---------------------- required
%                              1xM double
%                              M>1, >0, integer value, finite, real
%
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- method_dens -------- optional, default: 'Voronoi'
%      |                       1xM char array
%      |                       'AvgDist', 'RadCount', or 'Voronoi'
%      |
%      |- method_stat -------- optional, default: 'MC'
%      |                       1xM char array
%      |                       'MC' or 'T'
%      |
%      |- var_steps ---------- optional, default: 25
%      |                       1x1 double
%      |                       >0, integer value, finite, real
%      |
%     METHOD_DENS: 'Voronoi'
%      |
%      |- border_dist -------- required
%      |                       1x1 double
%      |                       >=0, finite, real
%      |
%     METHOD_DENS: 'AvgDist'
%      (in addition to all 'Voronoi' parameters) 
%      |
%      |- avg_n -------------- optional, default: 3
%      |                       1x1 double
%      |                       >=0, integer value, finite, real
%      |
%     METHOD_DENS: 'RadCount'
%      (in addition to all 'Voronoi' parameters) 
%      |
%      |- rad ---------------- required
%      |                       1xM double
%      |                       >0, finite, real
%      |
%     METHOD_STAT: 'T'
%      | 
%      |- alpha -------------- optional, default: 0.1
%      |                       1x1 double
%      |                       0 <= alpha <= 1, finite, real
%      |
%     METHOD_STAT: 'MC'
%      | 
%      |- alpha -------------- optional, default: 0.35
%      |                       1x1 double
%      |                       0 <= alpha <= 1, finite, real
%      |
%      |- mc_samples_n ------- optional, default: 1000
%      |                       1x1 double
%      |                       >100, integer value, finite, real
%
% RETURNS:
%  res ----------------------- 1x1 struct
%      |
%      |- pm ------------------ 1x1 double
%      |
%      |- hm ------------------ 1x1 double
%      |
%      |- c1 ------------------ 1xN double
%      |
%      |- c2 ------------------ 1xM double
%
%  resv ---------------------- 1x1 struct
%      |
%      |- pm ------------------ 1x1 double
%      |
%      |- hm ------------------ 1x1 double
%      |
%      |- c1 ------------------ 1xN double
%      |
%      |- c2 ------------------ 1xM double
%
% DETAILS:
%  The exact workings of this function depend on METHOD_DENS and
%  METHOD_STAT. 'Voronoi' is the default method to determine local density.
%  The 'Voronoi' method decomposes the display into polygon cells, each
%  enclosing a portion of space that is closer to a particular element in
%  the display than to any other element. The surface of these cells is
%  then compared between elements belonging to the contour and elements
%  belonging to the background. The indices of contour and background
%  elements need to be explicitly defined as two separate row vectors IDX1
%  and IDX2. In the 'AvgDist' option, GERT computes the average distance of
%  each element to its AVG_N nearest neighbours. The observed difference in
%  mean is then compared between the series of contour and background
%  elements. If avg_n is set to 0, a Delaunay triangulation will be
%  performed to determine the number of natural neighbours for each element.
%  The 'RadCount' method counts the number of elements within a
%  certain radius RAD of each point included in the element list. When a 
%  vector is provided, the total difference between two curves is computed.
%  For all 3 density measures, a BORDER_DIST needs to be defined,
%  indicating how far an element should be away from the edge of the
%  display to be included in the list of contour or background elements.
%  The nearest neighbours involved in the computation do not get selected
%  based on the distance from the border.
%  'MC' is the default method to test whether the observed difference in
%  means is significant or not. A Monte Carlo permutation test is used: the
%  labels (idx1 or idx2) are randomly shuffled, MC_SAMPLES_N times, to
%  generate a random distribution of differences in mean between both series of
%  elements. Within this distribution the actually observed difference can
%  be located. The resulting proportion p of random sample differences that are
%  smaller than the observed difference can be compared to a value ALPHA.
%  'T' is a faster alternate method, using a T test with Satterthwaite's 
%  compensation for unequal variances. However a normal distribution is 
%  assumed here, whereas the Monte Carlo test is distribution free.
%  In the output structure RES, PM contains the proportion of Monte Carlo
%  samples smaller than the observed difference, or the result of a
%  one-sided T-test. HM is the binary evaluation of this value against the
%  criterion level ALPHA. C1 and C2 contain the full distributions of
%  all retained density measurements on which this test was performed. The
%  output structure RESV contains analogous results for a comparison of a
%  more complete density distribution, including differences in variance
%  (see manual).
%
% EXAMPLE:
%  idx1 = 1:fg_n;
%  idx2 = fg_n+1:elements.n;
%  cld_params.avg_n = 4;
%  cld_params.border_dist = 10;
%  cld_params.method_dens = 'AvgDist';
%  res = GERT_Check_LocalDensity(elements,idx1,idx2,cld_params);
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
% Thanks:   Steven Dakin, for suggesting the Voronoi method
%
% This function is part of GERT, the Grouping Elements Rendering Toolbox
% Find GERT at: http://www.gestaltrevision.be/GERT/
%

GERT_Init;
global GERT_matlv;

%% Check arguments
fnc_name = 'GERT_CheckLocalDensity';

% At least two arguments required
if nargin ~= 4
    msg = 'Four input arguments needed';
    GERT_ShowError(fnc_name,msg,3);
end

% 'elements' - required
if ~isa(elements,'GElements') || ~isscalar(elements)
    msg = 'Input argument ''elements'' must be a 1x1 GElements';
    GERT_ShowError(fnc_name,msg,3);
end

% 'idx1' - required
if ~GERT_Aux_ValidVec(idx1,'double') || any(mod(idx1,1) ~= 0) || any(idx1<0)
    msg = 'Input argument ''idx1'' must be a row vector of positive integers';
    GERT_ShowError(fnc_name,msg,3);
end

% 'idx2' - required
if ~GERT_Aux_ValidVec(idx2,'double') || any(mod(idx2,1) ~= 0) || any(idx2<0)
    msg = 'Input argument ''idx2'' must be a row vector of positive integers';
    GERT_ShowError(fnc_name,msg,3);
end

% 'params' - required
if ~isstruct(params) || ~isscalar(params)
    msg = 'Input argument ''params'' must be a 1x1 struct';
    GERT_ShowError(fnc_name,msg,3);
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',elements,'IN_elements');
GERT_log = add(GERT_log,'var',idx1,'IN_idx1');
GERT_log = add(GERT_log,'var',idx2,'IN_idx2');
GERT_log = add(GERT_log,'var',params,'IN_params');

%% Parse the input
% Parse 'elements'
elements = validate(elements);

if isempty(elements.dims)
    msg = 'No valid dimensions specified in input argument ''elements''';
    GERT_ShowError(fnc_name,msg,3);
end

if elements.n <= 2
    msg = 'At least two elements needed to be present';
    GERT_ShowError(fnc_name,msg,3); 
end

x = elements.x;
y = elements.y;
dims = elements.dims;

% Parse 'params'
p = GStructParser;

p = addfield(p,'border_dist', 'req', @(x) ...
    isscalar(x) && isa(x,'double') && isfinite(x) && x>0);
p = addfield(p,'var_steps', 25, @(x) ...
    isscalar(x) && isa(x,'double') && isfinite(x) && x>=0);
p = addfield(p,'avg_n', 3, @(x) ...
    isscalar(x) && isa(x,'double') && isfinite(x) && x>=0 && mod(x,1) == 0);
p = addfield(p,'rad', 'creq', @(x) ...
    GERT_Aux_ValidVec(x,'double') && all(isfinite(x)) && all(x>0));
p = addfield(p,'mc_samples_n', 1000, @(x) ...
    isscalar(x) && isa(x,'double') && isfinite(x) && x>100 && mod(x,1) == 0);
p = addfield(p,'alpha', 0.35, @(x) ...
    isscalar(x) && isa(x,'double') && isfinite(x) && x>0 && x<1);
p = addfield(p,'method_dens', 'Voronoi', @(x) GERT_Aux_ValidVec(x,'char'));
p = addfield(p,'method_stat', 'MC', @(x) GERT_Aux_ValidVec(x,'char'));

p = parse(p,params);

border_dist = p.results.border_dist;
var_steps = p.results.var_steps;
method_dens = p.results.method_dens;
method_stat = p.results.method_stat;

if strcmp(method_dens,'AvgDist')    
    avg_n = p.results.avg_n;
    
    if avg_n >= (length(idx1)+length(idx2))
        msg = '''avg_n'' is larger than the total number of elements.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
elseif strcmp(method_dens,'RadCount')
    if strcmp(p.results.rad,'creq')
        msg = 'Missing fields in argument ''params''. Type ''help GERT_CheckLocalDensity'' to review the required fields.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    if p.results.border_dist < p.results.rad
        msg = 'Parameter ''border_dist'' may not be smaller than parameter ''rad''.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    rad = p.results.rad;
    
elseif strcmp(method_dens,'Voronoi')
    % Do nothing
else
    msg = 'Unknown method specified in ''method_dens''.';
    GERT_ShowError(fnc_name,msg,3);
end

if strcmp(method_stat,'MC')
    mc_samples_n = p.results.mc_samples_n;
elseif strcmp(method_stat,'T')
    if isempty(ver('stats'))
        msg = 'Matlab Statistics Toolbox must be installed to use the ''T'' option.';
        GERT_ShowError(fnc_name,msg,3);
    end
else
    msg = 'Unknown method specified in ''method_dens''.';
    GERT_ShowError(fnc_name,msg,3);
end

alpha = p.results.alpha;

if intersect(idx1,idx2)
    msg = '''idx1'' and ''idx2'' contain identical elements.';
    GERT_ShowError(fnc_name,msg,3);
end

if any(idx1>length(x)) || any(idx2>length(x))
    msg = 'Indices exceed sizes of ''x'' and ''y''.';
    GERT_ShowError(fnc_name,msg,3);
end

cld_width = dims(2)-dims(1)-(2*border_dist);
cld_height = dims(4)-dims(3)-(2*border_dist);
cld_dims_x = [dims(1)+border_dist dims(1)+border_dist dims(2)-border_dist dims(2)-border_dist];
cld_dims_y = [dims(3)+border_dist dims(4)-border_dist dims(4)-border_dist dims(3)+border_dist];

if cld_width<=0 || cld_height<=0
    msg = 'Effective display size is 0 or negative. Adjust ''dims'' or ''border_dist''.';
    GERT_ShowError(fnc_name,msg,3);
end


%% Implementation of methods
if strcmp(method_dens,'AvgDist')
    %% Method AvgDist
    % Retrieve the coordinates for both sets of points
    p1 = [x(idx1); y(idx1)];
    p2 = [x(idx2); y(idx2)];
    p_or = [x; y];
    p_idx = [idx1 idx2];
    p = [x(p_idx); y(p_idx)];
    
    % Retrieve the coordinates for 'source' points
    % I.e., points inside the limits set by border_dist
    tmp_idx1 = inpolygon(p1(1,:)',p1(2,:)',cld_dims_x,cld_dims_y);
    p1_src = p1(:,tmp_idx1);
    
    tmp_idx2 = inpolygon(p2(1,:)',p2(2,:)',cld_dims_x,cld_dims_y);
    p2_src = p2(:,tmp_idx2);
    
    idx_src = find([tmp_idx1' tmp_idx2']);
    p_src = [p1_src p2_src];
    n1_src = size(p1_src,2);
    
    if avg_n>0
        % Compute distances from the source points to all other points
        dists = GERT_Aux_EuclDist(p_src(1,:),p_src(2,:),p_or(1,:),p_or(2,:));
        dists = sort(dists,2);
        all_dists = dists(:,2:avg_n+1);
        avg_dists = mean(all_dists,2)';
    else
        
        if ~strcmp(GERT_matlv{1},'Matlab')
            msg = 'This method is at the moment only available for Matlab. Please specify the ''avg_n'' parameter';
            GERT_ShowError(fnc_name,msg,3);
        end
        
        % Use Delaunay triangulation to determine n for each point
        T = delaunayn(p_or');
        d1 = sqrt(((p_or(1,T)-p_or(1,circshift(T,[0 1]))).^2)+((p_or(2,T)-p_or(2,circshift(T,[0 1]))).^2));
        d2 = sqrt(((p_or(1,T)-p_or(1,circshift(T,[0 -1]))).^2)+((p_or(2,T)-p_or(2,circshift(T,[0 -1]))).^2));

        all_dists = cell(1,length(idx_src));
        avg_dists = zeros(1,length(idx_src));
        for i = 1:length(idx_src)
            tr = T==p_idx(idx_src(i));
            all_dists{i} = unique([d1(tr); d2(tr)]);
            avg_dists(i) = mean(all_dists{i});         
        end
    end
    
    % Data difference in mean
    diffm = mean(avg_dists(1:n1_src)) - mean(avg_dists(n1_src+1:end));
    res.c1 = avg_dists(1:n1_src);
    res.c2 = avg_dists(n1_src+1:end);
    
    % Do statistics on the significance of this difference
    if strcmp(method_stat,'MC')
        
        % Resampled differences
        ridx = zeros(mc_samples_n,size(p_src,2));
        [foo,ridx] = sort(rand(size(ridx)),2);
        avg_dists_rm = avg_dists(ridx);
        mean_diff_r = mean(avg_dists_rm(:,1:n1_src),2) - mean(avg_dists_rm(:,n1_src+1:end),2);
        
        % Locate the observed data within the shuffled samples
        mean_diff_r = sort(mean_diff_r);
        [foo, midx] = min(abs(mean_diff_r - diffm));
        res.pm = midx/length(mean_diff_r);
        
    elseif strcmp(method_stat,'T')
        [foo res.pm] = ttest2(avg_dists(1:n1_src),avg_dists(n1_src+1:end),alpha,'left','unequal');
    end
    
    % Variance test
    if nargout > 1
        
        % Throw all individual neighbor distances into one big pool, then 
        % bin them and count the distances within each bin. This is the local
        % density profile incl. variability.
        resv = struct;
        
        if avg_n>0 % fixed number of neighbors
            ad1 = all_dists(1:n1_src,:); ad1 = ad1(:); 
            ad2 = all_dists(n1_src+1:end,:); ad2 = ad2(:); 
        else % Variable number of neighbors
            ad1 = cell2mat(all_dists(1:n1_src)');
            ad2 = cell2mat(all_dists(n1_src+1:end)');
        end
        
        vrange = linspace(min([ad1; ad2])-0.01,max([ad1; ad2]),var_steps);
        for step = 1:var_steps-1
            resv.c1(step) = sum(ad1>vrange(step)&ad1<=vrange(step+1));
            resv.c2(step) = sum(ad2>vrange(step)&ad2<=vrange(step+1));
        end
        
        resv.c1 = resv.c1/sum(resv.c1);
        resv.c2 = resv.c2/sum(resv.c2);
        var_diff = sum(abs(resv.c1-resv.c2));
        
        % Statistics
        if strcmp(method_stat,'MC')
            ridx = zeros(mc_samples_n,length(p_src));
            [foo,ridx] = sort(rand(size(ridx)),2);
            
            if avg_n>0 % Fixed number of neighbors
                all_dists_rm = all_dists(ridx,:);
                all_dists_rm = reshape(all_dists_rm,[mc_samples_n length(p_src) avg_n]);
                ad1_rm = all_dists_rm(:,1:n1_src,:);
                ad2_rm = all_dists_rm(:,n1_src+1:end,:);
                
                c1_rm = zeros(mc_samples_n,var_steps-1);
                c2_rm = zeros(mc_samples_n,var_steps-1);
                for step = 1:var_steps-1
                    c1_rm(:,step) = sum(sum(ad1_rm>vrange(step)&ad1_rm<=vrange(step+1),3),2);
                    c2_rm(:,step) = sum(sum(ad2_rm>vrange(step)&ad2_rm<=vrange(step+1),3),2);
                end
            else % Variable number of neighbors
                all_dists_rm = all_dists(ridx);
                c1_rm = zeros(mc_samples_n,var_steps-1);
                c2_rm = zeros(mc_samples_n,var_steps-1);
                for i = 1:mc_samples_n % This should be optimized for speed...
                    ad1_rm = cell2mat(all_dists_rm(i,1:n1_src)')';
                    ad2_rm = cell2mat(all_dists_rm(i,n1_src+1:end)')';
                    
                    for step = 1:var_steps-1
                        c1_rm(i,step) = sum(ad1_rm>vrange(step)&ad1_rm<=vrange(step+1),2);
                        c2_rm(i,step) = sum(ad2_rm>vrange(step)&ad2_rm<=vrange(step+1),2);
                    end
                end
            end
            
            c1_rm = c1_rm./repmat(sum(c1_rm,2),[1 var_steps-1]);
            c2_rm = c2_rm./repmat(sum(c2_rm,2),[1 var_steps-1]);
            var_diff_r = sum(abs(c1_rm-c2_rm),2);
            var_diff_r = sort(var_diff_r);
            [foo, midx] = min(abs(var_diff_r - var_diff));
            resv.pm = midx/length(mean_diff_r);
            
        elseif strcmp(method_stat,'T')
            resv.pm = 0;
            msg = 'No variance test performed, ''T'' method is unavailable';
            GERT_ShowError(fnc_name,msg,1);
        end
        
    end
    
elseif strcmp(method_dens,'RadCount')
    %% Method RadCount
    % Exclude points near the borders
    p1 = [x(idx1); y(idx1)];
    p2 = [x(idx2); y(idx2)];
    p_or = [x; y];
    p_idx = [idx1 idx2];
    p = [x(p_idx); y(p_idx)];
    
    tmp_idx = inpolygon(p1(1,:)',p1(2,:)',cld_dims_x,cld_dims_y);
    p1_src = p1(:,tmp_idx);
    tmp_idx = inpolygon(p2(1,:)',p2(2,:)',cld_dims_x,cld_dims_y);
    p2_src = p2(:,tmp_idx);
    
    p_src = [p1_src p2_src];
    n1_src = size(p1_src,2);
    
    % If scalar rad
    if isscalar(rad)
        % Count how many other points are within a radius 'rad' of each point
        dists = GERT_Aux_EuclDist(p_src(1,:),p_src(2,:),p_or(1,:),p_or(2,:));
        dists(dists==0) = rad;
        cnt = dists<rad;
        cnt = sum(cnt,2);

        % Compare
        diffm = mean(cnt(1:n1_src)) - mean(cnt(n1_src+1:end));
        res.c1 = cnt(1:n1_src);
        res.c2 = cnt(n1_src+1:end);

        % Statistics
        if strcmp(method_stat,'MC')

            ridx = zeros(mc_samples_n,size(p_src,2));
            [foo,ridx] = sort(rand(size(ridx)),2);
            cnt_rm = cnt(ridx);
            mean_diff_r = mean(cnt_rm(:,1:n1_src),2) - mean(cnt_rm(:,n1_src+1:end),2);

            mean_diff_r = sort(mean_diff_r);
            [foo, midx] = min(abs(mean_diff_r - diffm));
            res.pm = midx/length(mean_diff_r);

        elseif strcmp(method_stat,'T')
            [foo res.pm] = ttest2(cnt(1:n1_src),cnt(n1_src+1:end),alpha,'left','unequal');
        end    

        res.pm = 1-res.pm;

        % Variance test
        if nargout > 1

            resv = struct;    
            radspace = linspace(min(dists(:)),rad,var_steps);

            all_cnt = zeros(length(p_src),var_steps);
            for i = 1:var_steps
                all_cnt(:,i) = sum(dists<radspace(i),2) ./ repmat(pi*radspace(i)*radspace(i),[length(p_src) 1]);
            end

            resv.c1 = mean(all_cnt(1:n1_src,:),1);
            resv.c2 = mean(all_cnt(n1_src+1:end,:),1);
            var_diff = sum(abs(resv.c1-resv.c2));

            if strcmp(method_stat,'MC')
                ridx = zeros(mc_samples_n,length(p_src));
                [foo,ridx] = sort(rand(size(ridx)),2);
                all_cnt_rm = all_cnt(ridx,:);
                all_cnt_rm = reshape(all_cnt_rm,[mc_samples_n length(p_src) var_steps]);

                c1_rm = mean(all_cnt_rm(:,1:n1_src,:),2);
                c2_rm = mean(all_cnt_rm(:,n1_src+1:end,:),2);
                c1_rm = squeeze(c1_rm); c2_rm = squeeze(c2_rm);

                var_diff_r = sum(abs(c1_rm-c2_rm),2);
                var_diff_r = sort(var_diff_r);
                [foo, midx] = min(abs(var_diff_r - var_diff));
                resv.pm = midx/length(mean_diff_r);

            elseif strcmp(method_stat,'T')
                resv.pm = 0;
                msg = 'No variance test performed, ''T'' method is unavailable';
                GERT_ShowError(fnc_name,msg,1);
            end

        end
    % If vector of radii
    else
        dists = GERT_Aux_EuclDist(p_src(1,:),p_src(2,:),p_or(1,:),p_or(2,:));
        dists(dists==0) = Inf;

        cnt = squeeze(sum(repmat(dists, [1,1,length(rad)]) < repmat(reshape(rad,[1,1,length(rad)]),[size(dists,1),size(dists,2),1]),2));
        cnt = cnt ./ repmat(pi.*rad.*rad,[size(cnt,1),1]);
        diffm = mean(cnt(1:n1_src,:),1)-mean(cnt(n1_src+1:end,:),1);
        diffm = mean(abs(diffm)) * sign(mean(diffm));
        
        res.c1 = mean(cnt(1:n1_src,:),2);
        res.c2 = mean(cnt(n1_src+1:end,:),2);

        % Statistics
        cnt_rm = zeros(mc_samples_n, size(p_src,2), length(rad));
        for i = 1:length(rad)
            [foo,ridx] = sort(rand([mc_samples_n, size(p_src,2)]), 2);
            cnt_tmp = cnt(:,i);
            cnt_rm(:,:,i) = cnt_tmp(ridx);
        end
        diffm_rm = mean(cnt_rm(:,1:n1_src,:),2) - mean(cnt_rm(:,n1_src+1:end,:),2);
        diffm_rm = mean(abs(diffm_rm),3) .* sign(mean(diffm_rm,3));

        diffm_rm = sort(diffm_rm);
        [foo, midx] = min(abs(diffm_rm - diffm));
        res.pm = midx/length(diffm_rm);

        res.pm = 1-res.pm;
    end
    
elseif strcmp(method_dens,'Voronoi')
    %% Method Voronoi   
    
    if ~strcmp(GERT_matlv{1},'Matlab')
        msg = 'The Voronoi method returns invalid results under Octave at this moment. Do not use.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    % Retrieve the relevant xy coordinates
    p1 = [x(idx1); y(idx1)];
    p2 = [x(idx2); y(idx2)];
    p_or = [x; y];
    p_idx = [idx1 idx2];
    p = [x(p_idx); y(p_idx)];

    % Construct the Voronoi diagram
    [V,C_or] = voronoin(p_or');
    
    if length(C_or)~= length(x)
       msg = 'Something went wrong with the Voronoi tesselation, please report this to the developers.';
       GERT_ShowError(fnc_name,msg,3);
    end
    
    C = C_or(p_idx);
    
    % Retrieve the vertices of each cell, remove those cells that have
    % vertices outside the display dimensions
    vin = true(1,size(p,2));
    for i = 1:size(p,2)
        Vx = V(C{i},1);
        Vy = V(C{i},2);
        
        if ~all(inpolygon(Vx,Vy,[dims(1) dims(1) dims(2) dims(2)],[dims(3) dims(4) dims(4) dims(3)]) )
            vin(i) = false;
        end
    end
    
    % Only consider source points that are at least border_dist away from the edge
    tmp_idx = vin(1:length(p1)) & inpolygon(p1(1,:)',p1(2,:)',cld_dims_x,cld_dims_y)';
    p1_src = p1(:,tmp_idx);
    [foo, faa, p1_src_idx] = find(tmp_idx .* (1:length(tmp_idx)));
    
    tmp_idx = vin(length(p1)+1:length(p)) & inpolygon(p2(1,:)',p2(2,:)',cld_dims_x,cld_dims_y)';
    p2_src = p2(:,tmp_idx);
    [foo, faa, p2_src_idx] = find(tmp_idx .* (1:length(tmp_idx)));
    p2_src_idx = length(idx1) + p2_src_idx;
    
    p_src_idx = [p1_src_idx p2_src_idx];
    p_src = [p1_src p2_src];
    n1_src = size(p1_src,2);
    
    % Compute the area of each cell
    locsurf = zeros(1,size(p_src,2));
    
    %figure; hold on;
    for i = 1:size(p_src,2)
        Vx = V(C{p_src_idx(i)},1);
        Vy = V(C{p_src_idx(i)},2);
        locsurf(i) = polyarea(Vx,Vy);
        
        % To plot the cells
        %fill(V(C{p_src_idx(i)},1),V(C{p_src_idx(i)},2),[0.5 0.5 0.5]);
        %plot(p(1,p_src_idx(i)),p(2,p_src_idx(i)),'o','Color',[0 0 0]);
    end
    %hold off;
    
    % Compare both series of points
    diffm = mean(locsurf(1:n1_src)) - mean(locsurf(n1_src+1:end));
    res.c1 = locsurf(1:n1_src);
    res.c2 = locsurf(n1_src+1:end);
    
    % Statistics
    if strcmp(method_stat,'MC')
        
        ridx = zeros(mc_samples_n,size(p_src,2));
        [foo,ridx] = sort(rand(size(ridx)),2);
        locsurf_rm = locsurf(ridx);
        mean_diff_r = mean(locsurf_rm(:,1:n1_src),2) - mean(locsurf_rm(:,n1_src+1:end),2);
        
        mean_diff_r = sort(mean_diff_r);
        [foo, midx] = min(abs(mean_diff_r - diffm));
        res.pm = midx/length(mean_diff_r);
        
    elseif strcmp(method_stat,'T')
        [foo res.pm] = ttest2(locsurf(1:n1_src),locsurf(n1_src+1:end),alpha,'left','unequal');
    end
    
    % Variance test
    if nargout > 1
        
        resv = struct;
        as1 = locsurf(1:n1_src);
        as2 = locsurf(n1_src+1:end);
        vrange = linspace(min(locsurf)-0.01,max(locsurf),var_steps);
        
        for step = 1:var_steps-1
            resv.c1(step) = sum(as1>vrange(step)&as1<=vrange(step+1));
            resv.c2(step) = sum(as2>vrange(step)&as2<=vrange(step+1));
        end
        
        resv.c1 = resv.c1/sum(resv.c1);
        resv.c2 = resv.c2/sum(resv.c2);
        var_diff = sum(abs(resv.c1-resv.c2));
        
        if strcmp(method_stat,'MC')
            ridx = zeros(mc_samples_n,length(p_src));
            [foo,ridx] = sort(rand(size(ridx)),2);
            all_surf_rm = locsurf(ridx);
            
            as1_rm = all_surf_rm(:,1:n1_src);
            as2_rm = all_surf_rm(:,n1_src+1:end);
            
            c1_rm = zeros(mc_samples_n,var_steps-1);
            c2_rm = zeros(mc_samples_n,var_steps-1);
            for step = 1:var_steps-1
                c1_rm(:,step) = sum(as1_rm>vrange(step)&as1_rm<=vrange(step+1),2);
                c2_rm(:,step) = sum(as2_rm>vrange(step)&as2_rm<=vrange(step+1),2);
            end
            
            c1_rm = c1_rm./repmat(sum(c1_rm,2),[1 var_steps-1]);
            c2_rm = c2_rm./repmat(sum(c2_rm,2),[1 var_steps-1]);
            var_diff_r = sum(abs(c1_rm-c2_rm),2);
            var_diff_r = sort(var_diff_r);
            [foo, midx] = min(abs(var_diff_r - var_diff));
            resv.pm = midx/length(mean_diff_r);
            resv.xaxis = vrange;
            
        elseif strcmp(method_stat,'T')
            resv.pm = 0;
            msg = 'No variance test performed, ''T'' method is unavailable';
            GERT_ShowError(fnc_name,msg,1);
        end
        
    end
    
end

% Test against alpha
if res.pm > alpha/2 && res.pm < 1-(alpha/2)
    res.hm = false;
else
    res.hm = true;
end

if nargout > 1
    if resv.pm > alpha
        resv.hm = true;
    else
        resv.hm = false;
    end
end

%% Log the output
GERT_log = add(GERT_log,'var',res,'OUT_res');
if nargout >1
    GERT_log = add(GERT_log,'var',resv,'OUT_resv');
end
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done