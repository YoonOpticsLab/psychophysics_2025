close('all'); clear('all');

% run_riq uses a "pair file" that is pre-generated based on the desired metric 
% functions. To rebuild this,

% First run RIQ_pair.m, which reads in the .csv from GY, and determines which
% pairs to test. In line 4, the second parameter is the interpolation factor (how
% many points to interpolate between each source data point), and the third
% parameter is which metric to use from the original CSV.

% pupil_mm is computed below from the arcmin_per_pixel
pupil_zernike_mm=4; % Z calculation and D->um
pupil_real_mm=4; % any additional truncation
psf_pixels=128;
visualize_psf=0 ;   % For debugging
psf_normalize_area=1; % Want this normalization. 2026/2/4
num_repeats=2;

% Monitor & setup information
distance_cm=400;
monitor_horiz_size_cm=52.3;   % For HP VH240a in 2308D
monitor_horiz_num_pixels=1920; % For HP VH240a in 2308D
stimulus_size_deg=2.0;
one_pixel_cm=monitor_horiz_size_cm/monitor_horiz_num_pixels
arcmin_per_pixel = atan( one_pixel_cm/distance_cm ) / pi * 180 * 60

wave=0.555;
pupil_mm=wave*0.001*180/pi*60/arcmin_per_pixel; % Size of calc grid pupil size

prompt={'Subject ID:', 'Baseline defocus (D):', 'Baseline spherical (um):'};
dlg_defaults={'TEST','0','0.25'};
dlg_num_lines=1;
dlg_title='Experiment settings';
answer=inputdlg(prompt,dlg_title,dlg_num_lines,dlg_defaults);

z4_baseline_D=str2double( cell2mat(answer(2)) );
z12_baseline_um=str2double( cell2mat(answer(3)) );

% Get current datetime object
currentTime = datetime('now');

% Define a filename-safe format (YYYY-MM-DD_HH-MM-SS)
% Underscores or hyphens are generally safe and readable
formatSpec = 'yyyy-MM-dd_HH-mm';

% Convert the datetime object to a st15ring using the specified format
dateTimeStr = string(currentTime, formatSpec);

output_name=[cell2mat(answer(1)) '-z4_' num2str(z4_baseline_D) '-z12_' num2str(z12_baseline_um) '-' convertStringsToChars(dateTimeStr)];
%output_name=cell2mat(answer(2))+'-z4_'+z4_baseline_D+'-z12_'+z12_baseline_um+'-'+convertStringsToChars(dateTimeStr);

% Stimulus
stimulus_duration = 0.5; % In seconds
noise_duration = 0.5;

%blur_levels_multiplier=[10^-0.1,10^0.1];
%blur_levels_multiplier=[1.0]; % This is not really  used for Quest
load("RIQ_pairs.mat")

% THIS IS COMMENT. PUT CURSOR HERE TO AVOID PROBLEMS



% QUEST params:
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.25; % 4 choices, gamma=1/4
% We know from piloting around 1.5X is good (for 0.5D baseline):
tGuess = 0.35; % TODO: Where is the best place to start the staircase?
tGuessSd = 3.0;

% Define stimulus range (NOT log units)
tMin = (0.01);  % Minimum allowed intensity
tMax = (2.0);   % Maximum allowed intensity
grain = 0.01;   % Step size in log units
range=4; 

%-0.6 seems ~ for 1D

% Screen size and background
background_level=0.5;
fix_size=10; % size of fixation cross (in pix)
fullScreen=1;
partialRect = [0 0 1024 1024];

gamma_exponent=2.2;
background=[background_level^(1/gamma_exponent),background_level^(1/gamma_exponent),background_level^(1/gamma_exponent)];
background = background * 255;

% Directory to randomly pull images from. All images are resized to the
% size given. (May distort if not square.)
%targets_dir='face_images';
%filename_mask='*.jpg';
targets_dir='natural';
filename_mask='*.png';

show_pf=0;

% RUN
which_experiment='RIQ_pairs';
run_experiment;


