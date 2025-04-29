function plot_and_save_power(name1, name2, orientations, power_alpha, save_data, power_path, figure_path)
%   PLOT_AND_SAVE_POWER(name1, name2, orientations, power_alpha, save_data, power_path, figure_path)
%   This function calculates and saves the average power for each
%   electrode group, then plots and saves the power deviation from the overall
%   group mean for all orientations and electrode groups in order to better visualize the
%   result.
%
%   Inputs:
%       name1         - String, filename to save the sorted power data.
%       name2         - String, filename to save the plot as an SVG.
%       orientations  - Array, containing the orientation data.
%       power_alpha   - Matrix, containing the power data for electrodes across orientations.
%       save_data     - Boolean, specify true to save the power data and figure, false otherwise.
%       power_path    - (Optional) String, directory path to save the power data. Default is '/Volumes/mbneufy2/Haptic/Data/all_power_data'.
%       figure_path   - (Optional) String, directory path to save the plot. Default is '/Volumes/mbneufy2/Haptic/Data Analysis/figures/'.
%
%   Example Usage:
%       plot_and_save_power('power_alpha_example.mat', 'power_plot_example.svg', orientations, power_alpha, true);
%       plot_and_save_power('power_alpha_example.mat', 'power_plot_example.svg', orientations, power_alpha, false);
%       plot_and_save_power('power_alpha_example.mat', 'power_plot_example.svg', orientations, power_alpha, false,'path/to/power','path/to/figure');

% Set default paths if not provided
if nargin < 6 || isempty(power_path)
    power_path = '/Volumes/mbneufy2/Haptic/Data/all_power_data';
end

if nargin < 7 || isempty(figure_path)
    figure_path = '/Volumes/mbneufy2/Haptic/Data Analysis/figures/behavioural analysis';
end

% Define electrode groups (adjusted for 1-based index)
red = [0,1,4,5,6,7,10,15,16,17,20,21,26,27,30,31,36,37,41,42,47,51,52,61,62,71,72,73,81,82,83,90,91] + 1;
green = [8,43,48,53,54,56,57,58,63,64,66,67,68,69,74,75,76,77,78,84,85,86,87,88,89,92,93,94,95] + 1;
blue = [2,3,9,11,12,13,14,18,19,22,23,24,25,28,29,32,33,34,35,38,39,40,44,45,46,49,50,55,59,60,65,70,79,80] + 1;

% Sort orientations and corresponding power data
[orientations_sorted, I] = sort(orientations);
power_alpha_sorted = power_alpha(:, I);

% Save sorted power data if the save_data flag is true
if save_data
    save(fullfile(power_path, name1), 'power_alpha_sorted');
end

% Calculate average power for each group
avg_power_red = mean(power_alpha_sorted(red, :), 1, 'omitnan');
avg_power_green = mean(power_alpha_sorted(green, :), 1, 'omitnan');
avg_power_blue = mean(power_alpha_sorted(blue, :), 1, 'omitnan');

% Plot the average power for each group
figure;
hold on;
plot(orientations_sorted, avg_power_red - mean(power_alpha_sorted, 'omitnan'), 'ro-', 'LineWidth', 2, 'DisplayName', 'Red Group', 'Color', [0.6350 0.0780 0.1840]);
plot(orientations_sorted, avg_power_green - mean(power_alpha_sorted, 'omitnan'), 'go-', 'LineWidth', 2, 'DisplayName', 'Green Group', 'Color', [0.4660 0.6740 0.1880]);
plot(orientations_sorted, avg_power_blue - mean(power_alpha_sorted, 'omitnan'), 'bo-', 'LineWidth', 2, 'DisplayName', 'Blue Group', 'Color', [0 0.4470 0.7410]);
hold off;
grid on;
xlabel('Orientation');
ylabel('Average Power Deviation (\muV^2)');
title('Average Power Deviation From Group Mean in Alpha Band Per Orientation');
legend('Location', 'northeastoutside');

% Save the figure if the save_data flag is true
if save_data
    saveas(gcf, fullfile(figure_path, name2));
end
end