function [elements, ors, actual_vals] = GERT_PlaceElements_Contour(contour, params)

% [elements, ors, actual_vals] = GERT_PlaceElements_Contour(contour, params)
%
% DESCRIPTION:
%  This function will place elements on a contour, defined as a vector of
%  Cartesian coordinates. Three methods are available: Parallel equidistant
%  placement, serial equidistant placement, and entirely random placement.
%
% ARGUMENTS:
%  contour ------------------- required
%                              1x1 GContour
%
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- method ------------- optional, default: 'ParallelEquidistant'
%      |                       1xM char array
%      |                       'ParallelEquidistant', 'SerialEquidistant', or 'Random'
%      |
%     METHOD: 'ParallelEquidistant'
%      |
%      |- cont_avgdist ------- optional, default minus 1 (=determined by el_n)
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- el_n ---------------- optional, default: minus 1 (=determined by cont_avgdist)
%      |                        1x1 double
%      |                        >0 or minus 1, integer value, finite, real
%      |
%      |- eucl_mindist ------  optional, default: 0
%      |                       1x1 double
%      |                        >=0, finite, real
%      |
%      |- cont_startpos ------ optional, default: minus 1 (=random)
%      |                       1x1 double
%      |                       0<=x<=1 or minus 1, finite, real
%      |
%      |- noise_method ------- optional, default: 'Uniform'
%      |                       1xM char
%      |                       'Uniform', 'Gaussian', or 'Vector'
%      |
%      |- noise_oncont ------- optional, default: 0
%      |                       1xI double
%      |                        0<=x<=1 or 0.5<=x<=0.5, finite, real
%      |
%      |- noise_offcont ------ optional, default:0
%      |                       1xJ double
%      |                       0<=x<=1 or 0.5<=x<=0.5, finite, real
%      |
%      |- noise_retries_n ---- optional, default: 0
%      |                       1x1 double
%      |                       >=0, integer value, finite, real
%      |
%      |- timeout ------------ optional, default: 60
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%     METHOD: 'SerialEquidistant'
%      (where different from 'ParallelEquidistant' parameters)
%      |
%      |- eucl_mindist -------- required
%      |                        1x1 double
%      |                        >=0, finite, real
%      |
%      |- dist_retries_step --- optional, default: cont_avgdist/5
%      |                        1x1 double
%      |                        >0, finite, real
%      |
%     METHOD: 'Random'
%      |
%      |- eucl_mindist -------- required
%      |                        1x1 double
%      |                        >=0, finite, real
%      |
%      |- el_n ---------------- optional, default: minus 1 (= until full)
%      |                        1x1 double
%      |                        >0 or minus 1, integer value, finite, real
%      |
%      |- resolution ---------- optional, default: 500
%      |                        1x1 double
%      |                        >1, integer value, finite, real
%      |
%      |- noise_dilrad -------- optional, default: 0
%      |                        1x1 double
%      |                        >=0, finite, real
%      |
%      |- timeout ------------- optional, default: 60
%      |                        1x1 double
%      |                        >0, finite, real
%      |
%      |- batch_size ---------- optional, default: 100
%      |                        1x1 double
%      |                        >0, integer value, finite, real
%
% RETURNS:
%  elements ------------------- 1x1 GElements
%
%  ors ------------------------ 1xn double
%
%  actual_vals ---------------- 1x1 struct
%
%
% DETAILS:
%  'ParallelEquidistant' is the default method. Here, the length of the
%  contour will be subdivided in equal segment, respecting the CONT_AVGDIST
%  between elements as closely as possible. Alternatively, you may provide 
%  the EL_N parameter to automatically determine this value based on the
%  number of elements. Position noise can be applied either along the 
%  contour through NOISE_ONCONT, or perpendicular to it, through NOISE_OFFCONT. 
%  These values reflect the limits of the noise offset, where 0 is no noise
%  and 1 is from -0.5*cont_avgdist to 0.5*cont_avgdist. For the Gaussian
%  case, this corresponds to 2SD. Note that the Gaussian distribution is 
%  therefore cut off at 2SD, and not truly Gaussian. For 'Vector' noise, 
%  a sufficiently large vector should be passed, from which the position 
%  deviations will be sampled randomly. Noise values are to be understood 
%  as a proportion of cont_avgdist. CONT_STARTPOS can be set to a fixed 
%  value; if not specified, the position of the first element will be 
%  random. The value is to lie between 0 and 1, where 0.5 is placement on 
%  the middle of the segment. Should the EUCL_MINDIST be violated by the 
%  noise displacements, the function will attempt NOISE_RETRIES_N new 
%  placements of all points. This method is especially useful for simple,
%  smooth contours, where different parts of the contour description do 
%  not typically come within a distance of EUCL_MINDIST of one another.
%
%  'SerialEquidistant' uses similar methods, but places the points one by
%  one. If even after a number of noise retries no suitable solution is
%  found, the average distance is increased by DIST_RETRIES_STEP, until a
%  point along the contour is found where no conflicts exist with previous
%  points. No position noise is applied to this point. For the next
%  point, the normal procedure is continued. This method is especially
%  useful for complex contours with difficult parts, where contour
%  segments come too close to one another.
%
%  'Random' uses methods similar to the GERT_PlaceElements_Background
%  function: Elements are placed on the remaining possible positions (that
%  is, at a distance of minimally EUCL_MINDIST from other points) until the
%  contour is filled, or the EL_N limit to the number of elements is reached.
%  Setting RESOLUTION and BATCH_SIZE to different values may affect precision
%  and performance. Position noise can be applied through setting the NOISE_DILRAD
%  parameter, which applies 'blurring' to the contour description that
%  limits the element placement. This method is useful for any contour
%  where equidistance is not necessarily required, and allows element
%  placement even on non-continuous contours.
%
%  In addition to the 'elements' structure containing the Cartesian
%  coordinates of the contour points placed, their orientation along the
%  contour is returned, if the original contour contained both cdist and lt
%  fields. As the third return argument, the actual values used in a method
%  may be found, since they might deviate from those passed as a parameter.
%  For instance, cont_avgdist in the ParallelEquidistant case can only take
%  certain discrete values.
%
% EXAMPLE:
%  (1) Equidistant placement with slight jitter on the contour
%    contour = GERT_GenerateContour_RFP(params);
%    pec_params.eucl_mindist = 1;
%    pec_params.cont_avgdist = 5;
%    pec_params.noise_method = 'Gaussian';
%    pec_params.noise_oncont = 0.2;
%    els = GERT_PlaceElements_Contour(contour, pec_params);
%
%  (2) Random placement of exactly 15 elements
%    contour = GERT_GenerateContour_RFP(params);
%    pec_params.method = 'Random';
%    pec_params.eucl_mindist = 1;
%    pec_params.el_n = 15;
%    els = GERT_PlaceElements_Contour(contour, pec_params);
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

%% Check the arguments
fnc_name = 'GERT_PlaceElements_Contour';

% Minimum two arguments needed
if nargin ~= 2
    msg = 'Minimum two input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'contour' - required
if ~isa(contour,'GContour') || ~isscalar(contour)
    msg = 'Input argument ''contour'' must be a 1x1 GContour.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'params' - required
if ~isstruct(params) || ~isscalar(params)
    msg = 'Input argument ''params'' must be a 1x1 struct.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'method' - optional, default is 'ParallelEquidistant'
if isfield(params,'method') && ~GERT_Aux_ValidVec(params.method,'char')
    msg = 'Input argument ''method'' must be a 1xN char array.';
    GERT_ShowError(fnc_name,msg,3);
elseif ~isfield(params,'method')
    method = 'ParallelEquidistant';
else
    method = params.method;
end

%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',contour,'IN_contour');
GERT_log = add(GERT_log,'var',params,'IN_params');

%% Parse and verify the input
% Parse 'contour'
contour = validate(contour);
cdn = contour.n;
cdx = contour.x;
cdy = contour.y;
closed = contour.closed;

% Parse 'params'
p = GStructParser;

% % Common elements
p = addfield(p,'timeout', 60, @(x) GERT_Aux_ValidVec(x,'double',1) && x>0);
p = addfield(p,'method', 'ParallelEquidistant', @(x) GERT_Aux_ValidVec(x,'char'));

% % Parse the rest of 'params' according to 'method'
if strcmp(method,'ParallelEquidistant') || strcmp(method,'SerialEquidistant')
    p = addfield(p,'cont_avgdist', -1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && (x>0 || x==-1));
    p = addfield(p,'cont_startpos', -1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && ((x>=0 && x<=1) || x==-1));
    p = addfield(p,'noise_oncont', 0, @(x) GERT_Aux_ValidVec(x,'double'));
    p = addfield(p,'noise_offcont', 0, @(x) GERT_Aux_ValidVec(x,'double'));
    p = addfield(p,'noise_method', 'Uniform', @(x) GERT_Aux_ValidVec(x,'char'));
    p = addfield(p,'noise_retries_n', 0, @(x) GERT_Aux_ValidVec(x,'double',1) && ...
        x>=0 && mod(x,1)==0);
    p = addfield(p,'el_n', -1, @(x) GERT_Aux_ValidVec(x,'double',1) ...
        && (x>0||x==-1) && mod(x,1)==0);
end

if strcmp(method,'ParallelEquidistant')
    p = addfield(p,'eucl_mindist', 0, @(x) GERT_Aux_ValidVec(x,'double',1)...
        && x>=0);
    
elseif strcmp(method,'SerialEquidistant')
    p = addfield(p,'eucl_mindist', 'req', @(x) GERT_Aux_ValidVec(x,'double',1)...
        && x>=0);
    p = addfield(p,'dist_retries_step', -1, @(x) GERT_Aux_ValidVec(x,'double',1)...
        && (x>=0||x==-1));
    
elseif strcmp(method,'Random')
    p = addfield(p,'eucl_mindist', 'req', @(x) GERT_Aux_ValidVec(x,'double',1)...
        && x>=0);
    p = addfield(p,'batch_size', 100, @(x) GERT_Aux_ValidVec(x,'double',1)...
        && x>1 && mod(x,1)==0);
    p = addfield(p,'resolution', 500, @(x) ...
        GERT_Aux_ValidVec(x,'double',1)&& x>1);
    p = addfield(p,'noise_dilrad', 0, @(x) GERT_Aux_ValidVec(x,'double',1)...
        && x>=0);
    p = addfield(p,'el_n', -1, @(x) GERT_Aux_ValidVec(x,'double',1) ...
        && (x>0||x==-1) && mod(x,1)==0);
end

p = parse(p,params);

eucl_mindist = p.results.eucl_mindist;
timeout = p.results.timeout;
el_n = p.results.el_n;

if strcmp(method,'ParallelEquidistant') || strcmp(method,'SerialEquidistant')
    cont_startpos = p.results.cont_startpos;
    cont_avgdist = p.results.cont_avgdist;
    noise_oncont = p.results.noise_oncont;
    noise_offcont = p.results.noise_offcont;
    noise_method = p.results.noise_method;
    noise_retries_n = p.results.noise_retries_n;
    
    if ~strcmp(noise_method,'Uniform') && ~strcmp(noise_method,'Gaussian') && ~strcmp(noise_method,'Vector')
        msg = 'Invalid field in argument ''params.noise_method''. The sampling method must be either ''Uniform'', ''Gaussian'', or ''Vector''.';
        GERT_ShowError(fnc_name,msg,3);
    end
end

if strcmp(method,'ParallelEquidistant')
    %none;
elseif strcmp(method,'SerialEquidistant')
    dist_retries_step = p.results.dist_retries_step;
elseif strcmp(method,'Random')
    batch_size = p.results.batch_size;
    res = p.results.resolution;
    noise_dilrad = p.results.noise_dilrad;
end

elements = GElements;
actual_vals = struct;

global GERT_matlv;

% First a common part for both methods
if strcmp(method,'ParallelEquidistant') || strcmp(method,'SerialEquidistant')
    
    tstart = tic;
    
    % Compute distances along contour, do some checks
    if length(contour.cdist) ~= (cdn+double(contour.closed))
        msg = 'No valid cdist present in contour description. Computing automatically...';
        GERT_ShowError(fnc_name,msg,1);
        contour = compute_cdist(contour);
    end
    cdist = contour.cdist;
    clength = contour.clength;
    
    % Close a closed contour (for interpolation purposes)
    if closed
        cdx = [cdx cdx(1)];
        cdy = [cdy cdy(1)];
    end
    
    % Check whether we have either el_n or cont_avgdist
    if (el_n==-1&&cont_avgdist==-1) || (el_n~=-1&&cont_avgdist~=-1)
        msg = 'Must have either el_n or cont_avgdist set, not both.';
        GERT_ShowError(fnc_name,msg,3);
    end

    % Determine the number of elements (if not given)
    if el_n == -1
        el_n = round(clength/cont_avgdist);
    end            
    actual_vals.el_n = el_n;
    
    if el_n < 4
        msg = 'At least 4 elements must be placed on a contour.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    % Randomize starting position if necessary
    if cont_startpos == -1
        cont_startpos = rand;
    end
    
    % Do noise value checks
    if all(noise_oncont == 0) && all(noise_offcont == 0) && cont_startpos ~= -1
        noise_retries_n = 0;
    else
        if strcmp(noise_method,'Uniform') || strcmp(noise_method,'Gaussian')
            if ~isscalar(noise_oncont) || noise_oncont < 0 || noise_oncont > 1 ||...
               ~isscalar(noise_offcont) || noise_offcont < 0 || noise_offcont > 1
                msg = 'When using the ''Uniform'' or ''Gaussian'' noise method, the noise values must be scalars between 0 and 1';
                GERT_ShowError(fnc_name,msg,3);
            end
        else
            if any(noise_oncont<-0.5) || any(noise_oncont>0.5) || ...
               any(noise_offcont<-0.5) || any(noise_offcont>0.5)
                msg = 'Noise values for the ''Vector'' method must lie between -0.5 and 0.5';
                GERT_ShowError(fnc_name,msg,3);
            end
        end
    end
    
    % Determine local tangents
    if length(contour.lt) ~= cdn
        msg = 'No valid local tangents present in contour description. Computing automatically...';
        GERT_ShowError(fnc_name,msg,1);
        contour = contour.compute_lt;
    end    
    cont_lt = contour.lt;
    
    if(closed)
        cont_lt = [cont_lt cont_lt(1)];
    end
end

% Now branch off both methods
if strcmp(method,'ParallelEquidistant')
    
    % Position the elements without noise
    pos = linspace(0,clength,el_n+1);   
    actual_vals.cont_avgdist = pos(2);
    pos = pos(1:end-1) + (cont_startpos*actual_vals.cont_avgdist);
    
    % Catch obvious mistake
    if actual_vals.cont_avgdist < eucl_mindist
        msg = 'Average element distance along the contour is equal to or smaller the minimum Euclidean distance to be respected.';
        GERT_ShowError(fnc_name,msg,3);
    end

    % Initial x and y values without noise
    posx = interp1(cdist,cdx,pos);
    posy = interp1(cdist,cdy,pos);
    poswn = pos;
    
    % Check whether eucl_mindist isn't violated here already
    if eucl_mindist ~= 0
        dist_to_eachother = GERT_Aux_EuclDist(posx,posy,posx,posy);
        dist_to_eachother = dist_to_eachother + eye(size(dist_to_eachother))*eucl_mindist;
        
        if any(dist_to_eachother(:) < eucl_mindist)
            msg = '''eucl_mindist'' is already violated before applying noise - consider the SerialEquidistant method.';
            GERT_ShowError(fnc_name,msg,3);
        end
    end

    % Add the noise
    for r = 1:noise_retries_n+1
        
        % See how much time we've spent already
        if strcmp(GERT_matlv{1},'Matlab')
            time_elapsed = toc(tstart);
        else
            time_elapsed = (double(tic) - double(tstart)) * 1e-6;
        end
        
        if time_elapsed > timeout
            msg = 'Timeout';
            GERT_ShowError(fnc_name,msg,3);
        end
        
        % Generate the contour noise distribution
        cnoise = zeros(1,el_n);
        if any(noise_oncont)
            cnoise = generate_noise(noise_method, ...
                actual_vals.cont_avgdist*noise_oncont, el_n);
        end
        
        % Add the noise
        poswn = pos + cnoise;
        
        % Adjust for exceeding the limits of clength
        poswn(poswn<0) = poswn(poswn<0) + clength;
        poswn(poswn>clength) = poswn(poswn>clength) - clength;
        poswn = sort(poswn,2);
        
        % Compute xy coordinates
        posx = interp1(cdist,cdx,poswn);
        posy = interp1(cdist,cdy,poswn);
        
        % Generate the perpendicular noise distribution
        pnoise = zeros(1,el_n);
        if any(noise_offcont)
            pnoise = generate_noise(noise_method, ...
                actual_vals.cont_avgdist*noise_offcont, el_n);
            el_lt = interp1(cdist, cont_lt, pos);
            posx = posx + pnoise .* cos(el_lt-(pi/2));
            posy = posy + pnoise .* cos(el_lt-(pi/2));
        end
        
        % Check whether min_eucl_dist is exceeded between any two points
        dist_to_eachother = GERT_Aux_EuclDist(posx,posy,posx,posy);
        dist_to_eachother = dist_to_eachother + eye(size(dist_to_eachother))*eucl_mindist;
        
        % If so, try again. If not, stop here.
        if any(dist_to_eachother(:) < eucl_mindist)
            if r == noise_retries_n+1
                msg = '''eucl_mindist'' is still violated after all noise retries.''';
                GERT_ShowError(fnc_name,msg,3);
            end
        else
            break;
        end
    end
    
    % Assign output values
    elements.x = posx;
    elements.y = posy;
    cpdist = poswn;
end
    
if strcmp(method,'SerialEquidistant')
    
    % Calculate the ideal average distance
    actual_vals.cont_avgdist = clength/actual_vals.el_n;
    
    % Catch obvious mistake
    if actual_vals.cont_avgdist < eucl_mindist
        msg = 'Average element distance along the contour is equal to or smaller the minimum Euclidean distance to be respected.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    % Set the default step of element displacement upon failure
    if dist_retries_step == -1
        dist_retries_step = actual_vals.cont_avgdist/5;
    end
    
    % Set some vars to empty
    cpdist = [];
    cpavg = [];
    posx = [];
    posy = [];
    
    % Begin, element per element
    points_moved = 0;
    while elements.n < actual_vals.el_n
        
        % Keep an eye on the time
        if strcmp(GERT_matlv{1},'Matlab')
            time_elapsed = toc(tstart);
        else
            time_elapsed = (double(tic) - double(tstart)) * 1e-6;
        end
        
        if time_elapsed > timeout
            msg = 'Timeout';
            GERT_ShowError(fnc_name,msg,3);
        end
        
        % Generate the on-contour noise candidates
        if any(noise_oncont)
            cnoise = generate_noise(noise_method, ...
                actual_vals.cont_avgdist*noise_oncont, noise_retries_n+1);
        else
            cnoise = zeros(1,noise_retries_n+1);
        end
        
        % Apply the cnoise candidates to the element
        if isempty(posx)
            cpcand = (cont_startpos*actual_vals.cont_avgdist) + cnoise;
        else
            cpcand = cpavg(end) + actual_vals.cont_avgdist + cnoise;
        end
        
        % Adjust for exceeding clength
        cpcand(cpcand<0) = cpcand(cpcand<0)+clength;
        cpcand(cpcand>clength) = cpcand(cpcand>clength)-clength;
        cpcand = sort(cpcand,2);
        
        % Generate the perpendicular noise candidates
        if any(noise_offcont)
            pnoise = generate_noise(noise_method, ...
                actual_vals.cont_avgdist*noise_offcont, noise_retries_n+1);
        else
            pnoise = zeros(1,noise_retries_n+1);
        end

        % Apply the pnoise, and compute Cartesian coordinates
        cand_lt = interp1(cdist, cont_lt, cpcand);
        pnoise_x = pnoise .* cos(cand_lt-(pi/2));
        pnoise_y = pnoise .* sin(cand_lt-(pi/2));
        cpcandx = interp1(cdist,cdx,cpcand) + pnoise_x;
        cpcandy = interp1(cdist,cdy,cpcand) + pnoise_y;
        
        % Determine the distance of these candidates to the previous points
        if ~isempty(posx)
            dist_to_other = GERT_Aux_EuclDist(cpcandx, cpcandy, posx, posy);
            dist_to_other = sort(dist_to_other,2);
            [idx foo] = find(dist_to_other(:,1) > eucl_mindist);
        else
            idx =(1:1+noise_retries_n)';
        end
        
        % If any valid point can be found, select a random valid point
        if any(idx)
            cselidx = idx(GERT_Aux_Randi(length(idx)));
            csel = cpcand(1,cselidx);
            if isempty(posx)
                cpavg(1) = cont_startpos*actual_vals.cont_avgdist;
                cpdist(1) = csel;
            else
                cpavg(end+1) = cpavg(end) + actual_vals.cont_avgdist;
                cpdist(end+1) = csel;
            end
            
            posx = [posx cpcandx(cselidx)];
            posy = [posy cpcandy(cselidx)];
            
        % Else, generate all possible next steps without noise
        else
            points_moved = points_moved+1;
            cpcand = cpavg(end)+actual_vals.cont_avgdist:...
                dist_retries_step:...
                clength+(cont_startpos*actual_vals.cont_avgdist);
            
            cpcand(cpcand<0) = cpcand(cpcand<0) + clength;
            cpcand(cpcand>clength) = cpcand(cpcand>clength) - clength;
            
            cpcandx = interp1(cdist,cdx,cpcand);
            cpcandy = interp1(cdist,cdy,cpcand);
            
            % Determine Euclidean distances
            if isempty(cpcand)
                break;
            else
                dist_to_other = GERT_Aux_EuclDist(cpcandx, cpcandy, posx, posy);
                dist_to_other = sort(dist_to_other,2);
                [idx foo] = find(dist_to_other(:,1) > eucl_mindist);
            end
            
            % Select the first point along the contour that qualifies
            if any(idx)
                csel = cpcand(idx(1));
                cpavg(end+1) = cpdist(end) + actual_vals.cont_avgdist +...
                    (dist_retries_step*(idx(1)-1));
                cdone = csel;
                cpdist(end+1) = csel;
                cleft = clength - cdone;
                posx = [posx cpcandx(idx(1))];
                posy = [posy cpcandy(idx(1))];
                
                % Recompute the disatnces at which the put the points,
                % as well as the number of points
                totcleft = cleft+cont_startpos*actual_vals.cont_avgdist;
                el_left = round(totcleft/actual_vals.cont_avgdist);
                actual_vals.cont_avgdist = totcleft/el_left;
                actual_vals.el_n = el_left + length(posx);
            else
                % If none do, stop the loop
                break;
            end
            
        end
    end
    msg = char(strcat({'Points shifted from their original position: '},num2str(points_moved)));
    GERT_log = add(GERT_log,'msg',msg);
    elements.x = posx;
    elements.y = posy;
end

if strcmp(method,'Random')
    
    % Determine the size of the drawing board around the figure
    h_or = (4*noise_dilrad) + abs(max(cdx)-min(cdx)+1);
    v_or = (4*noise_dilrad) + abs(max(cdy)-min(cdy)+1);
    
    if h_or >= v_or
        h_res = res;
        v_res = round((v_or/h_or) * res);
    else
        v_res = res;
        h_res = round((h_or/v_or) * res);
    end
    
    % Convert to the new, integer coordinates
    eucl_mindist = ceil(eucl_mindist*(h_res/h_or));
    cdx = 1+floor(abs((cdx-min(cdx)+(2*noise_dilrad))*((h_res-1)/(h_or-1))));
    cdy = 1+floor(abs((cdy-min(cdy)+(2*noise_dilrad))*((v_res-1)/(v_or-1))));
    
    % If el_n is not specified, go on until the display is full
    if el_n > 0
        %  Do nothing
    elseif el_n == -1
        el_n = 1 + (h_res*v_res);
    else
        msg = '''params.el_n'' is set to an invalid value. Set to a positive integer, or -1 to remove the limit to the number of elements';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    % Create the pool of possible positions
    try
        pool = false(h_res, v_res);
    catch %ME
        msg = '''params.resolution'' exceeds system resources.';
        GERT_ShowError(fnc_name,msg,3);%4,ME);
    end
    
    % Two dilation disks: one for checking eucl_mindist, and one for
    % applying position noise to the contour
    if strcmp(GERT_matlv{1},'Matlab')
        dildisk_mindist = strel('disk',eucl_mindist,0);
        dildisk_noise = strel('disk',noise_dilrad,0);
        
        % Apply the position noise (do an imshow on the pool before and after
        % if you are unsure what is happening here)
        pool(sub2ind([h_res v_res],cdx,cdy)) = true;
        pool = imdilate(pool,dildisk_noise);
    else
        [idx1,idx2] = meshgrid(-ceil(eucl_mindist):ceil(eucl_mindist));
        dildisk_mindist = sqrt((idx1.^2) + (idx2.^2)) < eucl_mindist;
        [idx1,idx2] = meshgrid(-ceil(noise_dilrad):ceil(noise_dilrad));
        dildisk_noise = sqrt((idx1.^2) + (idx2.^2)) < noise_dilrad;
        pool(sub2ind([h_res v_res],cdx,cdy)) = true;
        if any(dildisk_noise)
            pool = imdilate(pool,dildisk_noise);
        end
    end
       
    % Create the temporary pool for batch placement
    try
        sel_points_pool = false(h_res, v_res);
    catch% ME
        msg = '''params.resolution'' exceeds system resources.';
        GERT_ShowError(fnc_name,msg,3);%4,ME);
    end

    tstart = tic; % Begin
    while elements.n < el_n
        
        % Check which contour positions are still available
        remaining_idx = find(pool);
        
        % figure; imshow(pool);
        
        if isempty(remaining_idx)
            if p.results.el_n > 0
                msg = strcat('The display is full. The target of ',num2str(el_n),' elements was not reached.');
                GERT_ShowError(fnc_name,msg,1);
            end
            break;
        end
        
        if strcmp(GERT_matlv{1},'Matlab')
            time_elapsed = toc(tstart);
        else
            time_elapsed = (double(tic) - double(tstart)) * 1e-6;
        end
        
        if time_elapsed > timeout
            msg = strcat('Timeout limit of ', timeout, ' seconds has been reached, quitting.');
            GERT_ShowError(fnc_name,msg,3);
            break;
        end
        
        % Adjust batch size near the end
        batch_size = min([batch_size el_n-elements.n]);
        
        % Create a batch of unique points
        cand_points = unique(remaining_idx( GERT_Aux_Randi(length(remaining_idx),[1 batch_size])));
        [cand_x,cand_y] = ind2sub([h_res v_res],cand_points);
        
        % Eliminate batch points that are too close to each other
        if ~isscalar(cand_points)
            dist_to_eachother = GERT_Aux_EuclDist(cand_x', cand_y', cand_x', cand_y');
            too_close = logical(dist_to_eachother<eucl_mindist);
            
            cand_n = size(dist_to_eachother,1);
            too_close = tril(too_close) & ~eye(cand_n);
            
            for i = 1:cand_n
                if any(too_close(i,:))
                    too_close(:,i) = false;
                end
            end
            
            sel_points_idx = ~any(too_close,2)';
            
        else
            sel_points_idx = true;
        end
        
        % Subtract the remaining points from the pool of possible positions
        if strcmp(GERT_matlv{1},'Matlab')
            sel_points_pool(:) = false;
            sel_points_pool(cand_points(sel_points_idx)) = true;
            sel_points_pool = imdilate(sel_points_pool,dildisk_mindist);
        else
            % Octave: pasting
            sel_points_pool(:) = false;
            for j =find(sel_points_idx)
                lc = cand_x(j)-ceil(eucl_mindist);
                rc = cand_x(j)+ceil(eucl_mindist);
                tc = cand_y(j)-ceil(eucl_mindist);
                bc = cand_y(j)+ceil(eucl_mindist);
                bnd = [lc h_res tc v_res] - [1 rc 1 bc];
                this_disk = dildisk_mindist;
                if any(bnd<0)
                    
                    cropby = abs(bnd).*(bnd<0);
                    
                    if any(cropby(1:2) > (ceil(eucl_mindist)*2)+1) || any(cropby(3:4) > (ceil(eucl_mindist)*2)+1)
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
        
        % Save their positions
        old_n = elements.n;
        new_n = sum(sel_points_idx);
        elements.x(old_n+1:old_n+new_n) = cand_x(sel_points_idx);
        elements.y(old_n+1:old_n+new_n) = cand_y(sel_points_idx);
    end
    
    % Convert back to the old coordinate system
    elements.x = ((elements.x-1) * ((h_or-1)/(h_res-1)) ) + min(contour.x) + (2*noise_dilrad);
    elements.y = ((elements.y-1) * ((v_or-1)/(v_res-1)) ) + min(contour.y) + (2*noise_dilrad);
    
    % Compute shortest Euclidean distances to the original contour
    % description points
    if length(contour.cdist) ~= (cdn+double(contour.closed))
        msg = 'No valid cdist present in contour description. Computing automatically...';
        GERT_ShowError(fnc_name,msg,1);
        contour = contour.compute_cdist;
    end
    cdist = contour.cdist;
    
    disttocont = GERT_Aux_EuclDist(elements.x, elements.y, contour.x, contour.y);
    [foo idx] = sort(disttocont,2);
    cpdist = cdist(idx(:,1));
    [cpdist idx] = sort(cpdist);
    elements.x = elements.x(idx);
    elements.y = elements.y(idx);
end

%% Compute orientations
if length(contour.lt) ~= cdn
    msg = 'No valid local tangents present in contour description. Computing automatically...';
    GERT_ShowError(fnc_name,msg,1);
    contour = contour.compute_lt;
end

lt = contour.lt;
if(contour.closed)
    lt(end+1) = lt(end);
end

ors = interp1(contour.cdist, lt, cpdist);

%% Tag as contour
elements = settag(elements,'c');

%% Log the output
GERT_log = add(GERT_log,'var',elements,'OUT_elements');
GERT_log = add(GERT_log,'var',ors,'OUT_ors');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

end

% Auxiliary function
function noise = generate_noise(method, amount, n)
    if strcmp(method,'Uniform')
        noise = amount*(rand(1,n)-0.5);
    elseif strcmp(method,'Gaussian')
        noise = amount*randn(1,n)*0.5;
        while any(abs(noise)>amount/2)
            idx = abs(noise)>amount/2;
            noise(idx) = amount*randn(1,sum(idx));
        end
    elseif strcmp(method,'Vector')
        if length(amount) < n
            msg = 'Noise vector is smaller than the number of noise points to be sampled from it. Please increase the vector.';
            GERT_ShowError(fnc_name,msg,3);
        end
        [foo idx] = sort(rand(1,length(amount)));
        noise = amount(idx(1:n));
    end
end
