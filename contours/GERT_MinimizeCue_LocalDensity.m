function opt_p = GERT_MinimizeCue_LocalDensity(fnc1, args1, args2, cld_params, optfield)

% opt_p = GERT_MinimizeCue_LocalDensity(fnc1, args1, args2, cld_params, optfield)
%
% DESCRIPTION:
%  This function will minimize the local density cue in the display. FNC1
%  specifies the function call string for the placement of foreground
%  elements, as well as its arguments vector in ARGS1. Background elements
%  are then placed around these points using GERT_PlaceElements_Background,
%  according to the ARGS2 specified. OPTFIELD specifies whether the
%  parameter to be manipulated pertains to the first or the second element
%  placement function, as well as the name of the parameter and the range
%  to be tested. CLD_PARAMS contains the parameters into the
%  GERT_CheckCue_LocalDensity function.
%  Optionally, a GElements object might be passed as FNC1, leaving the
%  ARGS1 argument empty. A fixed set of foreground elements will then be
%  used, and the user is required to manipulate an ARGS2 parameter instead.
%
% ARGUMENTS:
%  fnc1 ---------------------- required
%                              1xN char OR 1xN GElements/GContour/cell
%
%  args1 --------------------- optional, pass [] to skip
%      |                       1xM cell
%      |                     
%      types must match parameter types required by FNC1
%
%  args2 --------------------- required
%      |                       1x3 cell
%      |                     
%      types must match parameter types required by GERT_PlaceElements_Background
%
%  cld_params ---------------- required
%                              1x1 struct
%                              (see GERT_CheckCue_LocalDensity)
%
%  optfield ------------------ required
%      |                       1x3 cell
%      |                     
%      |- {1} ---------------- 1x1 double (1 or 2)
%      |                     
%      |- {2} ---------------- 1xN char, contains argument name
%      |                     
%      |- {3} ---------------- MxN, type must match argument
%
% RETURNS:
%  opt_p --------------------- 1x1 double
%
% DETAILS:  
%  The parameter names in FNC1 do not necessarily have to match the
%  variables names in the ARGS1 cells. However, if the optimized parameter
%  belongs to the first function, at least one argument name in FNC1 must
%  be named 'params', and this must in ARGS1 be struct containing the 
%  parameter as a field. 
%
% EXAMPLE:
% (1) fnc1 = 'GERT_PlaceElements_Contour(contour,params)'
%    args1 = [{contour},{params}]
%    args2 =  [{[]},{peb_params}]
%    optfield = [{1},{'cont_avgdist'},{1:50}];
%    ansf = GERT_MinimizeCue_LocalDensity(fnc1,args1,args2,cld_params,optfield);
%
% (2) elements = GERT_PlaceElements_Contour(contour,pec_params);
%    optfield = [{2},{'min_dist'},{10:20}];
%    ansf = GERT_MinimizeCue_LocalDensity(fnc1,args1,args2,cld_params,optfield);
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

%% Check the arguments
fnc_name = 'GERT_MinimizeCue_LocalDensity';

% Five arguments required
if nargin ~= 5
    msg = 'Five input arguments needed.';
    GERT_ShowError(fnc_name,msg,3);
end

% 'fnc1' - required
if isa(fnc1,'GElements') || isa(fnc1,'GContour') || isa(fnc1,'cell')
    
    if ~GERT_Aux_ValidVec(fnc1)
        msg = 'If fnc1 is a GElements/GContour/cell, it must be a 1xN vector';
        GERT_ShowError(fnc_name,msg,3);
    end
    
elseif isa(fnc1,'char')
    if ~GERT_Aux_ValidVec(fnc1)
        msg = 'If fnc1 is a char, it must be 1xN';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    pars = regexp(fnc1, '[()]');
    fnc1_p = fnc1(pars(1)+1:pars(2)-1);
    split = [regexp(fnc1_p, '\,') length(fnc1_p)+1];
    prev = 0;
    for i = 1:length(split)
        fnc1_args{i} = fnc1_p(prev+1:split(i)-1);
        prev = split;
    end
    
    if exist(fnc1(1:pars(1)-1),'file') < 2
    	msg = 'fnc1 does not exist in the Matlab path.';
        GERT_ShowError(fnc_name,msg,3);    
    end
    
else
	msg = 'fnc1 must be a 1xN GElements, GContour or Cell or a 1xN char.';
	GERT_ShowError(fnc_name,msg,3);
end
    
% args1 - optional, pass [] to skip
if ~isempty(args1) && ~GERT_Aux_ValidVec(args1,'cell')
	msg = 'args1 must be a 1xM cell.';
	GERT_ShowError(fnc_name,msg,3);
end

if isa(fnc1,'char') && length(args1) ~= length(fnc1_args)
	msg = 'Number of parameters in FNC1 does not match the number of parameters in ARGS1.';
	GERT_ShowError(fnc_name,msg,3);
end

% args2 - required, pass [] to skip
if ~isempty(args2) && ~GERT_Aux_ValidVec(args2,'cell',2)
	msg = 'args2 must be a 1x2 cell.';
	GERT_ShowError(fnc_name,msg,3);
end

% optfield - required
if ~GERT_Aux_ValidVec(optfield,'cell',3);
	msg = 'optfield must be a 1x3 cell.';
	GERT_ShowError(fnc_name,msg,3);
end

if optfield{1} ~= 1 && optfield{1} ~= 2
	msg = 'optfield{1} must be 1 or 2.';
	GERT_ShowError(fnc_name,msg,3);
end

if ~isempty(optfield{2}) && ~GERT_Aux_ValidVec(optfield{2},'char')
    msg = 'optfield{2} must be a 1xN char.';
	GERT_ShowError(fnc_name,msg,3);
end

if ndims(optfield{3}) > 2 || size(optfield{3},1) < 1 || size(optfield{3},2) < 1
    msg = 'optfield{3} must be a MxN vector.';
	GERT_ShowError(fnc_name,msg,3);
end

whichfnc = optfield{1};
whichfield = optfield{2};
whichvals = optfield{3};

if (isa(fnc1,'GElements') ||  isa(fnc1,'GContour') || isa(fnc1,'cell')) && whichfnc == 1
    msg = 'Cannot manipulate a fixed set of elements.';
	GERT_ShowError(fnc_name,msg,3);   
end

% cld_params - required
if ~isstruct (cld_params) || ~isscalar(cld_params)
     msg = 'cld_params must be a 1x1 struct.';
	GERT_ShowError(fnc_name,msg,3);
end

%% Instantiate fnc1 arguments
if isa(fnc1,'char')
    for i = 1:length(fnc1_args)
       eval(strcat(fnc1_args{i},'=args1{i};'));
    end
end

if whichfnc == 1 && ~exist('params','var')
	msg = 'fnc1 does not have the required ''params'' parameter';
	GERT_ShowError(fnc_name,msg,3); 
end

%% Check args2
regions = args2{1};
params2 = args2{2};

if ~isempty(regions) && ~GERT_Aux_ValidVec(regions,'GContour')
    msg = 'regions must be empty or a 1xN GContour vector.';
	GERT_ShowError(fnc_name,msg,3);
end

if (~isstruct (params2) || ~isscalar(params2)) && ~isempty(params2)
     msg = 'args2{2} must be a 1x1 struct or empty';
	GERT_ShowError(fnc_name,msg,3);
end

%% If whichvals is 2D, check which value is being changed
chrow = [];
for i = 1:size(whichvals,1)
    if any(diff(whichvals(i,:)))
        chrow = [chrow i];
    end
end

%% Execute for each whichvals
megamat = zeros(1,size(whichvals,2));
i=0;

for v = 1:size(whichvals,2)
    whichvals(chrow,v)
    
    i=i+1;
    
    if whichfnc == 1
        params.(whichfield) = whichvals(:,i)';
    elseif whichfnc == 2
        params2.(whichfield) = whichvals(:,i)';
    end
    
    if isa(fnc1,'GElements') || isa(fnc1,'GContour') || isa(fnc1,'cell')
        els1n = 0;
        for j=1:length(fnc1)
           if isa(fnc1,'cell')
              tmp = fnc1{j}; 
           else
              tmp = fnc1(j);
           end
           
           if (~isa(tmp,'GContour') && ~isa(tmp,'GElements')) || ~isscalar(tmp)
              msg = 'fnc1 needs to consist of GContour or GElements objects';
              GERT_ShowError(fnc_name,msg,3); 
           else
              tmp = validate(tmp);
           end
           
           if isa(tmp,'GElements')
                els1n = els1n+tmp.n;
           end
        end
        els2 = GERT_PlaceElements_Background(fnc1,regions,params2);
    else
        eval(strcat('els1=',fnc1,';'));
        els1n = els1.n;
        els2 = GERT_PlaceElements_Background(els1,regions,params2);
    end

    
    idx1 = 1:els1n;
    idx2 = els1n+1:els2.n;
   
    if isempty(idx1) || isempty(idx2)
       msg = 'One of both functions did not return elements. Nothing to compare!';
       GERT_ShowError(fnc_name,msg,3); 
    end
    
    res = GERT_CheckCue_LocalDensity(els2,idx1,idx2,cld_params);
    megamat(i) = res.pm;
end

%% Model the results, determine p=0.5 value

modl_x = 1:length(megamat);

figure; hold on; 
plot(modl_x,megamat,'rx');

if ~isempty(ver('stats'))
    B = glmfit(modl_x',megamat', 'binomial', 'link', 'logit');
    fh = @(x) 1 ./ (1 + exp(-( B(1)+(x*B(2))  )));
    fh2 = @(x) (log( (1/x) - 1) - B(1)) / B(2);
    modl_y = fh(modl_x);
    opt_p = [];
    for i = 1:size(whichvals,1)
        if fh2(0.5)<1 || fh2(0.5)>length(megamat)
           msg = 'Optimal value appears to fall outside the tested range.';
               figure; hold on; 
               plot(modl_x,megamat,'rx');
               plot(modl_x,modl_y,'k-');
               axis([modl_x(1) modl_x(end) 0 1]);
               hold off;
           GERT_ShowError(fnc_name,msg,3); 
        end
        opt_p = [opt_p interp1(modl_x,whichvals(i,:),fh2(0.5))];
    end
    
    plot(modl_x,modl_y,'k-');
    line([modl_x(1) fh2(0.5)],[0.5 0.5]);
    line([fh2(0.5) fh2(0.5)],[0 0.5]);
    axis([modl_x(1) modl_x(end) 0 1]);
    
else
    msg = 'Matlab Statistics Toolbox is not installed. No model fit was performed.';
    GERT_ShowError(fnc_name,msg,1);
    opt_p = 0;
end

hold off;

%% All done
