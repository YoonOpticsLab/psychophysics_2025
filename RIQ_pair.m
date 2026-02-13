close all; clear all;

% Call with interpolation factor (default 10x if not specified)
pairs = find_peak_pairs('RIQ_data_origin.csv', 5);

%save('RIQ_pairs','pairs')

function [pairs] = find_peak_pairs(filename, interp_factor)
% FIND_PEAK_PAIRS Finds peak and symmetric y-value pairs around the peak
%
% Input:
%   filename - path to input file with two row vectors (x and y)
%   interp_factor - (optional) interpolation factor to increase resolution
%                   Default is 10 (creates 10x more points)
%                   Use 1 for no interpolation
%
% Output:
%   pairs - structure array with fields:
%           y_value: the y value
%           x_left: x value on left side of peak
%           x_right: x value on right side of peak
%           y_right: actual y value on right side (closest match)

    % Set default interpolation factor if not provided
    if nargin < 2
        interp_factor = 10;
    end

    % Read the data file
    data = load(filename);
    
    % Assuming first row is x, second row is y
    x_raw = data(1, :);
    y_raw = data(2, :);
    
    fprintf('Original data: %d points\n', length(x_raw));
    
    % Apply interpolation for better resolution
    if interp_factor > 1
        % Create interpolated x values
        x = linspace(min(x_raw), max(x_raw), length(x_raw) * interp_factor);
        
        % Interpolate y values using PCHIP method
        y = interp1(x_raw, y_raw, x, 'pchip');
        
        fprintf('Interpolated data: %d points (factor: %dx)\n', length(x), interp_factor);
    else
        x = x_raw;
        y = y_raw;
        fprintf('No interpolation applied\n');
    end
    
    % Find the peak (maximum y value)
    [y_peak, peak_idx] = max(y);
    x_peak = x(peak_idx);
    fprintf('Peak found at x = %.4f, y = %.4f\n', x_peak, y_peak);
    
    % Split data into left and right sides of peak
    x_left = x(1:peak_idx);
    y_left = y(1:peak_idx);
    x_right = x(peak_idx:end);
    y_right = y(peak_idx:end);
    
    % Initialize pairs structure
    pairs = struct('y_value', {}, 'x_left', {}, 'x_right', {}, 'y_right', {});
    
    % For each y value on the left side (excluding peak)
    for i = 1:(length(y_left)-1)
        y_target = y_left(i);
        x_left_val = x_left(i);
        
        % Find closest y value on the right side
        [~, idx_right] = min(abs(y_right - y_target));
        
        % Store the pair
        pairs(i).y_value = y_target;
        pairs(i).x_left = x_left_val;
        pairs(i).x_right = x_right(idx_right);
        pairs(i).y_right = y_right(idx_right);
    end
    
    % Display results
    fprintf('\nFound %d pairs:\n', length(pairs));
    fprintf('%-4s %-12s %-12s %-12s %-12s %-12s\n', '#', 'y_left', 'x_left', 'x_right', 'y_right', 'y_error');
    fprintf('%s\n', repmat('-', 1, 68));
    for i = 1:length(pairs)
        y_error = abs(pairs(i).y_value - pairs(i).y_right);
        fprintf('%-4d %-12.4f %-12.4f %-12.4f %-12.4f %-12.6f\n', ...
                i, pairs(i).y_value, pairs(i).x_left, ...
                pairs(i).x_right, pairs(i).y_right, y_error);
    end
    
    % Optional: Create visualization
    figure;
    
    % Plot original data if interpolation was used
    if interp_factor > 1
        plot(x_raw, y_raw, 'b.-', 'LineWidth', 1, 'MarkerSize', 8, ...
             'DisplayName', 'Original Data');
        hold on;
        plot(x, y, 'c-', 'LineWidth', 0.5, 'DisplayName', 'Interpolated Data');
    else
        plot(x, y, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Data');
        hold on;
    end
    
    plot(x_peak, y_peak, 'r*', 'MarkerSize', 12, 'LineWidth', 2, ...
         'DisplayName', 'Peak');
    
    % Plot the pairs (limit to first 50 for clarity if many pairs)
    max_pairs_to_plot = min(length(pairs), 50);
    for i = 1:max_pairs_to_plot
        if i == 1
            plot([pairs(i).x_left, pairs(i).x_right], ...
                 [pairs(i).y_value, pairs(i).y_right], ...
                 'g--', 'LineWidth', 1, 'DisplayName', 'Matched Pairs');
        else
            plot([pairs(i).x_left, pairs(i).x_right], ...
                 [pairs(i).y_value, pairs(i).y_right], ...
                 'g--', 'LineWidth', 1, 'HandleVisibility', 'off');
        end
        plot(pairs(i).x_left, pairs(i).y_value, 'ro', 'MarkerSize', 6, ...
             'HandleVisibility', 'off');
        plot(pairs(i).x_right, pairs(i).y_right, 'mo', 'MarkerSize', 6, ...
             'HandleVisibility', 'off');
    end
    
    xlabel('x');
    ylabel('y');
    title(sprintf('Peak and Symmetric Y-Value Pairs (Interpolation: %dx)', interp_factor));
    legend('Location', 'best');
    grid on;
    hold off;
    
    % Print summary statistics
    y_errors = zeros(length(pairs), 1);
    for i = 1:length(pairs)
        y_errors(i) = abs(pairs(i).y_value - pairs(i).y_right);
    end
    fprintf('\nMatching Statistics:\n');
    fprintf('Average Y-error: %.6e\n', mean(y_errors));
    fprintf('Maximum Y-error: %.6e\n', max(y_errors));
    fprintf('Minimum Y-error: %.6e\n', min(y_errors));
end