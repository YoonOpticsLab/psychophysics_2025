% For demo: change this to trye
if true
    % Example usage:
    rows = 512;
    cols = 512;
    
    % Generate 2D pink noise
    pink_img = generate_2d_pink_noise(rows, cols, 2);
    
    % Display the image
    figure;
    subplot(1,2,1);
    imshow(pink_img);
    title('2D 1/f (Pink) Noise');
    colorbar;
    
    % Show power spectrum
    subplot(1,2,2);
    pink_fft = fftshift(fft2(pink_img));
    power_spectrum = abs(pink_fft).^2;
    imagesc(log10(power_spectrum + 1)); % log scale for better visualization
    axis square;
    title('Power Spectrum (log scale)');
    colorbar;
    colormap(gca, 'jet');
    
    % Optional: Radial average of power spectrum
    figure;
    pink_fft = fft2(pink_img);
    power = abs(fftshift(pink_fft)).^2;
    [fx, fy] = meshgrid(0:cols-1, 0:rows-1);
    fx = fx - floor(cols/2);
    fy = fy - floor(rows/2);
    f_radial = sqrt(fx.^2 + fy.^2);
    
    % Compute radial average
    max_radius = floor(min(rows, cols)/2);
    radial_power = zeros(max_radius, 1);
    for r = 1:max_radius
        mask = (f_radial >= r-0.5) & (f_radial < r+0.5);
        radial_power(r) = mean(power(mask));
    end
    
    loglog(1:max_radius, radial_power/radial_power(1), 'b-', 'LineWidth', 2);
    hold on;
    loglog(1:max_radius, 1./(1:max_radius).^2, 'r--', 'LineWidth', 2);
    xlabel('Spatial Frequency');
    ylabel('Power');
    title('Radial Power Spectrum');
    legend('Generated', 'Theoretical 1/f^2');
    grid on;
end % demo