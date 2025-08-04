output_name='test';

stimulus_duration = 0.300 ; % In seconds
draw_mask=0; % whether to draw a phase-scrambled post-mask

% Screen size and background
background=[128,128,128];
fix_size=10; % size of fixation cross (in pix)
fullScreen=0;
partialRect = [0 0 1024 1024];

% Sigma blur levels (in pixels) of the Gaussian blur (imgaussfilt)
% TODO: convert to visual angle based on distance, etc.
sigmas=[1, 2, 4, 8];
num_repeats=4;

% Quadrant mask based on logistic function
midpoint=0.75; % 50% point, in proportion of entire ROI (quadrant)
k=0.2;  % "steepness" of logistic mask: higher is steeper
debug_visualize_mask=0; % to show a window displaying mask

% Directory to randomly pull images from. All images are resized to the
% size given. (May distort if not square.)
targets_dir='face_images/';
imsize=[256,256];

% RUN
which_experiment='blur1';
run_experiment;