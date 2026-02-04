function tf = GERT_Aux_ValidVec(vec,type,val)

% tf = GERT_Aux_ValidVec(vec,type,val)
%
% DESCRIPTION:
%  This function will check whether VEC is a valid row vector of a given
%  TYPE and length VAL. No error checking, for speed.
%
% ARGUMENTS:
%  None.
%
% RETURNS:
%  None.
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
% Find GERT at: http://www.gestaltrevision.be
%

%% No type, no length
if nargin == 1 || (nargin==2 && isempty(type) )
    
    if isvector(vec) && size(vec,1)==1 && size(vec,2) > 0
        
        if isnumeric(vec)
            if all(isfinite(vec)) && ~any(imag(vec))
                tf = true;
            else
                tf = false;
            end
        else
            tf = true;
        end
        
    else
        tf = false;
    end

%% No type, length
elseif nargin == 3 && isempty(type)
    
    if isvector(vec) && size(vec,1)==1 && size(vec,2)==val
        
        if isnumeric(vec)
            if all(isfinite(vec)) && ~any(imag(vec))
                tf = true;
            else
                tf = false;
            end
        else
            tf = true;
        end
        
    else
        tf = false;
    end
    
%% Type, no length
elseif nargin == 2 || (nargin==3 && isempty(val) )
    
    if isvector(vec) && size(vec,1)==1 && size(vec,2)>0 && isa(vec,type)
       
        if isnumeric(vec)
            if all(isfinite(vec)) && ~any(imag(vec))
                tf = true;
            else
                tf = false;
            end
        else
            tf = true;
        end
        
    else
        tf = false;
    end

%% Type, length
elseif nargin==3
    
    if isvector(vec) && size(vec,1)==1 && size(vec,2) == val && isa(vec,type)
       
        if isnumeric(vec)
            if all(isfinite(vec)) && ~any(imag(vec))
                tf = true;
            else
                tf = false;
            end
        else
            tf = true;
        end
    else
        tf = false;
    end
    
else
    tf = false;
end

%% All done