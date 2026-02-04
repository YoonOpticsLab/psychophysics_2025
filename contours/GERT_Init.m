% GERT_Init
%
% DESCRIPTION:
%  Initialization routine. Global variables are initialized, and the
%  necessary dependencies are checked.
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

global GERT_valid;
    
if isempty(GERT_valid)
    GERT_valid = false;
end

if ~GERT_valid
    
    global GERT_matlv;
    global GERT_path;
    global GERT_elerrcheck;
    global GERT_randseries;
    global GERT_log;
    
    GERT_elerrcheck = true;
    
    GERT_randseries = rand(1,100);
    
    GERT_matlv = cell(1,3);
    GERT_matlv{1} = '';
    GERT_matlv{2} = 0;
    GERT_matlv{3} = 0;
    
    GERT_path = fileparts(which('GERT_Init'));
    addpath([GERT_path filesep 'resources']);
    
    GERT_log = GLog;
    
    GERT_Version;
    GERT_Dependencies;
    
    disp('Initialization successful!');
    GERT_valid = true;
    
end
    
clear GERT_valid GERT_matlv GERT_elerrcheck;