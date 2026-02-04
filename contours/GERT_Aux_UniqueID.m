function id = GERT_Aux_UniqueID(cvar)

% vals = GERT_Aux_UniqueID(cvar)
%
% DESCRIPTION:
%  This function takes a double or char matrix, and generates
%  a hash code which can serve as a unique ID of the contents of this
%  matrix.
%
% ARGUMENTS:
%  cvar ---------------------- required
%                              double or char string
%                              finite, real
%
% RETURNS:
%  id ------------------------ 1xN double
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

%% Generate the hash
% Don't check the arguments, for speed. 
% This function is used internally only anyway.
global GERT_randseries;

if ~isnumeric(cvar)
    cvar = double(cvar);
end

cvar = cvar(:)';
l = length(cvar);

if l>100
    msg = 'Maximum vector length to create a unique ID from: 100. Change this  value in GERT_Init (and here).';
    GERT_ShowError('GERT_Aux_UniqueID',msg,3);
end

id = sum(cvar .* GERT_randseries(1:l));

%% All done
