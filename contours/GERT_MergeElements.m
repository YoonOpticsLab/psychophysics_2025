function merged_elements = GERT_MergeElements(elements)

% merged_elements = GERT_MergeElements(elements)
%
% DESCRIPTION:
%  This function will join a vector of GElement objects into a single
%  GElements object. 
%
% ARGUMENTS:
%  elements ------------------ required
%                              1xN GElements or cell
%                              N>1
%
% RETURNS:
%  merged_elements ----------- 1x1 GElements
%
% DETAILS:  
%  None.
%
% EXAMPLE: 
%  % Place two identical snakes on either side of a display
%  els = GERT_PlaceElements_Snake(params);
%  els1 = GERT_Transform_Shift(els,[-100 0]);
%  els2 = GERT_Transform_Shift(els,[100 0]);
%  all_els = GERT_MergeElements([els1 els2]);
%  all_els.dims = [-200 200 -200 200];
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
fnc_name = 'GERT_MergeElements';

% One argument required
if nargin ~= 1
    msg = 'One input argument needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'elements' - required
if ~GERT_Aux_ValidVec(elements,'GElements') && ~GERT_Aux_ValidVec(elements,'cell') 
    msg = 'Input argument ''elements'' must be a 1xN GElements or cell vector.';
    GERT_ShowError(fnc_name,msg,3);
end


%% Log the input
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',elements,'IN_elements');

%% Merge them
merged_elements = GElements;

for i = 1:length(elements)
       
    % Validate the GElements object
    if iscell(elements)
        els = elements{i};
        if ~GERT_Aux_ValidVec(els,'GElements',1)
            msg = 'Cell inputs should contain only scalar GElements objects.';
            GERT_ShowError(fnc_name,msg,3);
        end
    else
        els = elements(i);
    end
        
    els = validate(els);
    
    % Coordinates
    prev_size = merged_elements.n;
    merged_elements.x = [merged_elements.x els.x];
    merged_elements.y = [merged_elements.y els.y];
    
    % Dims
    if ~isempty(merged_elements.dims) && ~isempty(els.dims) && ...
            any(merged_elements.dims - els.dims)
       msg = 'The ''elements'' vector to be merged contains various different display dimension specifications. Retaining the first...';
       GERT_ShowError(fnc_name,msg,1);
    end
    
    if ~isempty(els.dims) && isempty(merged_elements.dims)
        merged_elements.dims = els.dims;
    end
    
    % Tags
    ut = unique(els.tags{1});   
    
    for j = 1:length(ut)
        idx = find(els.tags{1} == ut);
        merged_elements = settag(merged_elements,ut(j),prev_size+idx);
    end
    
end

%% Log the output
GERT_log = add(GERT_log,'var',merged_elements,'OUT_merged_elements');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done