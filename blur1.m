close('all'); clear('all');

output_name='test';

%blur_levels_multiplier=[10^-0.1,10^0.1];
blur_levels_multiplier=[1.25,1.5,2.0];
blur_baseline_D=0.25;
num_repeats=4;

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
stimulus_duration = -0.50 ; % In seconds
stimulus_size_deg = 0.5;

% Screen size and background
background=[128,128,128];
fix_size=10; % size of fixation cross (in pix)
fullScreen=0;
partialRect = [0 0 1024 1024];

% Directory to randomly pull images from. All images are resized to the
% size given. (May distort if not square.)
targets_dir='face_images';
filename_mask='*.jpg';
imsize=[256,256];

show_pf=1;

% RUN
which_experiment='blur1';
run_experiment;