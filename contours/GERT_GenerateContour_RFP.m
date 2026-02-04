function contour = GERT_GenerateContour_RFP(params)

% contour = GERT_GenerateContour_RFP(params)
%
% DESCRIPTION:
%  This function generates an Radial Frequency Pattern contour description
%  (Wilkinson, Wilson, & Habak, 1998). RFP's arise through sinusoidal
%  deformation of a number of base circles, that are then summed to
%  create a single contour. Each base circle has an identical base radius 
%  BASER, and a sinus deformation of amplitude AMP, frequency FREQ, and 
%  phase PH. The function returns a Cartesian contour description.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- baser -------------- required
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- amp ---------------- required
%      |                       1xN double
%      |                       >=0, finite, real
%      |
%      |- freq --------------- required
%      |                       1xN double
%      |                       >0, integer value, finite, real
%      |
%      |- ph ----------------- required
%      |                       1xN double
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
%      |- rot ---------------- optional, default: 0
%      |                       1x1 double
%      |                       finite, real
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
%  segment selected does not depend on the rotation ROT of the shape. Note 
%  that in the final stimulus images, the segment selection goes counter-
%  clockwise from 0 to 2*pi. Rotation is similarly counter-clockwise. Point 
%  0 is at the lowest point in the image. 
%  The SCALE parameter allows rescaling of the entire contour (default: 1).
%
% EXAMPLE: 
%  % Create an open contour segment 
%  params.baser = 10;
%  params.freq = [2 3 4];
%  params.amp = [1 0.5 2];
%  params.ph = [rand rand rand]*2*pi;
%  params.th_range = [0 pi];
% 
%  contour = GERT_GenerateContour_RFP(params);
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
fnc_name = 'GERT_GenerateContour_RFP';

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
p = addfield(p,'baser', 'req', @(x) ...
    GERT_Aux_ValidVec(x,'double',1) && x>0);
p = addfield(p,'amp', 'req', @(x) ...
    GERT_Aux_ValidVec(x,'double') && all(x>=0));
p = addfield(p,'freq', 'req', @(x) ...
    GERT_Aux_ValidVec(x,'double')  && all(x>0) && all(mod(x,1)==0));
p = addfield(p,'ph', 'req', @(x) ...
    GERT_Aux_ValidVec(x,'double'));
p = addfield(p,'th_range', [0 2*pi], @(x) ...
    GERT_Aux_ValidVec(x,'double',2)); 
p = addfield(p,'th_n', 1000, @(x) ...
    GERT_Aux_ValidVec(x,'double',1) && x>0 && mod(x,1)==0 );
p = addfield(p,'rot', 0, @(x) ...
    GERT_Aux_ValidVec(x,'double') );
p = addfield(p,'scale', 1, @(x) ...
    GERT_Aux_ValidVec(x,'double') && x>0);

p = parse(p,params);

if abs(diff(p.results.th_range))>2*pi
    msg = '''th_range'' must be smaller than 2*pi';
    GERT_ShowError(fnc_name,msg,3);
end

if length(p.results.amp) ~= length(p.results.freq) || length(p.results.amp) ~= length(p.results.ph)
    msg = 'Parameter vectors ''amp'', ''freq'' and ''ph'' must be of equal size.';
    GERT_ShowError(fnc_name,msg,3);
else
    nfc = length(p.results.amp);
end

if p.results.baser < sum(p.results.amp,2)
    msg = 'Negative radius values are possible. Increase ''baser'' or reduce ''amp''.';
    GERT_ShowError(fnc_name,msg,3);
end

baser = p.results.baser;
amp = p.results.amp;
freq = p.results.freq;
ph = p.results.ph;
th_range = p.results.th_range;
th_n = p.results.th_n;
rot = p.results.rot;
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
comp_matrix = zeros(nfc, length(pol.th));

for i = 1:nfc
    comp_matrix(i,:) = amp(i) * sin( (freq(i)*pol.th) + ph(i) );
end

pol.r = (baser + sum(comp_matrix,1)) * scale;

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