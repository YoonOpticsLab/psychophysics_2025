function [elements ors] = GERT_PlaceElements_Snake(params)

% [elements ors] = GERT_PlaceElements_Snake(params)
%
% DESCRIPTION:
%  This function generates directly generates 'snake' grouping elements,
%  without needing to define an underlying continuous contour description.
%  Similar to the methods of Hess & Dakin (1999) it will construct a snake
%  as a series of SEG_N connected line segments, each of length SEG_LEN. 
%  The average angle between each successive segment equals SEG_OR_AVGANG.
%  The snake elements are then placed on the midpoints of these segments. 
%  The function returns both the position of the snake elements, and the
%  orientation of the segments on which they were placed.
%
% ARGUMENTS:
%
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- seg_n -------------- required
%      |                       1x1 double    
%      |                       >0, integer value, finite, real
%      |
%      |- seg_len ------------ required
%      |                       1x1 double
%      |                       >0, finite, real
%      |
%      |- seg_or_avgang ------ required
%      |                       1x1 double
%      |                       >=0 <=pi, finite, real
%      |
%      |- seg_or_jitang ------ optional, default: 0
%      |                       1x1 double
%      |                       >=0 <=seg_or_avgang, finite, real
%      |
%      |- seg_or_bias -------- optional, default: 0.5
%      |                       1x1 double
%      |                       >=0 <=1, finite, real
%      |
%      |- pt_noise_onseg ----- optional, default: 0
%      |                       1x1 double
%      |                       >=0, finite, real
%      |
%      |- pt_noise_offseg ---- optional, default: 0
%      |                       1x1 double
%      |                       >=0, finite, real
%      |
%      |- rot ---------------- optional, default: rand*2*pi
%      |                       1x1 double
%      |                       >=0 <=2*pi, finite, real
%
% RETURNS:
%  elements ------------------ 1x1 GElements
%
%  ors ----------------------- 1xn double
%
% DETAILS:
%  The shape of the snake can be manipulated further. SEG_OR_JITANG
%  controls the amount of uniform orientation jitter, relative to the
%  SEG_OR_AVGANG average angle between successive line segments. The
%  default segment orientation jitter is 0. Whereas the chance of this segment 
%  angle pointing to the left or the right is by default 0.5, SEG_OR_BIAS
%  allows the introduction of bias, between 0 and 1. 
%  Position noise can be added to the element placement, either along the
%  segment (PT_NOISE_ONSEG) or perpendicular to it (PT_NOISE_OFFSEG). By
%  default both are equal to 0, meaning no noise. As this value nears 1, a
%  uniform noise equal to the length of the segment can be applied.
%  Position noise exceeding the segment length is not possible.
%  An overall rotation ROT can also be specified. By default the rotation
%  equals rand*2*pi, that is, completely random.
%
% EXAMPLE: 
%  % Seven segment snake with slight position noise along the segment
%  params.seg_n = 7;
%  params.seg_len = 5; 
%  params.seg_or_avgang = pi/6;
%  params.seg_or_jitang = pi/10;
%  params.pt_noise_onseg = 0.2;
%  snake = GERT_PlaceElements_Snake(params);
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
fnc_name = 'GERT_PlaceElements_Snake';

% One argument
if nargin ~= 1
    msg = 'One input arguments needed.';
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
GERT_log = add(GERT_log,'on');
GERT_log = add(GERT_log,'var',params,'IN_params');

%% Parse the input
% Parse 'params'
p = GStructParser;
p = addfield(p,'seg_n', 'req', @(x) GERT_Aux_ValidVec(x,'double',1) ...
    && mod(x,1)==0 && x>0);
p = addfield(p,'seg_len', 'req', @(x) GERT_Aux_ValidVec(x,'double',1) ...
    && x>0);
p = addfield(p,'seg_or_avgang', 'req', @(x) GERT_Aux_ValidVec(x,'double',1) ...
    && x>=0 && x<=pi);
p = addfield(p,'seg_or_jitang', 0, @(x) GERT_Aux_ValidVec(x,'double',1) ...
    && x>=0 && x<=pi);
p = addfield(p,'seg_or_bias', 0.5, @(x) GERT_Aux_ValidVec(x,'double',1) ...
    && x>=0 && x<=1);
p = addfield(p,'pt_noise_onseg', 0, @(x) GERT_Aux_ValidVec(x,'double',1) ...
    && x>=0 && x<=1);
p = addfield(p,'pt_noise_offseg', 0, @(x) GERT_Aux_ValidVec(x,'double',1) ...
    && x>=0 && x<=1);
p = addfield(p,'rot', rand*2*pi, @(x)  GERT_Aux_ValidVec(x,'double',1) ...
    && x>=0 && x<=2*pi);

p = parse(p,params);

if p.results.seg_or_avgang < p.results.seg_or_jitang
    msg = 'Segment angle jitter must not be larger than the average angle.';
    GERT_ShowError(fnc_name,msg,3);
end

seg_n = p.results.seg_n;                        
seg_len = p.results.seg_len;                  
seg_or_avgang = p.results.seg_or_avgang;       
seg_or_jitang = p.results.seg_or_jitang;       
seg_or_bias = p.results.seg_or_bias;           
pt_noise_onseg = p.results.pt_noise_onseg;   
pt_noise_offseg = p.results.pt_noise_offseg;  
rot = p.results.rot;        

%% Segments
segment_ors = ones(1,seg_n);
segment_ors(rand(1,seg_n) < seg_or_bias) = -1;
segment_ors = segment_ors .* (seg_or_avgang + ((rand(1,seg_n)-0.5)*2*seg_or_jitang));
segment_ors(1) = rand*pi*2;
segment_ors = cumsum(segment_ors);

% First point at (0,0)
segment_pts = zeros(seg_n+1,2);
segment_pts(1,:) = [0 0];

% Determine the endpoint of each segment
for i = 1:seg_n
    segment_pts(i+1,1) = segment_pts(i,1) + (seg_len * sin(segment_ors(i)));
    segment_pts(i+1,2) = segment_pts(i,2) + (seg_len * cos(segment_ors(i)));
end

%% Elements
snake = GElements;

% Center the snake
cx = mean(segment_pts(:,1));
cy = mean(segment_pts(:,2));

segment_pts(:,1) = (segment_pts(:,1)-cx);
segment_pts(:,2) = (segment_pts(:,2)-cy);

% Rotate the snake
main_axis = atan((segment_pts(end,2)-segment_pts(1,2))/...
    (segment_pts(end,1)-segment_pts(1,1)));
[th, r] = cart2pol(segment_pts(:,1),segment_pts(:,2));
th = th - main_axis + rot;
[segment_pts(:,1),segment_pts(:,2)] = pol2cart(th,r);

% Place element on the segment
sn = (rand(seg_n,1).*pt_noise_onseg)+((1-pt_noise_onseg)*0.5);
snake.x = ((sn.*segment_pts(1:end-1,1)) + ((1-sn).*segment_pts(2:end,1)))';
snake.y = ((sn.*segment_pts(1:end-1,2)) + ((1-sn).*segment_pts(2:end,2)))';

sn = (rand(1,seg_n).*pt_noise_offseg)+((1-pt_noise_offseg)*0.5);
sn = sn-0.5;
xdiff = segment_pts(2:end,1) - segment_pts(1:end-1,1);
ydiff = segment_pts(2:end,2) - segment_pts(1:end-1,2);
snake.x = snake.x - (sn.*ydiff');
snake.y = snake.y + (sn.*xdiff');

elements = snake;

%% Also return segment orientations
xp = segment_pts(1:end-1,1);
yp = segment_pts(1:end-1,2);
xshp = segment_pts(2:end,1);
yshp = segment_pts(2:end,2);
ors = (pi/2) + atan2(xp-xshp,yp-yshp) ;
ors = mod(ors,2*pi);

%% Tag as contour
elements = settag(elements,'c');

%% Log the output
GERT_log = add(GERT_log,'var',elements,'OUT_elements');
GERT_log = add(GERT_log,'var',ors,'OUT_ors');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done