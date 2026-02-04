function cart = GERT_Aux_DrawBezier(points,res)

% cart = GERT_Aux_DrawBezier(points,res)
%
% DESCRIPTION:
%  This function will output a cubic Bezier curve in Cartesian coordinates, 
%  at a given resolution. The POINTS matrix further specifies the
%  coordinates of both Bézier control points. Multiple curves can be drawn 
%  at once using the third dimension.
%
% ARGUMENTS:
%  points -------------------- required
%                              2x4xN double
%                              Finite, real
%
%  res ----------------------- required
%                              1x1 double
%                              >0, integer value, finite, real
%
% RETURNS:
%  cart ---------------------- 2xM double, where M = res * N (minus identical points)
%
% DETAILS:
%  The POINTS input argument is logically structured to contain the start
%  point, the first control point, the second control point, and the end
%  point in its columns, respectively.
%
% EXAMPLE: 
%  points = [5,10,15,20; 0,10,10,0];
%  cart = GERT_Aux_DrawBezier(points, 100);
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

%%
%% Clean this file up some more
%%

GERT_Init;

%% Check the arguments
fnc_name = 'GERT_Aux_DrawBezier';

% Two arguments required
if nargin ~= 2
    msg = 'Two input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'points' - required
if ~isa(points,'double') || size(points,1) ~= 2 || size(points,2) ~= 4 || any(~isfinite(points(:)))
    msg = 'Input argument ''points'' must be a 2x4xN double with finite elements.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'res' - required
if ~GERT_Aux_ValidVec(res,'double',1) || mod(res,1) || res <= 0
    msg = 'Input argument ''res'' must be a positive, integer value scalar double.';
    GERT_ShowError(fnc_name,msg,3); 
end

%% Draw the Béziers
t = linspace(0,1,res);
tmpcart.x = [];
tmpcart.y = [];

for n = 1:size(points,3)
    
    cx = (((1-t).^3).*points(1,1,n)) + (3.*((1-t).^2).*t.*points(1,2,n)) + ...
        (3.*(1-t).*(t.^2).*points(1,3,n)) + ((t.^3).*points(1,4,n));
    
    cy = (((1-t).^3).*points(2,1,n)) + (3.*((1-t).^2).*t.*points(2,2,n)) + ...
        (3.*(1-t).*(t.^2).*points(2,3,n)) + ((t.^3).*points(2,4,n));
    
    if ~isempty(tmpcart.x)
        if tmpcart.x(end) == cx(1) && tmpcart.y(end) == cy(1)
            tmpcart.x = [tmpcart.x cx(2:end)];
            tmpcart.y = [tmpcart.y cy(2:end)];
        else
            tmpcart.x = [tmpcart.x cx];
            tmpcart.y = [tmpcart.y cy];
        end
    else
        tmpcart.x = cx;
        tmpcart.y = cy;
    end
    
    % Visualization
    % plot(cx,cy,'k-');
    % plot(points(1,[1 4],n),points(2,[1 4],n),'rs');
    % plot(points(1,[2 3],n),points(2,[2 3],n),'b.');
    % line(points(1,1:2,n),points(2,1:2,n));
    % line(points(1,3:4,n),points(2,3:4,n));
    
end

[tmpcart.x,tmpcart.y] = GERT_Aux_RemoveIdenticalPoints(tmpcart.x,tmpcart.y);
cart(1,:) = tmpcart.x;
cart(2,:) = tmpcart.y;

%% All done