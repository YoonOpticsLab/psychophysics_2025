% GERT_Demo
%
% DESCRIPTION:
%  Generates nine demo figures and benchmarks the speed.
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

tic;
ccc; GERT_Init;
warning off;
global GERT_elerrcheck;
GERT_elerrcheck = false;

%% R
disp('***');
disp('Generating Figure 1');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

C = GERT_GenerateContour_FileSVG('R.svg',20);
C = compute_cdist(C);
C = GERT_Transform_Center(C,[250 250],'Centroid');
C = GERT_Transform_Rotate(C,pi/4);

pec_params.cont_avgdist = 17.9;
pec_params.eucl_mindist = 15;
pec_params.method = 'SerialEquidistant';
E = GERT_PlaceElements_Contour(C, pec_params);

peb_params.min_dist = 14;
peb_params.dims = [1 500 1 500];
peb_params.timeout = 99999;
Ea = GERT_PlaceElements_Background(E,[],peb_params);

c_idx = gettag(Ea,'c');
b_idx = gettag(Ea,'b');

gausel_params.sigmax = 1.5;
gausel_params.sigmay = 1.5;
gausel_params.size = 6;
gausel_params.lum_bounds(c_idx) = {[0.2 0.6 0.6; 0.8 1 0.6]'};
gausel_params.lum_bounds(b_idx) = {[0.2 0.6 0.6; 0.8 0.6 0.8]'};

img_params.bg_lum = [0.2 0.6 0.6];
img_params.global_rendering = true;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Gaussian, Ea, gausel_params, img_params);
figure; imshow(IMG);

%% Glass
disp('***');
disp('Generating Figure 2');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

peb_params.min_dist = 20;
peb_params.bg_n = 120;
peb_params.dims = [1 600 1 600];
peb_params.timeout = 99999;

Set1 = GERT_PlaceElements_Background([],[],peb_params);
Set2 = GERT_Transform_Rotate(Set1,pi/30,'Custom',[300 300]);
Ea = GERT_MergeElements({Set1 Set2});

img_params.dims = [500 500];
img_params.blend_mode = 'MaxDiff';
img_params.global_rendering = true;

el_params.size = 30;
el_params.width = 8;
el_params.lum_bounds = {[0.5 1]};
el_params.scale = 2/3;
el_params.aa = 2;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Ellipse,Ea,el_params,img_params);
figure; imshow(IMG);

%% E
disp('***');
disp('Generating Figure 3');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

C = GERT_GenerateContour_FileSVG('E.svg',20);
C = compute_cdist(C); C = compute_lt(C);
C = GERT_Transform_Center(C,[250 250],'Centroid');

pec_params.cont_avgdist = 18;
[E ors] = GERT_PlaceElements_Contour(C,pec_params);

peb_params.min_dist = 14;
peb_params.dims = [1 500 1 500];
peb_params.timeout = 99999;
Ea = GERT_PlaceElements_Background(E,[],peb_params);
c_idx = gettag(Ea,'c');
b_idx = gettag(Ea,'b');

gabel_params.size = 6;
gabel_params.or(b_idx) = GERT_Aux_RestrictResolution(2*pi*rand(1,length(b_idx)),pi/50);
gabel_params.or(c_idx) = ors;
gabel_params.lum_bounds(c_idx) = {[0.5 0 0; 0.5 0.5 0.5; 1 0.5 0.5]'};
gabel_params.lum_bounds(b_idx) = {[0 0 0; 0.5 0.5 0.5; 1 1 1]'};

img_params.bg_lum = [0.5 0.5 0.5];
img_params.global_rendering = true;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Gabor, Ea, gabel_params, img_params);
figure; imshow(IMG);

%% Lattice
disp('***');
disp('Generating Figure 4');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

X = linspace(1,1000,50); Y = linspace(1,1000,45);
[XX YY] = meshgrid(X,Y);
X = reshape(XX,[1 numel(XX)]);
Y = reshape(YY,[1 numel(YY)]);

E = GElements([X;Y],[1 1000 1 1000]);
E = GERT_Transform_Rotate(E,pi/5);

gce_params.hax = 300;
gce_params.vax = 300;
circle = GERT_GenerateContour_Ellipse(gce_params);
circle = GERT_Transform_Shift(circle,[500 500]);
in_idx = GERT_Aux_InContour(E, circle);
E = GElements(E,in_idx);

el_params.sigmax = 1.2;
el_params.sigmay = 1.2;
el_params.size = 5;
el_params.lum_bounds = {[1 0]};
el_params.scale = 0.5;

img_params.bg_lum = 1;
img_params.global_rendering = true;
img_params.dims = [500 500];
IMG = GERT_RenderDisplay(@GERT_DrawElement_Gaussian,E,el_params,img_params);
figure; imshow(IMG);

%% G
disp('***');
disp('Generating Figure 5');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

C = GERT_GenerateContour_FileSVG('G.svg',20);
C.closed = true;
C = GERT_Transform_Center(C,[250 250],'Centroid');

peb_params.min_dist = 4;
peb_params.dims = [1 500 1 500];
peb_params.timeout = 99999;
Ea = GERT_PlaceElements_Background([],[],peb_params);
in = GERT_Aux_InContour(Ea,C);

rect_params.width = 1;
rect_params.height = 6;
rect_params.size = 20;
rect_params.or = GERT_Aux_RestrictResolution(rand([1 Ea.n])*pi/4 + pi,pi/10);
rect_params.or(in) = GERT_Aux_RestrictResolution(rand([1 length(in)])*pi/4 + pi/2,pi/10);
rect_params.lum_bounds = {[1 0]};
rect_params.aa = 4;

img_params.bg_lum = 1;
img_params.blend_mode = 'MaxDiff';
img_params.global_rendering = true;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Rectangle, Ea, rect_params, img_params);
figure; imshow(IMG);

%% Color
disp('***');
disp('Generating Figure 6');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

peb_params.min_dist = 20;
peb_params.dims = [1 500 1 500];
peb_params.timeout = 99999;
Ea = GERT_PlaceElements_Background([],[],peb_params);

gabel_params.sigma = 1 + rand(1,Ea.n)*1.5;                                                          
gabel_params.freq = 0.05 + (rand(1,Ea.n)*0.25); 
gabel_params.phase = rand(1,Ea.n)*pi;
gabel_params.scale = 1.5;
gabel_params.or = rand(1,Ea.n)*pi;

for i = 1:Ea.n
    gabel_params.lum_bounds(i) = {[rand(1,3);[0.5 0.5 0.5]; rand(1,3)]'};
end

img_params.bg_lum = [0.5 0.5 0.5];

IMG = GERT_RenderDisplay(@GERT_DrawElement_Gabor, Ea, gabel_params, img_params);
figure; imshow(IMG);

%% Eagle
disp('***');
disp('Generating Figure 7');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

C = GERT_GenerateContour_FileTXT('eagle.txt',true,' ');
C = GERT_Transform_Flip(C,0,'Centroid');
C = GERT_Transform_Center(C, [0 0], 'Centroid');

pec_params.method = 'SerialEquidistant';
pec_params.cont_avgdist = 25;
pec_params.eucl_mindist = 20;
pec_params.cont_startpos = 0.25;
[E ors] = GERT_PlaceElements_Contour(C,pec_params);
E.dims = [-250 250 -250 250];

peb_params.min_dist = 20;
peb_params.timeout = 99999;
Ea = GERT_PlaceElements_Background(E,[],peb_params);

[in_idx, out_idx, on_idx] = GERT_Aux_InContour(Ea, E);

el_params.width = 10;
el_params.height = 17;
el_params.scale = 0.5;
el_params.size = 10;
el_params.aa = 4;
el_params.or(in_idx) = repmat(main_axis(C),[1 numel(in_idx)]);
el_params.or(on_idx) = ors;
el_params.or(out_idx) = GERT_Aux_RestrictResolution(2*pi*rand([1 numel(out_idx)]),pi/50);
el_params.lum_bounds(in_idx) = {[0.4 0; 0.25 0; 0.15 0.6]};
el_params.lum_bounds(on_idx) = {[0.4 .95; 0.25 0; 0.15 0]};
el_params.lum_bounds(out_idx) = {[0.4 .95; 0.25 .95; 0.15 .95]};

img_params.bg_lum = [0.4 0.25 0.15];
img_params.dims = [500 500];
img_params.global_rendering = true;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Triangle,Ea,el_params,img_params);
figure; imshow(IMG);

%% MonaLisa
disp('***');
disp('Generating Figure 8');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

global GERT_matlv;

if strcmp(GERT_matlv{1},'Octave')
    IMAGE_PATH(['.' pathsep fileparts(which('MonaLisa.jpg'))]);
end
im = imread('MonaLisa.jpg');

im = im';
im(:,1:end) = im(:,end:-1:1);
dims = size(im);

peb_params.min_dist = 6;
peb_params.dims = [1 dims(1) 1 dims(2)];
peb_params.timeout = 99999;
E = GERT_PlaceElements_Background([],[],peb_params);

el_params.or = pi/2;
el_params.sigma = 3;
el_params.freq = 0.09;
el_params.size = 12;
el_params.scale = 0.5;
el_params.aa = 2;
lind = sub2ind(dims,round(E.x),round(E.y));
lums = double(im(lind))/255;
el_params.phase = GERT_Aux_RestrictResolution(pi-(lums*pi),pi/20);

img_params.blend_mode = 'MaxDiff';
img_params.global_rendering = true;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Gabor,E,el_params,img_params);
figure; imshow(IMG);

%% T
disp('***');
disp('Generating Figure 9');
clear variables;
clear global GERT_glob_el_ids GERT_glob_el_patches;

C = GERT_GenerateContour_FileSVG('T.svg',20);
C = GERT_Transform_Center(C,[250 250],'Centroid');

pec_params.cont_avgdist = 20;
E = GERT_PlaceElements_Contour(C,pec_params);

peb_params.min_dist = 18;
peb_params.dims = [1 500 1 500];
peb_params.timeout = 99999;
Ea = GERT_PlaceElements_Background(E,[],peb_params);

[in_idx, out_idx, on_idx] = GERT_Aux_InContour(Ea, E);

el_params.fname = cell(1,Ea.n);
el_params.fname(out_idx) = {'R.png'};
el_params.fname(in_idx) = {'G.png'};
el_params.fname(on_idx) = {'E.png'};
el_params.color = true;

img_params.bg_lum = [1 1 1];
img_params.blend_mode = 'MaxDiff';
img_params.global_rendering = true;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Image,Ea,el_params,img_params);
figure; imshow(IMG);
toc;