one_pixel_cm=monitor_horiz_size_cm/monitor_horiz_num_pixels
arcmin_per_pixel = atan( one_pixel_cm/distance_cm ) / pi * 180 * 60



if strcmp(which_experiment,'blur1')
    blur1_run;
elseif strcmp(which_experiment,'embedded_num')
    embedded_number_run;
end