% GERT class: GStructParser
%
% DESCRIPTION:
%   This class allows the parsing of parameter structures in GERT. It is
%   similar to the inputParser class in Matlab 2007 and later, and is
%   mostly used internally.
%
% CONSTRUCTORS:
%  None.
%
% PROPERTIES:
%  fields -------------------- 1x3 cell
%  results ------------------- 1x1 struct
%  n ------------------------- 1x1 double (dependent on x)
%
% METHODS:
%  addfield ------------------ Add a field to parse
%  parse --------------------- Parse the listed fields
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

classdef GStructParser
    
    %% Properties
    properties (SetAccess = 'protected')
        fields = cell(1,3);
        results = struct;
        n = 0;
    end
    
    %% Methods
    methods
        obj = addfield(obj,name,defval,valfnc);
        obj = parse(obj,s);
    end
    
end