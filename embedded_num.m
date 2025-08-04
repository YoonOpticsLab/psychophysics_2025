output_name='test';

stimulus_duration = 0.300 ; % In seconds
draw_mask=0; % whether to draw a phase-scrambled post-mask

% Screen size and background
background=[128,128,128];
fix_size=10; % size of fixation cross (in pix)
fullScreen=0;
partialRect = [0 0 1024 1024];

% Sigma blur levels (in pixels) of the Gaussian blur 
% TODO: convert to visual angle based on distance, etc.
randstr_lengths=[5 8];

% RUN
which_experiment='embedded_num';
run_experiment;