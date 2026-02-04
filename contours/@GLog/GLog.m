% GERT class: GLog
%
% DESCRIPTION:
%  This class contains all logging information. 
%  It contains an INFO struct which summarizes basic information on the
%  computer and Matlab installation used. The FUNCTIONS property struct
%  retains all the messages and variables saved, grouped per function and
%  per call to that function. The FILES property struct saves entire
%  plain-text files, (e.g., .m or .svg).
%  The START method enables logging, and will cause many GERT functions to
%  automatically log their input and output variables. STOP disables
%  logging, and clears the contents of the GLog class. EXIST checks
%  whether logging is enabled or disabled. ADD allows the adding of either
%  a variable, a message or a file to the log. FETCH retrieves a copy of
%  the log as a struct, which can be saved to a .mat file. Finally, GROUP
%  allows the user to group several entries under a single function call
%  under the 'Functions' struct property.
%
% CONSTRUCTORS:
%  Empty:
%    ------------------------- No requirements
%
% PROPERTIES:
%  Info ---------------------- 1x1 struct
%  Functions ----------------- 1x1 struct
%  Files --------------------- 1x1 struct
%
% METHODS:
%  start --------------------- Enable logging
%  stop ---------------------- Disable logging, clear the log
%  add(type,val,name) -------- Add an entry
%
%       - type 'msg':  val is a 1xN char containing the message
%                      name is ignored
%       - type 'var':  val is the variable to be stored
%                      name is a 1xN char containing the name under which to store it
%       - type 'file': val is the 1xN char path to the file
%                      name is a 1xN char containing the name under which to store it
%
%  group(s) ------------------ Group the following entries
%       - s == 'on': Group the following items with the previous one
%       - s == 'off': Treat the following items as separate function calls
%
%  l = fetch ------------------ Fetch the contents of the log as a struct
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

classdef GLog

    %% Properties
    properties (SetAccess = 'protected')
        Info = [];
        Functions = [];
        Files = [];
    end
    
    properties (SetAccess = 'protected', Hidden = true)   
        Exist = false;
        Group = [];
    end

    %% Methods
    methods
        
        obj=start(obj);                              % Start logging
        obj=stop(obj);                               % Stop logging, clear vars
        obj=add(obj,entry_type,entry_val,entry_name);% Add an entry
        obj=group(obj,s);                            % Enable/disable grouping of entries
        l=fetch(obj);                                % Fetch a log object   
        
    end

end