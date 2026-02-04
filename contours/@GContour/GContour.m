% GERT class: GContour
%
% DESCRIPTION:
%  This class holds information on individual element X and Y positions, the 
%  open or CLOSED status of the contour, and the number of contour
%  definition points N. In addition, the distances along the contour CDIST
%  can be present, as well as the local tangents LT and the total contour
%  length CLENGTH.
%
%  The methods implemented include a VALIDATE and PLOT function, and
%  generic contour specific computing functions COMPUTE_CDIST and
%  COMPUTE_LT. Often the contour generation function might already have
%  filled in the CDIST and LT values, however, using its own methods. For
%  closed contours, MAIN_AXIS and CENTROID allow the retrieval of the
%  properties to which the function names refer. Finally, RMID allows the
%  removal of identical points from the contour description.
%
% CONSTRUCTORS:
%  Empty:
%    ------------------------- No requirements
%                                  
%  Using a subset of an existing GContour object:
%    contour ----------------- required
%                              1x1 GContour
%
%    idx --------------------- required
%                              1xN double, positive integer values
%
%  Using an existing GElements object:
%    els --------------------- required
%                              1x1 GElements
%
%    closed ------------------ optional, default: false
%                              1x1 logical
%
%  Using existing coordinate vectors:
%    coordinates ------------- required
%                              2xN double
%                              finite, real
%
%    closed ------------------ optional, default, false
%                              1x1 logical
%
% PROPERTIES:
%  x ------------------------- 1xN double
%  y ------------------------- 1xN double
%  n ------------------------- 1x1 double
%  closed -------------------- 1x1 logical
%  cdist --------------------- empty, 1xN or 1xN+1 double
%  clength ------------------- empty or 1x1 double
%  lt ------------------------ empty or 1xN double
%
% METHODS:
%  tf = validate ------------- Validate the object
%  plot ---------------------- Plot the contents of the object
%  compute_cdist ------------- Compute the distances along the contour
%  compute_lt ---------------- Compute the local tangents to the contour points
%  x0,y0 = centroid ---------- Retrieve the centroid of a closed contour
%  ma,pt = main_axis --------- Retrieve the main axis of a closed contour, as well as the centroid
%  rmid ---------------------- Remove identical points from the contour description
%  h = hash ------------------ Create a unique identifier out of this object
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

classdef GContour
    
    %% Properties
    properties
        x = [];
        y = [];
        cdist = [];
        lt = [];
        closed = false;
    end
    
    properties (SetAccess = 'protected', Hidden = true)
        validated = false;
    end
    
    properties (SetAccess = 'protected')
        clength = 0;
        n = 0;
    end
    
    %% Methods
    methods
        
        % Constructor
        function obj=GContour(one,two)
            
            fnc_name = 'GContour.constructor';
            
            if nargin ~= 0
                if isa(one, 'GElements')
                    if ~isscalar(one)
                        msg = 'Only scalar GElements objects are accepted for the GContour constructor';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    validate(one);
                    obj.x = one.x;
                    obj.y = one.y;
                    
                elseif isa(one,'double')
                    if ~size(one,1) == 2 || size(one,2) < 1 || ndims(one)~= 2 || ...
                            any(~isfinite(one(:))) || any(imag(one(:)))
                        msg = 'Only real-valued, finite 2xN double matrices can be provided as a GContour constructor argument';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    obj.x = one(1,:);
                    obj.y = one(2,:);
                
                elseif isa(one,'GContour')
                    validate(one);
                    if ~isscalar(one)
                        msg = 'Invalid contour object used';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    if nargin ~= 2
                        msg = 'Index vector needed';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    if ~GERT_Aux_ValidVec(two,'double') || any(mod(two,1)) || any(two<1) || any(two>one.n)
                        msg = 'Invalid index vector';
                        GERT_ShowError(fnc_name,msg,3);
                    end
                    
                    obj.x = one.x(two);
                    obj.y = one.y(two);
                    obj.closed = one.closed;
                    
                    if ~isempty(one.lt)
                        obj.lt = one.lt(two);
                    end
                    
                    if ~isempty(one.cdist)
                        obj.cdist = one.cdist(two);
                        
                        if obj.closed
                            obj.cdist(end+1) = one.cdist(end);
                        end
                    end
                    
                else
                    msg = 'First GContour constructor argument must be a 1x1 GElements or a 2xN double.';
                    GERT_ShowError(fnc_name,msg,3);
                end
            end
            
            if nargin == 2 && ~isa(one,'GContour')
                if ~isa(two,'logical') || ~isscalar(two)
                    msg = 'Second constructor argument for GContour must be a 1x1 logical';
                    GERT_ShowError(fnc_name,msg,3);
                end
                
                obj.closed = two;
            elseif nargin == 1
                obj.closed = false;
            end
            
            if nargin > 2
                msg = '0, 1 or 2 constructor arguments needed for GContour';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj = validate(obj);
            GERT_Init;
        end
        
        % Set
        function obj = set.x(obj,x)
            fnc_name = 'GContour.set.x';
            
            if ~isempty(x) && ~GERT_Aux_ValidVec(x,'double')
                msg = 'GContour.x must be a real-valued, finite 1xN double vector';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.x = x;
            obj.n = length(obj.x);
            obj.validated = false;
        end
        
        function obj = set.y(obj,y)
            fnc_name = 'GContour.set.y';
            
            if ~isempty(y) && ~GERT_Aux_ValidVec(y,'double')
                msg = 'GContour.y must be a real-valued, finite 1xN double vector';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.y = y;
            obj.validated = false;
        end
        
        function obj = set.n(obj,n)
            fnc_name = 'GContour.set.n';
            
            if ~GERT_Aux_ValidVec(n,'double',1)
                msg = 'GContour.n must be an positive integer value scalar double.';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.n = n;
            obj.validated = false;
        end
        
        function obj = set.clength(obj,clength)
            fnc_name = 'GContour.set.clength';
            
            if ~GERT_Aux_ValidVec(clength,'double',1)
                msg = 'GContour.clength must be an positive scalar double.';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.clength = clength;
            obj.validated = false;
        end
        
        function obj = set.cdist(obj,cdist)
            fnc_name = 'GContour.set.cdist';
            
            if ~isempty(cdist) && ~GERT_Aux_ValidVec(cdist,'double')
                msg = 'GContour.cdist must be a real-valued, finite 1xN double vector';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            if any(cdist<0)
                msg = 'All values in GContour.cdist must be positive';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.cdist = cdist;
            if ~isempty(obj.cdist)
                obj.clength = obj.cdist(end);
            else
                obj.clength = 0;
            end
        end
        
        function obj = set.lt(obj,lt)
            fnc_name = 'GContour.set.lt';
            
            if ~isempty(lt) && ~GERT_Aux_ValidVec(lt,'double')
                msg = 'GContour.lt must be a real-valued, finite 1xN double vector';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.lt = lt;
        end
        
        function obj = set.closed(obj,closed)
            fnc_name = 'GContour.set.closed';
            
            if ~isempty(closed) && (~isscalar(closed) || ~islogical(closed))
                msg = 'GContour.closed must be a logical value';
                GERT_ShowError(fnc_name,msg,3);
            end
            
            obj.closed = closed;
            obj.validated = false;
        end
        
        function clength = get.clength(obj)
            fnc_name = 'GContour.get.clength';
            
            if ~isempty(obj.cdist)
                clength = obj.cdist(end);
            else
                clength = 0;
            end
        end
        
        function n = get.n(obj)
            fnc_name = 'GContour.get.n';
            
            n = length(obj.x);
        end
        
        % Custom methods
        obj=validate(obj);      % Validate the object
        obj=rmid(obj);          % Remove identical points
        obj=compute_cdist(obj); % Compute distances along contour
        obj=compute_lt(obj);    % Compute local tangents to contour
        [x0,y0]=centroid(obj);  % Compute the centroid of a closed contour
        [ma,pt]=main_axis(obj); % Compute the main axis of a closed contour
        plot(obj);              % Graphical display of the GContour object
        h=hash(obj);            % Create a hash number
        
    end
    
end