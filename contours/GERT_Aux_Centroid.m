function [x0,y0] = GERT_Aux_Centroid(x,y)

% [x0,y0] = GERT_Aux_Centroid(x,y)
%
% DESCRIPTION:
%   This function computes the centroid of a series of x and y coordinates.
%   They should described a closed contour.
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
%  x0 ------------------------ 1x1 double  
%
%  y0 ------------------------ 1x1 double
%
% DETAILS:
%  None.
%
% EXAMPLE:
%  None.
%
%
% ---
% Original author: Kirill K. Pankratov (SaGA toolbox)
%      http://puddle.mit.edu/~glenn/kirill/saga.html
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
fnc_name = 'GERT_Aux_Centroid';

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

%% Parse and verify the input
if length(x) ~= length(y)
    msg = 'Input argument fields ''x'' and ''y'' must have the same size.';
    GERT_ShowError(fnc_name,msg,3);
end

%% Do the computation
% Close the contour
x = [x(:); x(1)];
y = [y(:); y(1)];

l = length(x);

% X-mean: Int{x^2*dy} 
del = y(2:l)-y(1:l-1);
v = x(1:l-1).^2+x(2:l).^2+x(1:l-1).*x(2:l);
x0 = v'*del;

% Y-mean: Int{y^2*dx} 
del = x(2:l)-x(1:l-1);
v = y(1:l-1).^2+y(2:l).^2+y(1:l-1).*y(2:l);
y0 = v'*del;

% Calculate area: Int{y*dx}
a = (y(1:l-1)+y(2:l))'*del;
tol= 2*eps;

if abs(a)<tol
  msg = 'Area of polygon is close to 0.';
  GERT_ShowError(fnc_name,msg,1);
  a = a+sign(a)*tol+(~a)*tol;
end

% Multiplier
a = 1/3/a;

% Divide by area
x0 = -x0*a;
y0 =  y0*a;

%% All done

