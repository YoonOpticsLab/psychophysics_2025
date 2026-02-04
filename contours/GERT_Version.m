function v = GERT_Version()

% v = GERT_Version
%
% DESCRIPTION:
%  Outputs the current version of GERT.
%
% ARGUMENTS: 
%  None.
% 
% DETAILS:
%  None.
%
% EXAMPLES:
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

%% Do stuff
% The version.txt file is structured as follows:
%
% Field 1-2             version numbers
% Field 3               ctd (continued from version, i.e. in development)
%                       rc (release candidate) 
%                       rel (release)
%			            alt (alternate release)
% Field 4               revision number in svn (0 if unreleased)
%

fh = fopen('version.txt');
va = textscan(fh,'%f %f %s %f');
v1 = va(1); v1 = num2str(v1{1});
v2 = va(2); v2 = num2str(v2{1});
status = va(3); status = status{1}; status = status{1};
rev = va(4); rev = num2str(rev{1});
fclose(fh);  
if ~nargout
    if strcmp(status,'rel') || strcmp(status, 'alt')
        disp(['Grouping Elements Rendering Toolbox v' v1 '.' v2]);
    else
        disp(['Grouping Elements Rendering Toolbox v' v1 '.' v2 ' ' status]);
    end
else
    v = [ v1 '.' v2];
end

%% All done