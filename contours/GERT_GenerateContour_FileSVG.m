function contour = GERT_GenerateContour_FileSVG(fname,res)

% contour = GERT_GenerateContour_FileSVG(fname,res)
%
% DESCRIPTION:
%  This function reads in a file FNAME containing a plain SVG file, and
%  render these vector graphics at a resolution RES. RES is equal to the
%  number of points placed on each subcurve of the path. In practice, only
%  one <path> definition should be present in the file, although this path
%  may be discontinuous. This wil result in an array of multiple GContours.
%
% ARGUMENTS:
%  fname --------------------- required
%                              1xN char
%                              Valid file in the Matlab path
%
%  res ----------------------- optional, default: 100
%                              1x1 double
%                              >0, integer value, finite, real
%
% RETURNS:
%  contour ------------------- 1xN GContour
%
% DETAILS:
%  Supported path commands: MmHhVvLlCcSsQqTtAaZz. Transform commands 
%  (translation, rotation, skewing...) will be ignored. The recommended 
%  program for creating these files is the free Inkscape; you may save the
%  file either as an Inkscape SVG or a plain SVG.
%
%
% EXAMPLE: 
%  contour = GERT_GenerateContour_FileSVG('R.svg');
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

GERT_Init;

%% Check arguments
fnc_name = 'GERT_GenerateContour_FileSVG';

% One or two arguments required
if nargin < 1 || nargin > 2
    msg = 'One or two input arguments required';
    GERT_ShowError(fnc_name,msg,3);
end

% fname - required
if ~GERT_Aux_ValidVec(fname,'char')
    msg = 'Argument ''fname'' must be a 1xN char vector';
    GERT_ShowError(fnc_name,msg,3);
end

if ~exist(fname,'file')
    msg = 'File was not found';
    GERT_ShowError(fnc_name,msg,3);
end

% 'closed' - optional
if ~exist('res','var')
    res = 100;
end

if ~GERT_Aux_ValidVec(res,'double',1) || mod(res,1)~= 0 || res < 1
     msg = 'Input argument ''res'' must be an integer value 1x1 double greater than 0';
     GERT_ShowError(fnc_name,msg,3);
end

%% Log the input
global GERT_matlv;
global GERT_log;
GERT_log = add(GERT_log,'msg','Entering function');
GERT_log = group(GERT_log,'on');
GERT_log = add(GERT_log,'var',fname,'IN_fname');
GERT_log = add(GERT_log,'var',res,'IN_res');
GERT_log = add(GERT_log,'file',fname,'svg');

%% Parse the <path> string
% Read the whole file
fid = fopen(fname);
fh = fread(fid,'*char')';
fclose(fid);

% Find the beginning of the <path> string
[a b1] = regexp(fh,'<path', 'match');

if ~isscalar(b1)
   msg = 'Exactly one path definition required in SVG file';
   GERT_ShowError(fnc_name,msg,3);
end

% Find the ending of the <path> string
[a b2] = regexp(fh,'/>', 'match');
b2 = b2(b2-b1>0);
[b2_sel] = min(b2-b1);
b2 = b2_sel+b1;

% Crop the string further to the useful part
fh2 = fh(b1:b2);
[a b1] = regexpi(fh2,'d="m', 'match','end');
[a b2] = regexp(fh2,'"', 'match','end');
b2 = b2(b2-b1>0);
[b2_sel] = min(b2-b1);
b2 = b2_sel+b1;

% Identify all the command locations
pathcode = fh2(b1:b2-1);
[pathcomm pathcomm_idx] = regexpi(pathcode,'[MmHhVvLlCcSsQqTtAaZz]', 'match');

%% Process commands
contour = GContour;
node_curr = zeros(1,2);
prev_prepnodes = [];

% Iterate over the commands
subpathn = 1;
for n = 1:length(pathcomm)
    
    % Retrieve the numbers behind this letter
    if n~= length(pathcomm)
        ptstr = pathcode(pathcomm_idx(n)+1:pathcomm_idx(n+1)-1);
        
        % Split according to the spaces
        a = strfind(ptstr,' ');
        pt = zeros(2,length(a)-1);
        for m = 1:length(a)-1
            % Split X and Y
            b = findstr(ptstr(a(m):a(m+1)),',');
            if(b)
                pt(1,m) = str2double(ptstr(a(m)+1:a(m)+b-2));
                pt(2,m) = str2double(ptstr(a(m)+b:a(m+1)-1));
            else
                pt(1,m) = str2double(ptstr(a(m):a(m+1)));
            end
        end
        
    else
        % Last command
        ptstr = pathcode(pathcomm_idx(n)+1:end);
        
        % Split according to the spaces
        a = strfind(ptstr,' ');
        pt = zeros(2,length(a));
        a = [a size(ptstr,2)];
        for m = 1:length(a)-1
            % Split X and Y
            b = findstr(ptstr(a(m):a(m+1)),',');
            if(b)
                pt(1,m) = str2double(ptstr(a(m)+1:a(m)+b-2));
                pt(2,m) = str2double(ptstr(a(m)+b:a(m+1)));
            else
                pt(1,m) = str2double(ptstr(a(m):a(m+1)));
            end
        end
    end
    
    % Prepare the nodes
    abscoord = isstrprop(pathcomm{n}, 'upper');
    
    if strfind('Mm',pathcomm{n})
        
        %---Move-to
        
        if abscoord || n==1
            node_curr = pt(:,1);
        else
            node_curr = node_curr + pt(:,1);
        end

        if n~=1
            if strcmp(GERT_matlv{1}, 'Octave')
                msg = 'No discontinuous SVG paths are allowed under Octave';
                GERT_ShowError(fnc_name,msg,3); 
            end
            subpathn = subpathn+1;
            contour(subpathn) = GContour;
        end
        
        start_point = node_curr;
        
        % Any further coordinates are considered to be line-to commands
        prep_nodes = zeros(2,2,size(pt,2)-1);
        for i=2:size(pt,2)
            
            if abscoord
                node_next = pt(:,i);
            else
                node_next = node_curr + pt(:,i);
            end
            
            prep_nodes(1:2,1,i-1) = node_curr;
            prep_nodes(1:2,2,i-1) = node_next;
            node_curr = node_next;
        end
        
        
    elseif strfind('HhVvLl',pathcomm{n})
        
        %---Line
        prep_nodes = zeros(2,2,size(pt,2));
        
        % Normal line
        if strfind('Ll',pathcomm{n})
            for i=1:size(pt,2)
                if abscoord
                    node_next = pt(:,i);
                else
                    node_next = node_curr + pt(:,i);
                end
                
                prep_nodes(1:2,1,i) = node_curr;
                prep_nodes(1:2,2,i) = node_next;
                node_curr = node_next;
            end
            
            % Horizontal
        elseif strfind('Hh',pathcomm{n})
            for i=1:size(pt,2)
                if abscoord
                    node_next = [pt(1,i); node_curr(2)];
                else
                    node_next = [node_curr(1)+pt(1,i); node_curr(2)];
                end
                
                prep_nodes(1:2,1,i) = node_curr;
                prep_nodes(1:2,2,i) = node_next;
                node_curr = node_next;
            end
            
            % Vertical
        elseif strfind('Vv',pathcomm{n})
            for i=1:size(pt,2)
                if abscoord
                    node_next = [node_curr(1); pt(1,i)];
                else
                    node_next = [node_curr(1); node_curr(2)+pt(1,i)];
                end
                
                prep_nodes(1:2,1,i) = node_curr;
                prep_nodes(1:2,2,i) = node_next;
                node_curr = node_next;
            end
        end
        
        
    elseif strfind('CcSsQqTt',pathcomm{n})
        
        %---Cubic or quadratic Bezier
        
        % Non-smooth cubic
        if strfind('Cc',pathcomm{n})
            step = 3;
            prep_nodes = zeros(2,4,round(size(pt,2)/step));
            for i=1:step:size(pt,2)
                if abscoord
                    node_int1 = pt(:,i);
                    node_int2 = pt(:,i+1);
                    node_next = pt(:,i+2);
                else
                    node_int1 = node_curr + pt(:,i);
                    node_int2 = node_curr + pt(:,i+1);
                    node_next = node_curr + pt(:,i+2);
                end
                
                prep_nodes(1:2,1,floor(i/step)+1) = node_curr;
                prep_nodes(1:2,2,floor(i/step)+1) = node_int1;
                prep_nodes(1:2,3,floor(i/step)+1) = node_int2;
                prep_nodes(1:2,4,floor(i/step)+1) = node_next;
                node_curr = node_next;
            end
            
            % Smooth cubic
        elseif strfind('Ss',pathcomm{n})
            step = 2;
            prep_nodes = zeros(2,4,size(pt,2)/step);
            for i=1:step:size(pt,2)
                
                if n~=1 && strfind('CcSs',pathcomm{n-1})
                    node_int1 = prev_prepnodes(:,4,end)-(prev_prepnodes(:,3,end) - prev_prepnodes(:,4,end));
                else
                    node_int1 = node_curr;
                end
                
                if abscoord
                    node_int2 = pt(:,i);
                    node_next = pt(:,i+1);
                else
                    node_int2 = node_curr + pt(:,i);
                    node_next = node_curr + pt(:,i+1);
                end
                
                prep_nodes(1:2,1,floor(i/step)+1) = node_curr;
                prep_nodes(1:2,2,floor(i/step)+1) = node_int1;
                prep_nodes(1:2,3,floor(i/step)+1) = node_int2;
                prep_nodes(1:2,4,floor(i/step)+1) = node_next;
                node_curr = node_next;
            end
            
            % Non-smooth quadratic
        elseif strfind('Qq',pathcomm{n})
            step = 2;
            prep_nodes = zeros(2,4,size(pt,2)/step);
            for i=1:step:size(pt,2)
                if abscoord
                    node_int1 = pt(:,i);
                    node_int2 = pt(:,i);
                    node_next = pt(:,i+1);
                else
                    node_int1 = node_curr + pt(:,i);
                    node_int2 = node_curr + pt(:,i);
                    node_next = node_curr + pt(:,i+1);
                end
                
                prep_nodes(1:2,1,floor(i/step)+1) = node_curr;
                prep_nodes(1:2,2,floor(i/step)+1) = node_int1;
                prep_nodes(1:2,3,floor(i/step)+1) = node_int2;
                prep_nodes(1:2,4,floor(i/step)+1) = node_next;
                node_curr = node_next;
            end
            
        elseif strfind('Tt',pathcomm{n})
            step = 1;
            prep_nodes = zeros(2,4,size(pt,2)/step);
            for i=1:step:size(pt,2)
                
                if n~=1 && strfind('QqTt',pathcomm{n-1})
                    node_int1 = prev_prepnodes(:,4,end)-(prev_prepnodes(:,3,end) - prev_prepnodes(:,4,end));
                else
                    node_int1 = node_curr;
                end
                
                node_int2 = node_int1;
                
                if abscoord
                    node_next = pt(:,i);
                else
                    node_next = node_curr + pt(:,i);
                end
                
                prep_nodes(1:2,1,floor(i/step)+1) = node_curr;
                prep_nodes(1:2,2,floor(i/step)+1) = node_int1;
                prep_nodes(1:2,3,floor(i/step)+1) = node_int2;
                prep_nodes(1:2,4,floor(i/step)+1) = node_next;
                node_curr = node_next;
            end
            
        end
        
    elseif strfind('Aa',pathcomm{n})
        
        %---Arc
        step = 4;
        prep_nodes = zeros(2,5,size(pt,2)/step);

        for i=1:step:size(pt,2)
            
            rad = pt(:,i);
            rot = pt(1,i+1);
            flags = pt(:,i+2);
            
            if abscoord
                node_next = pt(:,i+3);
            else
                node_next = node_curr + pt(:,i+3);
            end
            
            prep_nodes(1:2,1,floor(i/step)+1) = node_curr;
            prep_nodes(1:2,2,floor(i/step)+1) = rad;
            prep_nodes(1:2,3,floor(i/step)+1) = (rot/180)*pi;
            prep_nodes(1:2,4,floor(i/step)+1) = flags;
            prep_nodes(1:2,5,floor(i/step)+1) = node_next;
            node_curr = node_next;
        end
        
    elseif strfind('Zz',pathcomm{n})
        
        %---Line back to start
        prep_nodes = zeros(2,2,1);
        prep_nodes(1:2,1,1) = node_curr;
        prep_nodes(1:2,2,1) = start_point;
        node_curr = start_point;
    end
    
    prev_prepnodes = prep_nodes;

    % Pass the prepared nodes to the rendering engine
    if ~isempty(strfind('MmHhVvLlZz',pathcomm{n})) && ~isempty(prep_nodes)
        % Draw line
        new_points = GERT_Aux_DrawBezier([prep_nodes(:,1,:) prep_nodes(:,1,:)...
            prep_nodes(:,2,:) prep_nodes(:,2,:)],res); 
        contour(subpathn).x = [contour(subpathn).x new_points(1,:)];
        contour(subpathn).y = [contour(subpathn).y new_points(2,:)];
    elseif strfind('CcSsQqTt',pathcomm{n}) 
        % Draw Bezier
        new_points = GERT_Aux_DrawBezier(prep_nodes,res);
        contour(subpathn).x = [contour(subpathn).x new_points(1,:)];
        contour(subpathn).y = [contour(subpathn).y new_points(2,:)];
    elseif strfind('Aa',pathcomm{n})   
        % Draw arc
        new_points = GERT_Aux_DrawArc(prep_nodes,res);
        contour(subpathn).x = [contour(subpathn).x new_points(1,:)];
        contour(subpathn).y = [contour(subpathn).y new_points(2,:)];
    end    
end

%% We have the full contour now
for i = 1:subpathn
    % Flip
    contour(i).y = -contour(i).y;
    
    % Check whether the contour is closed
    if contour(i).x(1) == contour(i).x(end) && contour(i).y(1) == contour(i).y(end)
        contour(i).closed = true;
        contour(i).x = contour(i).x(1:end-1);
        contour(i).y = contour(i).y(1:end-1);
    elseif ~any(start_point-[contour(i).x(end); contour(i).y(end)])
        contour(i).closed = true;
    else
        contour(i).closed = false;
    end

    % Do some computations
    contour(i) = rmid(contour(i));
    contour(i) = compute_cdist(contour(i));
    contour(i) = compute_lt(contour(i));
    contour(i) = validate(contour(i));
end

%% Log the output
GERT_log = add(GERT_log,'var',contour,'OUT_contour');
GERT_log = add(GERT_log,'msg','Exiting function');
GERT_log = group(GERT_log,'off');

%% All done
