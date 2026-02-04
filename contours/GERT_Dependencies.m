function GERT_Dependencies

% GERT_CheckDependencies
%
% DESCRIPTION:
%  This function will quickly check whether all necessary components are
%  present in your Matlab installation.
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

fnc_name = 'GERT_CheckDependencies';

%% Matlab version: 2007b and up
global GERT_matlv;

v = ver('Matlab');
if ~isempty(v)
    GERT_matlv{1} = 'Matlab';
    idx=findstr(v.Version,'.');
    GERT_matlv{2} = str2double(v.Version(1:idx-1));
    GERT_matlv{3} = str2double(v.Version(idx+1:end));
    
    if isempty(ver('images'))
        msg = 'Image Processing Toolbox is required.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    if isempty(ver('stats'))
    	msg = 'Statistics Toolbox is not installed.';
    	GERT_ShowError(fnc_name,msg,1);
    end
end

v = ver('Octave');
if ~isempty(v)
    GERT_matlv{1} = 'Octave';
    idx=findstr(v.Version,'.');
    GERT_matlv{2} = str2double(v.Version(1:idx(1)-1));
    GERT_matlv{3} = str2double(v.Version(idx(1)+1:idx(2)-1));
    
    if isempty(ver('image'))
        msg = 'Image Processing Toolbox is required.';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    if isempty(ver('statistics'))
    	msg = 'Statistics Toolbox is not installed.';
    	GERT_ShowError(fnc_name,msg,1);
    end
end

if isempty(GERT_matlv)
	msg = 'Matlab or Octave is required.';
	GERT_ShowError(fnc_name,msg,3);
end

% For new class definitions
if ~exist([fileparts(which('GContour')) filesep 'subsref.m'],'file') && ...
        (~strcmp(GERT_matlv{1},'Matlab')||GERT_matlv{2}<7||(GERT_matlv{2}==7&&GERT_matlv{3}<5))
    msg = 'Matlab version 2007b or higher is required. Download the alternate GERT version for Octave and older Matlab versions.';
    GERT_ShowError(fnc_name,msg,3);
end

%% Everything was ok
disp('Your Matlab installation is OK!');

%% All done
