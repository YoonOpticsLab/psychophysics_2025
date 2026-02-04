%disp('***');
%disp('Generating Figure 3');
%clear variables;
%clear global GERT_glob_el_ids GERT_glob_el_patches;
%close all;
%clear all;

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

%type='fruit';
%for n_image=1:4
function C = gen1x_first(fname,target_dist)
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

end