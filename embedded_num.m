output_name='num_test';

stimulus_duration = 0.100 ; % In seconds
draw_mask=1; % whether to draw a phase-scrambled post-mask

% Screen size & color info
background=[128,128,128];
fix_size=10; % size of fixation cross (in pix)
fullScreen=1; % if 0, use partialRect:
%partialRect = [0 0 1024 1024];

%text_color = [0 0 0]; % black
text_color = [90 90 90]; % 50 gray (TODO: gamma)

text_sizes = [10,20,40,80]; % Size in pixels: TODO: arcmin
num_repeats=4;

% Random string params:
randstr_lengths=[5 8];
use_uppercase=1; % else lower case
skip_outermost=1; % avoid the first and last letters
omit_zero=1; % ZERO ALWAYS OMITTED

% RUN
which_experiment='embedded_num';
run_experiment;