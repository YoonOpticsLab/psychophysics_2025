function IMG = GERT_DrawElement_Image(params)

% IMG = GERT_DrawElement_Image(params)
%
% DESCRIPTION:
%  This function will load an image stored in file FNAME using ''imread'', 
%  either as a COLOR or a grayscale matrix. No other parameters can be
%  provided at the moment. The image must be square, and of an odd size.
%
% ARGUMENTS:
%  params -------------------- required
%      |                       1x1 struct
%      |
%      |- fname -------------- required
%      |                       1x1 cell
%      |                       containing 1xN char
%      |
%      |- scale -------------- optional, default: 1
%      |                       1x1 double
%      |                       >0
%      |
%      |- color -------------- optional, default: false
%      |                       1x1 logical, finite, real
%
% RETURNS:
%  IMG ----------------------- MxM double
%
% DETAILS:
%  The current implementation is a simple paste-job of an existing image
%  file. Rotation or scaling could in principle be implemented easily.
%  However, in many cases the image quality will suffer from the pixel
%  interpolation algoritm that will have to be applied. For instance, what
%  can be displayed perfectly as an straight line when upright, cannot be
%  rendered perfectly straight when at an angle of 45� degrees, due to the
%  pixelation of the image. Therefore rotated images can differ on more
%  properties than just rotation, making them unsuitable for scientific
%  research. When we have figured out a way around this kind of quality
%  loss, we will implement it. Suggestions are of course also welcome.
%
% EXAMPLE: 
%  % Load a color GIF as a greyscale image
%  params.fname = {'E.png'};
%  params.color = false;
%  IMG = GERT_DrawElement_Image(params);
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

%% Check the arguments
fnc_name = 'GERT_DrawElement_Image';

global GERT_elerrcheck;
if GERT_elerrcheck
    
    GERT_Init;
    
    % One argument required
    if nargin ~= 1
        msg = 'One input argument needed.';
        GERT_ShowError(fnc_name,msg,3);
    end

    % 'params' - required
    if ~isstruct(params) || ~isscalar(params)
        msg = 'Input argument ''params'' must be a 1x1 struct.';
        GERT_ShowError(fnc_name,msg,3);
    end

    % Parse 'params'
    p = GStructParser;
    p = addfield(p,'fname', 'req', @(x) ...
        isscalar(x) && iscell(x));
    p = addfield(p,'color', false, @(x) ...
        isscalar(x) && islogical(x));
    p = addfield(p,'scale', 1, @(x) ...
        GERT_Aux_ValidVec(x,'double',1) && x>0);
    
    p = parse(p,params);

    fname = p.results.fname;
    color = p.results.color;
    scale = p.results.scale;

    if iscell(fname) && ~GERT_Aux_ValidVec(fname{1},'char')
        msg = '''params.fname'' must contain a 1xN char array';
        GERT_ShowError(fnc_name,msg,3);
    elseif iscell(fname)
        fname = fname{1};
    end

    if ~exist(fname,'file')
       msg = 'File was not found.';
       GERT_ShowError(fnc_name,msg,3);
    end
    
else
    
   if isfield(params,'fname'),fname = params.fname{1};else fname = '';end
   if isfield(params,'color'),color= params.color;else color = false;end
   if isfield(params,'scale'),scale= params.scale;else scale = 1;end
    
end

%% Load the file
global GERT_matlv;
if strcmp(GERT_matlv{1},'Octave')
    IMAGE_PATH(['.' pathsep fileparts(which(fname))]);
end

try
   [IMG, map] = imread(fname);
catch
   msg = 'Error reading image file. ';
   GERT_ShowError(fnc_name,msg,3);
end

if scale ~=1
    IMG = imresize(IMG,[size(IMG,1)*scale size(IMG,2)*scale]);
end

if ~isempty(map)
    IMG = double(ind2rgb(IMG,map));
else
    IMG = double(IMG) / 255;
end

if size(IMG,1) ~= size(IMG,2) || ~mod(size(IMG,1),2)
   msg = 'Bitmap image must be square and have an odd size. Cropped.';
   GERT_ShowError(fnc_name,msg,1); 
   sh = min([size(IMG,1) size(IMG,2)]);
   sh = sh - ~mod(sh,2);
   IMG = IMG(1:sh,1:sh,:);
end

%% Process further
if color && size(IMG,3) == 1
   IMG = repmat(IMG,[1 1 3]);
elseif ~color && size(IMG,3) == 3
   IMG = mean(IMG,3);
end

for layer = 1:size(IMG,3)
    l = IMG(:,:,layer);
    l(1:end,:) = l(end:-1:1,:);
    l = l';
    IMG(:,:,layer) = l;
end

%% All done
