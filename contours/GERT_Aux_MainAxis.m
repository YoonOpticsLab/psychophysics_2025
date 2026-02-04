function [main_axis pt] = GERT_Aux_MainAxis(x,y)

% [main_axis pt] = GERT_Aux_MainAxis(x,y)
%
% DESCRIPTION:
%   This function computes the main axis of a series of x and y coordinates.
%   They should described a closed contour. It also returns the centroid of
%   these coordinates.
%
% ARGUMENTS:
%  x ------------------------- required
%                              1xN double
%                              N>=0, finite, real
%
%  y ------------------------- required
%                              1xN double
%                              N>=0, finite, real
%
% RETURNS:
%  main_axis ----------------- 1x1 double  
%
%  pt ------------------------ 1x2 double  
%
% DETAILS:
%  None.
%
% EXAMPLE:
%  None.
%
%
% ---
% Original author: Roger Stafford
%      http://www.mathworks.com/matlabcentral/newsreader/view_thread/165770
%
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
fnc_name = 'GERT_Aux_MainAxis';

% One argument needed
if nargin ~= 2
    msg = 'Two input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'x' - required
if ~GERT_Aux_ValidVec(x,'double')
    msg = 'Input argument ''x'' must be a 1xN double';
    GERT_ShowError(fnc_name,msg,3);
end

%'y' - required
if ~GERT_Aux_ValidVec(y,'double')
    msg = 'Input argument ''y'' must be a 1xN double';
    GERT_ShowError(fnc_name,msg,3);
end

%% Parse and verify the input
if length(x) ~= length(y)
    msg = 'Input argument fields ''x'' and ''y'' must have the same size.';
    GERT_ShowError(fnc_name,msg,3);
end

%% Do the computation
A = [x; y]';
c = zeros(1,2);
[c(1),c(2)] = GERT_Aux_Centroid(x,y);
[u,s,v] = svd(A-repmat(c,size(A,1),1),0);
main_axis = -atan2(-v(2),-v(1));

pt = c;

%% All done