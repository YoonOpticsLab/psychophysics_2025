function dmat = GERT_Aux_EuclDist(x1,y1,x2,y2)

% dmat = GERT_Aux_EuclDist(x1,y1,x2,y2)
%
% DESCRIPTION:
%  This function will compute all the pairwise Euclidean distances between
%  the points in row vectors (x1,y1) and (x2,y2). 
%
% ARGUMENTS:
%  x1 ------------------------ required
%                              1xN double
%                              Finite, real
%
%  y1 ------------------------ required
%                              1xN double
%                              Finite, real
%
%  x2 ------------------------ required
%                              1xM double
%                              Finite, real
%
%  y2 ------------------------ required
%                              1xM double
%                              Finite, real
%
% RETURNS:
%  dmat ---------------------- NxM double
%
%
% ---
% Original authors: Roland Bunschoten 
%                   Marcus Buehren
% http://www.mathworks.de/matlabcentral/fileexchange/71-distance-m
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

%% Check arguments
fnc_name = 'GERT_Aux_EuclDist';

% Four arguments required
if nargin ~= 4
    msg = 'Four input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'x1' - required
if ~GERT_Aux_ValidVec(x1,'double')
    msg = 'Input argument ''x1'' must be a 1xN double.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'x2' - required
if ~GERT_Aux_ValidVec(x2,'double')
    msg = 'Input argument ''x2'' must be a 1xN double.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'y1' - required
if ~GERT_Aux_ValidVec(y1,'double')
    msg = 'Input argument ''y1'' must be a 1xN double.';
    GERT_ShowError(fnc_name,msg,3); 
end

% 'y2' - required
if ~GERT_Aux_ValidVec(y2,'double')
    msg = 'Input argument ''y2'' must be a 1xN double.';
    GERT_ShowError(fnc_name,msg,3); 
end

%% Further validate the arguments
if length(x1) ~= length(y1) || length(x2) ~= length(y2)
    msg = 'Vectors ''x1'' and ''y1'' and ''x2'' and ''y2'' must be of equal length.';
    GERT_ShowError(fnc_name,msg,3); 
end

%% Compute
a = [x1; y1];
b = [x2; y2];

aa = sum(a.*a,1); 
bb = sum(b.*b,1);
dmat = sqrt(abs(aa( ones(size(bb,2),1), :)' + bb( ones(size(aa,2),1), :) - 2*a'*b));

%% All done