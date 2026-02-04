% ccc()
%
% DESCRIPTION:
%  Clear Close Clear. This removes all variables, both local and global, closes all figures,
%  and clears the command window. The credit for this function goes 
%  entirely to Bart Machilsen, who originally conceived and implemented the 
%  CCC concept. We also acknowledge the useful feedback of Tom Putzeys.
%
% ARGUMENTS:
%  None.
%
% RETURNS:
%  None.
%
%
% ---
% Authors:  Bart Machilsen (bart.machilsen@ppw.kuleuven.be)  
%           Maarten Demeyer (maarten.demeyer@ppw.kuleuven.be)         
%
% From:     University of Leuven (K.U. Leuven)
%           Laboratory of Experimental Psychology
%           Leuven, BELGIUM
%
% This function is part of GERT, the Grouping Elements Rendering Toolbox
% Find GERT at: http://www.gestaltrevision.be/GERT/
%

clear variables
clear global
clear functions
close('all');
clc;
