close('all'); clear('all');

output_name='num_test';

blur_levels_D=[0.1,0.25];
pupil_mm=6; % For D->Z_um,Z calculation
pupil_real_mm=6;
psf_pixels=128;
visualize_psf=0; % For debugging

% Monitor & setup information
distance_cm=300;
monitor_horiz_size_cm=61.47; % 27" LG LCD (27GL83A)
monitor_horiz_num_pixels=2560;
gamma_exponent=2.2;

% Screen size & color info
background=[255,255,255];
fix_size=10; % size of fixation cross (in pix)
fullScreen=0; % if 0, use partialRect:
partialRect = [0 0 1024 1024];

% Stimulus
stimulus_duration = -0.250 ; % In seconds (negative for infinite)
text_denominator=60; % Snellen denominator
num_repeats=4;
draw_mask=0; % whether to draw a phase-scrambled post-mask

text_color = [0 0 0]; % black
%text_color = [64 64 64]; % 50 gray (TODO: gamma)
text_font='Optician Sans';
text_scaling_factor=0.48; % Multiply by this to make height match top-bottom pixels

% Layout 1: Single-row word-length, 9 letters
% Layout 2: 3 rows of 3 columns
text_layout=2;
text_spacing=2.0;

% Random string params:
randstr_lengths=[9 9];
use_uppercase=1; % else lower case
skip_outermost=0; % avoid the first and last letters
omit_zero=1; % ZERO ALWAYS OMITTED

show_pf=1;

% RUN
which_experiment='embedded_num';
run_experiment;