function contour = GERT_GenerateContour_Ellipse(params)

% contour = GERT_GenerateContour_Ellipse(params)
%
% DESCRIPTION:
%  This function generates an ellipse contour description, from the length
%  of the horizontal and vertical semi-axes (HAX and VAX) and clockwise rotation
%  (ROT) defined. It returns a Cartesian contour description.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- hax ---------------- required
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- vax ---------------- required
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- rot ---------------- optional, default: 0
%      |                       1x1 double
%      |                       finite, real
%      |
%      |- th_range ----------- optional, default: [0 2*pi]
%      |                       1x2 double
%      |                       finite, real
%      |
%      |- th_n --------------- optional, default: 1000
%      |                       1x1 double
%      |                       >1, integer value, finite, real
%      |
%      |- scale -------------- optional, default: 1
%      |                       1x1 double
%      |                       >0, finite, real
%
% RETURNS:
%  contour ------------------- 1x1 GContour
%
% DETAILS:
%  The resolution of the contour description is chosen through setting TH_N
%  (default: 1000 points). To generate an open contour, change the
%  beginning and ending values in TH_RANGE. The function will return the
%  contour segment that is always enclosed between the lowest and the
%  highest value, but in reverse if the first value is the highest. The
%  segment selected does not depend on the rotation of the shape. Note that
%  in the final stimulus images, the segment selection goes counter-clockwise
%  from 0 to 2*pi. Rotation is similarly counter-clockwise. An ellipse
%  where shax<lax will then be vertically oriented, with point 0 at its
%  lowest point in the image. 
%  The SCALE parameter allows rescaling of the entire contour (default: 1).
%
% EXAMPLE: 
%  % Generate an ellipse quadrant, rotated by 45�
%  params.hax = 50;
%  params.vax = 100;
%  params.rot = pi/4;
%  params.th_range = [0 pi/2];
% 
%  contour = GERT_GenerateContour_Ellipse(params);
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

%% Check arguments
fnc_name = 'GERT_GenerateContour_Ellipse';

% One argument required
if nargin ~=1
    msg = 'One input argument required';
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
GERT_log = add(GERT_log,'var',params,'IN_params');

%% Parse the input
% Parse 'params'
p = GStructParser;
p = addfield(p,'hax', 'req', @(x) ...
   GERT_Aux_ValidVec(x,'double') && x>0);
p = addfield(p,'vax', 'req', @(x) ...
   GERT_Aux_ValidVec(x,'double') && x>0);
p = addfield(p,'rot', 0, @(x) ...
   GERT_Aux_ValidVec(x,'double',1));
p = addfield(p,'th_range', [0 2*pi], @(x) ...
   GERT_Aux_ValidVec(x,'double',2));
p = addfield(p,'th_n', 1000, @(x) ...
   GERT_Aux_ValidVec(x,'double',1) && x>0 && mod(x,1)==0);
p = addfield(p,'scale', 1, @(x) ...
   GERT_Aux_ValidVec(x,'double',1) && x>0);

p = parse(p,params);

if abs(diff(p.results.th_range))>2*pi
    msg = '''th_range'' must be smaller than 2*pi';
    GERT_ShowError(fnc_name,msg,3);
end

hax = p.results.hax;
vax = p.results.vax;
rot = p.results.rot;
th_range = p.results.th_range;
th_n = p.results.th_n;
scale = p.results.scale;

clear params p;

%% Construct the linspace
if mod(th_range(1)-th_range(2),2*pi) == 0
    pol.th = linspace(th_range(1), th_range(2), th_n+1);
    pol.th = pol.th(2:end);
    pol.closed = true;
else
    pol.th = linspace(th_range(1), th_range(2), th_n);
    pol.closed = false;
end

%% Compute the polar coordinates
pol.r = (hax*vax) ./ sqrt(((vax*cos(pol.th)).^2)+((hax*sin(pol.th)).^2));
pol.r = pol.r * scale;

%% Apply rotation, normalize th values
pol.th = mod(pol.th+rot,2*pi);

%% Compute the Cartesian coordinates
contour = GContour;
contour.x = pol.r.*cos(pol.th);
contour.y = pol.r.*sin(pol.th);
contour.closed = pol.closed;

%% Compute distances and tangents along the contour
contour = rmid(contour);
contour = compute_cdist(contour);
contour = compute_lt(contour);
contour = validate(contour);

%% Log the output
GERT_log = add(GERT_log,'var',contour,'OUT_contour');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done