function [in_idx, out_idx, on_idx] = GERT_Aux_InContour(elements, polydef)

% [in_idx, out_idx, on_idx] = GERT_Aux_InContour(elements,polydef)
%
% DESCRIPTION:
%  This function will determine which ELEMENTS are situated inside a closed
%  GContour POLYDEF. Their indices will be returned as IN_IDX. Note that 
%  this will include elements lying exactly on the contour. Elements lying 
%  outside the contour can be retrieved as OUT_IDX.
%  If the POLYDEF is defined through a GElements object, a further
%  distinction is made, where elements identical to the POLYDEF members are
%  returned as ON_IDX. 
%
% ARGUMENTS:
%  elements ------------------ required
%                              1x1 GElements
%                              elements.n>0
%
%  polydef ------------------- required
%                              1x1 GContour or GElements
%                              polydef.n>0, closed
%
% RETURNS:
%  in_idx -------------------- 1xL double  
%
%  out_idx ------------------- 1xM double
%
%  on_idx -------------------- 1xN double
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

%% Check all arguments
fnc_name = 'GERT_Aux_InContour';

% Two arguments needed
if nargin ~= 2
    msg = 'Two input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'elements' - required
if ~isa(elements,'GElements') || ~isscalar(elements)
    msg = 'Input argument ''elements'' must be a 1x1 GElements';
    GERT_ShowError(fnc_name,msg,3);
end

% 'polydef' - required
if (~isa(polydef,'GContour')&&~isa(polydef,'GElements') )|| ~isscalar(polydef)
    msg = 'Input argument ''polydef'' must be a 1x1 GContour or GElements';
    GERT_ShowError(fnc_name,msg,3);
end

if ~elements.n 
    msg = 'No elements found in input argument ''elements''.';
    GERT_ShowError(fnc_name,msg,3); 
end

if isa(polydef,'GContour')&& ~polydef.closed
    msg = 'Input argument ''polydef'' must be a closed contour.';
    GERT_ShowError(fnc_name,msg,3); 
end

elements = validate(elements);
polydef = validate(polydef);

%% Perform the operation
all_idx = 1:elements.n;
inp = inpolygon(elements.x,elements.y,polydef.x,polydef.y);

if isa(polydef,'GElements')
    onp = ismember(elements.x,polydef.x) & ismember(elements.y,polydef.y);
    in_idx = all_idx(inp & ~onp);
    on_idx = all_idx(onp);
    out_idx = all_idx(~(inp|onp));
else
    in_idx = all_idx(inp);
    on_idx = [];
    out_idx = all_idx(~inp);
end

%% All done