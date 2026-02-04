% GERT class: GElements
%
% DESCRIPTION:
%  This class holds information on individual element X and Y positions, the 
%  dimensions DIMS of the display inside which these elements are placed, and
%  their status TAGS. E.g., 'c1' for the first contour. In addition it
%  implements methods to VALIDATE the object, PLOT its contents, and
%  request or change the tags through SETTAG and GETTAG.
%
% CONSTRUCTORS:
%  Empty:
%    ------------------------- No requirements
%
%  Using a subset of an existing GElements object:
%    els --------------------- required
%                              1x1 GElements
%
%    idx --------------------- required
%                              1xN double
%                              >0, integer value, finite, real
%                                  
%  Using an existing GContour object:
%    contour ----------------- required
%                              1x1 GContour
%
%    dims -------------------- optional, default: []
%                              1x4 double
%                              dims(2)>dims(1) dims(4)>dims(3), finite, real
%
%  Using existing coordinate vectors:
%    coordinates ------------- required
%                              2xN double
%                              finite, real
%
%    dims -------------------- optional, default, []
%                              1x4 double
%                              finite, real
%
% PROPERTIES:
%  x ------------------------- 1xN double
%  y ------------------------- 1xN double
%  n ------------------------- 1x1 double
%  dims ---------------------- 1x4 double, dims(1)<dims(2),dims(3)<dims(4)
%  tags ---------------------- 1x2 cell (set access through settag)
%
% METHODS:
%  validate ------------------ Validate the object
%  plot ---------------------- Plot the contents of the object
%  settag(tag,idx) ----------- Set this 1xN char tag for a 1xN vector of indices
%                              The first char should be a lowercase letter,
%                              the next chars should form an integer value
%  idx = gettag(tag) --------- Fetch the indices corresponding to this 1xN char tag
%  rmid ---------------------- Remove identical points
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

classdef GElements
    
    %% Properties
    properties
        x = [];
        y = [];
        dims = [];
    end
    
    properties (SetAccess = 'protected', Hidden = true)
        tags = cell(1,2);
        validated = false;
    end
    
    properties (SetAccess = 'protected')
        n = 0;
    end
    
    %% Methods
    methods
        
        % Constructor
        function obj=GElements(one,two)
            
            fnc_name = 'GElements.constructor';
            
            if nargin ~= 0
                if isa(one, 'GContour')
                    
                    if ~isscalar(one)
                        msg = 'Only scalar GContour objects are accepted for the GElements constructor';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    validate(one);
                    obj.x = one.x;
                    obj.y = one.y;
                    settag(obj,'c',1:one.n);
                    
                    if nargin>1 
                        if ~GERT_Aux_ValidVec(two,'double',4)
                        msg = 'Second GElements constructor argument must be a real-valued, finite 1x4 double vector';
                        GERT_ShowError(fnc_name,msg,3);
                        else
                            obj.dims = two;
                        end
                    end
                    
                elseif isa(one,'GElements')
                    
                    if ~isscalar(one)
                        msg = 'Only scalar GElements objects are accepted for the GElements constructor';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    if nargin < 2
                        msg = 'Second input argument needed if the first is a GElements object';
                        GERT_ShowError(fnc_name,msg,3); 
                    end
                    
                    if ~GERT_Aux_ValidVec(two,'double') || any(mod(two,1)) || any(two<1)
                        msg = 'Second GElements constructor argument must be a positive, integer-value 1xN double vector';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    if any(two>one.n)
                        msg = 'Indices in the second argument exceed the number of elements in the first';
                        GERT_ShowError(fnc_name,msg,3);   
                    end
                    
                    validate(one);
                    obj.x = one.x(two);
                    obj.y = one.y(two);
                    obj.dims = one.dims;
                    
                    if ~isempty(one.tags{1})
                        idx = two(two<=length(one.tags{1}));
                        obj.tags{1} = one.tags{1}(idx);
                        obj.tags{2} = one.tags{2}(idx);
                    end
                    
                elseif isa(one,'double')
                    
                    if size(one,1) ~= 2 || size(one,2) < 1 || ndims(one)~= 2 || ...
                            any(~isfinite(one(:))) || any(imag(one(:)))
                        msg = 'Only 2xN double matrices are accepted for the GElements constructor';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    obj.x = one(1,:);
                    obj.y = one(2,:);
                    settag(obj,'o',1:obj.n);
                    
                    if nargin>1 
                        if ~GERT_Aux_ValidVec(two,'double',4)
                        msg = 'Second GElements constructor argument must be a real-valued, finite 1x4 double vector';
                        GERT_ShowError(fnc_name,msg,3);
                        else
                            obj.dims = two;
                        end
                    end
                    
                else
                    
                    msg = 'First constructor argument for GElements must be GContour, GElements or double.';
                    GERT_ShowError(fnc_name,msg,3);
                    
                end
            end
            
            if nargin > 2
                msg = '0,1 or 2 constructor arguments are needed for the GElements constructor';
                GERT_ShowError(fnc_name,msg,3);        
            end
            
            obj = validate(obj);
            GERT_Init;
        end
        
        % Set
        function obj = set.x(obj,x)
            fnc_name = 'GElements.set.x';
            
            if ~isempty(x) && ~GERT_Aux_ValidVec(x,'double')
                msg = 'GElements.x must be a real-valued, finite 1xN double vector';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.x = x;
            obj.n = length(obj.x);
            obj.validated = false;
        end
        
        function obj = set.y(obj,y)
            fnc_name = 'GElements.set.y';
            
            if ~isempty(y) && ~GERT_Aux_ValidVec(y,'double')
                msg = 'GElements.y must be a real-valued, finite 1xN double vector';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.y = y;
            obj.validated = false;
        end
        
        function obj = set.n(obj,n)
            fnc_name = 'GElements.set.n';
            
            if ~GERT_Aux_ValidVec(n,'double',1)
                msg = 'GElements.n must be an positive integer value scalar double.';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.n = n;
            obj.validated = false;
        end
        
        function obj = set.dims(obj,dims)
            fnc_name = 'GElements.set.dims';
            
            if ~isempty(dims) && ~GERT_Aux_ValidVec(dims,'double',4)
                msg = 'GElements.dims must be a real-valued, finite 1x4 double vector';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            if ~isempty(dims) && (dims(1) >= dims (2) || dims(3) >= dims(4))
                msg = 'Effective display size is 0 or negative.';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.dims = dims;
            obj.validated = false;
        end
        
        function n = get.n(obj)
            fnc_name = 'GElements.get.n';
            
            n = length(obj.x);
        end
        
        % Custom methods
        obj=validate(obj);      % Validate the elements
        obj=rmid(obj);          % Remove identical elements
        idx=gettag(obj,tag);    % Retrieve indices to a given tag
        obj=settag(obj,tag,idx);% Set a tag for given indices
        plot(obj,idx);          % Graphical overview of the GElements object
        
    end
    
end