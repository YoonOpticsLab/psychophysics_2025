%disp('***');
%disp('Generating Figure 3');
%clear variables;
%clear global GERT_glob_el_ids GERT_glob_el_patches;
%close all;
clear all;

%C = GERT_GenerateContour_FileSVG('G.svg',20);
%C = GERT_GenerateContour_FileSVG('drc/circle-2-bloat.svg');
%fname='./shapes/animals/Untitled-2-03.svg';
%fname='./shapes/car/10.svg';
%fname='drc/strawb.svg';
%fname='./shapes/veg/Design-107.svg';
%fname='./shapes/fruit/35.svg';
%fname='./shapes/apple2.svg';
%fname='./drc/gimp_horse3.svg';
%fname='./shapes/fruit/pear.svg';
% fname='./shapes/car/scissors.svg';

type='fruit';
for n_image=1:4

%clear variables;
clear GERT_glob_el_ids GERT_glob_el_patches;
clear globals pec_params peb_params el_params
%typen=1;
fils=dir(['shapes/' type]);

% +2 because "." and ".." appear first
fname=['shapes/' type '/' fils(n_image+2).name];

C = GERT_GenerateContour_FileSVG(fname);
C = compute_cdist(C);
C = compute_lt(C);
C = GERT_Transform_Center(C,[250 250],'Centroid');
pec_params.cont_avgdist = 18*1.6;
[E ors] = GERT_PlaceElements_Contour(C,pec_params);
peb_params.min_dist = 14*1.89;
peb_params.dims = [1 560 1 560];
peb_params.timeout = 99999;
Ea = GERT_PlaceElements_Background(E,[],peb_params);
c_idx = gettag(Ea,'c');
b_idx = gettag(Ea,'b');

gabel_params.size = 6;
gabel_params.or(b_idx) = GERT_Aux_RestrictResolution(2*pi*rand(1,length(b_idx)),pi/50);

gabel_params.or(c_idx) = ors + 3.14/10.0 * (rand(1,length(c_idx))-0.5) ;
%gabel_params.lum_bounds(c_idx) = {[0.5 0 0; 0.5 0.5 0.5; 1 0.5 0.5]'};
gabel_params.lum_bounds(c_idx) = {[0 0 0; 0.5 0.5 0.5; 1 1 1]'};
gabel_params.lum_bounds(b_idx) = {[0 0 0; 0.5 0.5 0.5; 1 1 1]'};

Ea.x(c_idx) = Ea.x(c_idx) + 12*(rand(1,length(c_idx))-0.5);

img_params.bg_lum = [0.5 0.5 0.5];
img_params.global_rendering = true;

IMG = GERT_RenderDisplay(@GERT_DrawElement_Gabor, Ea, gabel_params, img_params);
%figure; imshow(IMG);

img_bw=mean(IMG,3);
%%
blur_multiplier=1.0;
blur_baseline_D=1.2;
pupil_mm=6;
psf_pixels=128;
arcmin_per_pixel=1;
pupil_real_mm=6;
visualize_psf=0;
gamma_exponent=1;
z12=0.99;

Z_blur_um = blur_multiplier*blur_baseline_D / 2 / sqrt(6) * (pupil_mm/2)^2;
psf=defocus_psf(psf_pixels,Z_blur_um,z12,arcmin_per_pixel,pupil_mm,pupil_real_mm,visualize_psf);
blurred = conv2(img_bw,psf,'same');
blurred = blurred - min(min(blurred));
blurred = blurred / max(max(blurred));
blurred = blurred .^ (1/gamma_exponent);

figure();
imagesc(blurred,[0 1.0]); colormap('bone');
axis('off');

end