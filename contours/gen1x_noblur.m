function IMG = gen1x_noblur(fname,target_dist)
%clear variables;
%clear GERT_glob_el_ids GERT_glob_el_patches;
%clear globals pec_params peb_params el_params
%typen=1;
%fils=dir(['shapes/' type]);

% +2 because "." and ".." appear first
%fname=['shapes/' type '/' fils(n_image+2).name];

C = GERT_GenerateContour_FileSVG(fname);
C = compute_cdist(C);
C = compute_lt(C);
C = GERT_Transform_Center(C,[250 250],'Centroid');
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
IMG=mean(IMG,3);
end