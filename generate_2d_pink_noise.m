

function pink_image = generate_2d_pink_noise(rows, cols, expo)
    % Generate 2D 1/f (pink) noise image
    % rows = number of rows
    % cols = number of columns
    
    % Generate white noise in frequency domain
    white_freq = fft2(randn(rows, cols));
    
    % Create 2D frequency grid
    [fx, fy] = meshgrid(0:cols-1, 0:rows-1);
    
    % Center the frequencies
    fx = fx - floor(cols/2);
    fy = fy - floor(rows/2);
    
    % Calculate radial frequency (distance from DC)
    f_radial = sqrt(fx.^2 + fy.^2);
    f_radial(f_radial == 0) = 1; % avoid division by zero at DC
    
    % Apply 1/f filter in frequency domain
    pink_freq = fftshift(white_freq) ./ sqrt(f_radial .^ expo );
    
    % Convert back to spatial domain
    pink_image = real(ifft2(ifftshift(pink_freq)));
    
    % Normalize to [0, 1] for display
    pink_image = (pink_image - min(pink_image(:))) / (max(pink_image(:)) - min(pink_image(:)));
end