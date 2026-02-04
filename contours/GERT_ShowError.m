function GERT_ShowError(fnc, msg, lvl, E)

% GERT_ShowError(fnc, msg, lvl, E)
%
% DESCRIPTION:
%  Handles the different types of errors thrown by other functions.
%
% ARGUMENTS: 
%  fnc ------------------ required
%                              1xN char
%
%  msg ----------------------- required
%                              1xM char
%
%  lvl ----------------------- required
%                              1x1 double  
%                              1,2,3,4
% 
%  E ------------------------- optional
%                              1x1 MException
%  
% DETAILS:
%  Level 1 is a command window warning, level 2 a pop-up dialog without
%  halting, level 3 a pop-up dialog with halting, and level 4 an
%  interpretation of a thrown exception. An MException object then needs to
%  be passed.
%  Warning messages can be suppressed for each GERT function separately.
%  E.g., warning('off','GERT:GERT_RenderDisplay')
%
% EXAMPLE:
%  GERT_ShowError('GERT_Init','Could not initialize',3);
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

if ~strcmp(fnc,'GERT_CheckDependencies')
    GERT_Init;
end

%% Check the arguments
fnc_name = 'GERT_ShowError';

% At least three arguments required
if nargin < 3 || nargin > 4
    msg = 'Between three and four input arguments needed';
    GERT_ShowError(fnc_name,msg,3);
end

% 'fnc_name' - required
if ~GERT_Aux_ValidVec(fnc_name,'char')
    msg = 'Input argument ''fnc_name'' must be a 1xN character string';
    GERT_ShowError(fnc_name,msg,3);
end

% 'msg' - required
if ~GERT_Aux_ValidVec(msg,'char')
    msg = 'Input argument ''msg'' must be a 1xN character string';
    GERT_ShowError(msg,msg,3);
end

% 'lvl' - required
if ~GERT_Aux_ValidVec(lvl,'double',1) || ~ismember(lvl,1:4)
    msg = 'Input argument ''lvl'' must be a 1x1 double equal to 1,2,3 or 4';
    GERT_ShowError(msg,msg,3);
end

% 'E' - optional
if exist('E','var')
    if ~GERT_Aux_ValidVec(E,'MException',1)
        msg = 'Input argument ''E'' must be a 1x1 MException';
        GERT_ShowError(msg,msg,3);
    end
elseif lvl == 4
    msg = 'Level 4 errors require input argument ''E''';
    GERT_ShowError(msg,msg,3);
end

global GERT_matlv;
global GERT_log;
GERT_log = group(GERT_log,'on');

%% Do the checking
if lvl == 1
    % LEVEL 1 ERROR: Command text without halting
    full_msg = char(strcat(fnc,{': '},msg));
    warning(strcat('GERT:',fnc), full_msg);

    GERT_log = add(GERT_log,'msg',full_msg);
    
    
elseif lvl == 2
    % LEVEL 2 ERROR: Dialog without halting
    GERT_log = add(GERT_log,'msg',char(strcat({'ERROR: '},fnc,{' : '},msg)));
    if strcmp(GERT_matlv{1},'Matlab')
        errordlg(msg,fnc);   
    else
        error(strcat('GERT:',fnc), msg);
    end
    
    
elseif lvl == 3
    % LEVEL 3 ERROR: Dialog with halting
    GERT_log = add(GERT_log,'msg',char(strcat({'ERROR: '},fnc,{' : '},msg)));
    if strcmp(GERT_matlv{1},'Matlab')
        errordlg(msg,fnc);
        error('GERT execution stopped.');
    else
        error(strcat('GERT:',fnc), msg);
    end
      
    
elseif lvl == 4
    % LEVEL 4 ERROR: Dialog and exception interpretation, with halting
    % Not compatible with Octave so not actually used at the moment... 
    
        % Memory allocation errors
    if strcmp(GERT_matlv{1},'Matlab') && strcmp(E.identifier,'MATLAB:pmaxsize')
        msg = char(strcat(msg, {' Reduce the variable size.'}));
        GERT_log = add(GERT_log,'msg',char(strcat({'ERROR : '},fnc,{' : '},msg))); 
        errordlg(msg,fnc);
        error('GERT execution stopped.');
    elseif strcmp(GERT_matlv{1},'Matlab') && strcmp(E.identifier,'MATLAB:nomem')
        msg = char(strcat(msg, {' Reduce the variable size, or free up memory.'}));
        GERT_log = add(GERT_log,'msg',char(strcat({'ERROR : '},fnc,{' : '},msg))); 
        errordlg(msg,fnc);
        error('GERT execution stopped.');
      
        % Imread
    elseif strcmp(GERT_matlv{1},'Matlab') && strcmp(E.identifier,'MATLAB:imread:fileFormat')
        msg = char(strcat(msg, {' Unknown file format.'}));
        GERT_log = add(GERT_log,'msg',char(strcat({'ERROR : '},fnc,{' : '},msg))); 
        errordlg(msg,fnc);
        error('GERT execution stopped.');
        
        % Unidentified errors
    else
        msg = char(strcat(msg,{' GERT did not automatically recognize this exact type of error. '},...
            {'Please inspect the command window error text to find the cause.'}));
        GERT_log = add(GERT_log,'msg',char(strcat({'ERROR: '},fnc,{' : '},msg))); 
        
        if strcmp(GERT_matlv{1},'Matlab')
            errordlg(msg,fnc);
            rethrow E;
        else
            error(strcat('GERT:',fnc), msg);
        end
    end
end

%% All done