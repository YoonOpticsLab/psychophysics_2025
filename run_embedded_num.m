close('all'); clear('all');

output_name='num_test';
z12_baseline_um=0;

blur_levels_D=[0.5,1.045];
% pupil_mm is computed below from the arcmin_per_pixel73
pupil_zernike_mm=4; % Z calculation and D->um
pupil_real_mm=4; % any additional truncation
psf_pixels=128;
visualize_psf=0;   % For debugging
psf_normalize_area=0; % Want this normalization. 2026/2/4

% Monitor & setup information
distance_cm=400;
monitor_horiz_size_cm=52.3;   % For HP VH240a in 2308D
monitor_horiz_num_pixels=1920; % For HP VH240a in 2308D
stimulus_size_deg=1.0;
one_pixel_cm=monitor_horiz_size_cm/monitor_horiz_num_pixels
arcmin_per_pixel = atan( one_pixel_cm/distance_cm ) / pi * 180 * 60

wave=0.555;
pupil_mm=wave*0.001*180/pi*60/arcmin_per_pixel; % Size of calc grid pupil size

gamma_exponent=2.2;

% Screen size & color info
background=[255,255,255];
fix_size=10; % size of fixation cross (in pix)
fullScreen=0; % if 0, use partialRect:
partialRect = [0 0 1024 1024];

% Stimulus
stimulus_duration = 0.25 ; % In seconds (negative for infinite)
text_denominator=40; % Snellen denominator
num_repeats=4;
draw_mask=0; % whether to draw a phase-scrambled post-mask

text_color = [0 0 0]; % black
%text_color = [64 64 64]; % 50 gray (TODO: gamma)
text_font='Optician Sans';
text_scaling_factor=0.48; % Multiply by this to make height match top-bottom pixels

% Layout 1: Single-row word-length, 9 letters
% Layout 2: 3 rows of 3 columns
text_layout=2;
text_spacing=1.5;

% Random string params:
randstr_lengths=[9];
use_uppercase=1; % else lower case
skip_outermost=0; % avoid the first and last letters
omit_zero=1; % ZERO ALWAYS OMITTED

show_pf=1;

% RUN
which_experiment='embedded_num';
run_experiment;