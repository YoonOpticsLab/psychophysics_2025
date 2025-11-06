one_pixel_cm=monitor_horiz_size_cm/monitor_horiz_num_pixels
arcmin_per_pixel = atan( one_pixel_cm/distance_cm ) / pi * 180 * 60

if strcmp(which_experiment,'blur1')
    code_blur1;
elseif strcmp(which_experiment,'embedded_num')
    code_embedded_number;
end
