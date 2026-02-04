function cart = GERT_Aux_DrawArc(points,res)

% cart = GERT_Aux_DrawArc(points,res)
%
% DESCRIPTION:
%  This function will output an ellipsoid arc between two points in Cartesian
%  coordinates, at a given resolution. The POINTS matrix further needs to specify
%  the ellipse radii, its rotation, and two flags to determine which of 4 
%  possible solutions needs to be drawn. Multiple arcs can be drawn at once
%  using the third dimension.
%
% ARGUMENTS:
%  points -------------------- required
%                              2x5xN double
%                              Finite, real; column 2 >0; column 4 [0 1]
%
%  res ----------------------- required
%                              1x1 double
%                              >0, integer value, finite, real
%
% RETURNS:
%  cart ---------------------- 2xM double, where M = res * N (minus identical points)
%
% DETAILS:
%  The POINTS input argument contains the same information as described in
%  the specifications of the SVG graphic file format, see:
%
%       http://www.w3.org/TR/SVG/paths.html#PathDataEllipticalArcCommands
%
%  The first column contains the X and Y coordinates of the start point.
%  The second column contains the X and Y radii of the ellipse
%  The third column contains its rotation (second value is ignored)
%  The fourth column contains the large arc and sweep flags
%  The fifth column contains the X and Y coordinates of the end point
%
% EXAMPLE: 
%  % From 5,10 to 20,0, radii 20,10, no rotation, large arc, positive sweep
%  points = [5,20,0,1,20; 10,10,0,1,0];
%  cart = GERT_Aux_DrawArc(points, 100);
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
%% Clean this file up, it works but could be much much better written
%%

GERT_Init;

%% Check the arguments
fnc_name = 'GERT_Aux_DrawArc';

% Two arguments required
if nargin ~= 2
    msg = 'Two input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'points' - required
if ~isa(points,'double') || size(points,1) ~= 2 || size(points,2) ~= 5 || ...
        any(~isfinite(points(:))) || any(imag(points(:))) || ...
        any(points(:,2,:) < 0) || any(points(:,4,:) ~= 1 & points(:,4,:) ~= 0)
    msg = 'Input argument ''points'' must be a valid 2x5xN double, type ''help GERT_Aux_DrawArc'' for more information.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'res' - required
if ~GERT_Aux_ValidVec(res,'double',1) || mod(res,1) || res <= 0
    msg = 'Input argument ''res'' must be a positive, integer value scalar double.';
    GERT_ShowError(fnc_name,msg,3); 
end

%% Draw the various arcs
tmpcart.x = [];
tmpcart.y = [];

for n = 1:size(points,3)
    
    % Start point
    x1 = points(1,1,n);
    y1 = points(2,1,n);
    
    % End point
    x2 = points(1,5,n);
    y2 = points(2,5,n);
    
    r1 = x1-x2;
    r2 = y1-y2;
    rf = (x1-x2)/(y1-y2);
    
    % Radii
    a = points(1,2,n);
    b = points(2,2,n);
    
    % Rotation
    phi = points(1,3,n);
    
    % Flags
    f1 = points(1,4,n);
    f2 = points(2,4,n);
    
    % Do the computations
    insq = (((2*a*rf*sin(phi))-(2*a*cos(phi)))^2) - (4*(-(b*rf*cos(phi))-(b*sin(phi)))*((b*rf*cos(phi))+(b*sin(phi))));
    divp = b*((rf*cos(phi))+sin(phi));
    minp = (a*rf*sin(phi))-(a*cos(phi));
    
    tsum1 = 2*atan(((0.5*sqrt(insq))-minp)/divp);
    tsum2 = 2*atan(((-0.5*sqrt(insq))-minp)/divp);
    
    tdiff1 = asin(r1/((-2*a*cos(phi)*sin(tsum1)) - (2*b*sin(phi)*cos(tsum1))));
    tdiff2 = asin(r1/((-2*a*cos(phi)*sin(tsum2)) - (2*b*sin(phi)*cos(tsum2))));
    
    if ~isreal(tdiff1) || ~isreal(tdiff2)
        msg = 'Impossible to draw arc given these parameters';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    % First set of possible arcs
    t1 = tsum1+tdiff1;
    t2 = tsum1-tdiff1; 
    xc1 = x1 - ((a*cos(t1)*cos(phi))-(b*sin(phi)*sin(t1)));
    yc1 = y1 - ((a*cos(t1)*sin(phi))+(b*cos(phi)*sin(t1)));
    
    start1 = t1;
    if abs(start1)>0 && abs(start1)<=pi/2
        quadr = 1;
    elseif abs(start1)>pi/2 && abs(start1)<=pi
        quadr = 2;
    elseif abs(start1)>pi && abs(start1)<=3*pi/2
        quadr = 3;
    elseif abs(start1)>3*pi/2 && abs(start1)<=2*pi
        quadr = 4;
    end
    if sign(start1) == -1
        quadr = 5-quadr;
    end
    start1 = atan((b/a)*tan(start1));
    if sign(t1) == 1 && (quadr == 2 || quadr == 3)
        start1 = start1 + pi;
    elseif sign(t1) == -1 && (quadr == 2 || quadr == 3)
        start1 = start1 - pi;
    end
    start1 = mod(start1,2*pi);
    
    stop1 = t2; 
    if abs(stop1)>0 && abs(stop1)<=pi/2
        quadr = 1;
    elseif abs(stop1)>pi/2 && abs(stop1)<=pi
        quadr = 2;
    elseif abs(stop1)>pi && abs(stop1)<=3*pi/2
        quadr = 3;
    elseif abs(stop1)>3*pi/2 && abs(stop1)<=2*pi
        quadr = 4;
    end
    if sign(stop1) == -1
        quadr = 5-quadr;
    end
    stop1 = atan((b/a)*tan(stop1));
    if sign(t2) == 1 && (quadr == 2 || quadr == 3)
        stop1 = stop1 + pi;
    elseif sign(t2) == -1 && (quadr == 2 || quadr == 3)
        stop1 = stop1 - pi;
    end
    stop1 = mod(stop1,2*pi);
    
    % Second set of possible arcs
    t1 = tsum2+tdiff2;
    t2 = tsum2-tdiff2; 
    xc2 = x1 - ((a*cos(t1)*cos(phi))-(b*sin(phi)*sin(t1)));
    yc2 = y1 - ((a*cos(t1)*sin(phi))+(b*cos(phi)*sin(t1)));
    
    start2 = t1;
    if abs(start2)>0 && abs(start2)<=pi/2
        quadr = 1;
    elseif abs(start2)>pi/2 && abs(start2)<=pi
        quadr = 2;
    elseif abs(start2)>pi && abs(start2)<=3*pi/2
        quadr = 3;
    elseif abs(start2)>3*pi/2 && abs(start2)<=2*pi
        quadr = 4;
    end
    if sign(start2) == -1
        quadr = 5-quadr;
    end
    start2 = atan((b/a)*tan(start2));
    if sign(t1) == 1 && (quadr == 2 || quadr == 3)
        start2 = start2 + pi;
    elseif sign(t1) == -1 && (quadr == 2 || quadr == 3)
        start2 = start2 - pi;
    end
    start2 = mod(start2,2*pi);
    
    stop2 = t2; 
    if abs(stop2)>0 && abs(stop2)<=pi/2
        quadr = 1;
    elseif abs(stop2)>pi/2 && abs(stop2)<=pi
        quadr = 2;
    elseif abs(stop2)>pi && abs(stop2)<=3*pi/2
        quadr = 3;
    elseif abs(stop2)>3*pi/2 && abs(stop2)<=2*pi
        quadr = 4;
    end
    if sign(stop2) == -1
        quadr = 5-quadr;
    end
    stop2 = atan((b/a)*tan(stop2));
    if sign(t2) == 1 && (quadr == 2 || quadr == 3)
        stop2 = stop2 + pi;
    elseif sign(t2) == -1 && (quadr == 2 || quadr == 3)
        stop2 = stop2 - pi;
    end
    stop2 = mod(stop2,2*pi);
    
    % Draw arcs using the GERT_GenerateContour_Ellipse function
    params.hax = a;
    params.vax = b;
    params.rot = phi;
    params.th_n = res;
    
    % Ellipse 1, arc1
    params.th_range = [start1 stop1];
    arc11 = GERT_GenerateContour_Ellipse(params);
    arc11.x = arc11.x+xc1;
    arc11.y = arc11.y+yc1;
    
    arc11flags(1) = abs(start1-stop1) > pi;
    arc11flags(2) = start1 > stop1;
    
    % Ellipse 1, arc2
    if start1 > stop1
        params.th_range = [start1-2*pi stop1];
    else
        params.th_range = [start1+2*pi stop1];
    end
    arc12 = GERT_GenerateContour_Ellipse(params);
    arc12.x = arc12.x+xc1;
    arc12.y = arc12.y+yc1;
    
    arc12flags(1) = ~arc11flags(1);
    arc12flags(2) = ~arc11flags(2);
    
    % Ellipse 2, arc1
    params.th_range = [start2 stop2];
    arc21 = GERT_GenerateContour_Ellipse(params);
    arc21.x = arc21.x+xc2;
    arc21.y = arc21.y+yc2;
    
    arc21flags(1) = abs(start2-stop2) > pi;
    arc21flags(2) = start2 > stop2;
    
    % Ellipse 2, arc2
    if start2 > stop2
        params.th_range = [start2-2*pi stop2];
    else
        params.th_range = [start2+2*pi stop2];
    end
    arc22 = GERT_GenerateContour_Ellipse(params);
    arc22.x = arc22.x+xc2;
    arc22.y = arc22.y+yc2;
    
    arc22flags(1) = ~arc21flags(1);
    arc22flags(2) = ~arc21flags(2);
    
    % Now decide what to use
    % Flag 1 determines whether the arc is small (0) or large(1)
    % Flag 2 determines whether the angle increases positively (1) or
    % negatively (0)
    
    % Visual overview
    % plot(arc11.x,arc11.y,'k.') %00
    % hold on;
    % plot(arc12.x,arc12.y,'r.') %11
    % plot(arc21.x,arc21.y,'g.') %10
    % plot(arc22.x,arc22.y,'b.') %01
    % axis equal
    
    if all(arc11flags == [f1 f2])
        arc = arc11;
    elseif all(arc12flags == [f1 f2])
        arc = arc12;
    elseif all(arc21flags == [f1 f2])
        arc = arc21;   
    elseif all(arc22flags == [f1 f2])
        arc = arc22;
    else
        msg = 'Error, mail Maarten and tell him to fix his code goddamnit';
        GERT_ShowError(fnc_name,msg,3);         
    end
    
    % Check whether this arc is connected to the last one
    if ~isempty(tmpcart.x)
        if tmpcart.x(end) == arc.x(1) && tmpcart.y(end) == arc.y(1)
            tmpcart.x = [tmpcart.x arc.x(2:end)];
            tmpcart.y = [tmpcart.y arc.y(2:end)];
        else
            tmpcart.x = [tmpcart.x arc.x];
            tmpcart.y = [tmpcart.y arc.y];
        end
    else
        tmpcart.x = arc.x;
        tmpcart.y = arc.y;
    end
    
end

[tmpcart.x,tmpcart.y] = GERT_Aux_RemoveIdenticalPoints(tmpcart.x,tmpcart.y);
cart(1,:) = tmpcart.x;
cart(2,:) = tmpcart.y;

%% All done