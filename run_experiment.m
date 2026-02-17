one_pixel_cm=monitor_horiz_size_cm/monitor_horiz_num_pixels
arcmin_per_pixel = atan( one_pixel_cm/distance_cm ) / pi * 180 * 60

if strcmp(which_experiment,'blur1')
    code_blur1_quest;
elseif strcmp(which_experiment,'embedded_num')
    code_embedded_number;
elseif strcmp(which_experiment,'contour')
    code_contour;
elseif strcmp(which_experiment,'contour_spherical')
    code_contour_spherical;
elseif strcmp(which_experiment,'RIQ_pairs')
    code_riq;
elseif strcmp(which_experiment,'natural')
    code_natural_quest;      
end
