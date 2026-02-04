function IMG = gen1x_second(C,target_dist)
pec_params.cont_avgdist = 18*target_dist;
[E ors] = GERT_PlaceElements_Contour(C,pec_params);
peb_params.min_dist = 14*1.9;
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

IMG=blurred;
%figure();
%imagesc(blurred,[0 1.0]); colormap('bone');
%axis('off');
end