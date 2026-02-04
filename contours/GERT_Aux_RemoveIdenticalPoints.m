function [xv,yv,idx] = GERT_Aux_RemoveIdenticalPoints(x,y)

% [xv,yv,idx] = GERT_Aux_RemoveIdenticalPoints(x,y)
%
% DESCRIPTION:
%  This function will remove identical points from Cartesian pairs of 
%   coordinates, returning both the values and the indices.
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
%  xv ------------------------ 1xM double  
%
%  yv ------------------------ 1xM double
%
%  idx ----------------------- 1xM double  
%
% DETAILS:
%  None.
%
% EXAMPLE:
%  None.
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
fnc_name = 'GERT_Aux_RemoveIdenticalPoints';

% Two arguments needed
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

if length(x) ~= length(y)
    msg = 'Input argument fields ''x'' and ''y'' must have the same size.';
    GERT_ShowError(fnc_name,msg,3);
end

if isempty(x)
    msg = 'No points found.';
    GERT_ShowError(fnc_name,msg,3);
end

%% Remove identical points
dists = GERT_Aux_EuclDist(x,y,x,y);
dists = dists + tril(ones(size(dists,1),size(dists,2)));
dists = min(dists,[],2);

idx = find(dists>0.001);

xv = x(idx);
yv = y(idx);

%% All done