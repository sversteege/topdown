function plot_average_power_with_se(all_power_data, plot_option, electrode_index)
%   PLOT_AVERAGE_POWER_WITH_SE(all_power_data, plot_option, electrode_index)
%   This function calculates and plots the average power per electrode with 
%   standard error as a shaded region.
%
%   Inputs:
%       all_power_data - 3D matrix containing power data for each electrode, trial, and session.
%       plot_option     - String, specify 'single' to plot a specific electrode or 'multiple' for all electrodes.
%       electrode_index  - Integer, index of the electrode to plot when plot_option is 'single' (ignored if plot_option is 'multiple').
%
%   Example Usage:
%       plot_average_power_with_se(all_power_data, 'single', 1); % Plot only electrode 1
%       plot_average_power_with_se(all_power_data, 'multiple');   % Plot all electrodes

% Determine the number of electrodes and trials
[nChannels, nTrials, ~] = size(all_power_data);
    
% Calculate mean and standard error of the mean (SE)
mean_power = mean(all_power_data, 3, 'omitnan');
stderr = std(all_power_data, 0, 3, 'omitnan') ./ sqrt(sum(~isnan(all_power_data), 3));  % Standard error calculation

    if strcmpi(plot_option, 'single')
        % Ensure electrode_index is valid
        if electrode_index <= 0 || electrode_index > nChannels
            error('Invalid electrode index. Must be between 1 and %d.', nChannels);
        end
        
        % Plot mean ± SE for the selected electrode
        figure(electrode_index); 
        hold on;
        plot(linspace(-15, 14, nTrials), mean_power(electrode_index, :), 'b', 'LineWidth', 2);
        patch([linspace(-15, 14, nTrials), fliplr(linspace(-15, 14, nTrials))], ...
              [mean_power(electrode_index, :) + stderr(electrode_index, :), fliplr(mean_power(electrode_index, :) - stderr(electrode_index, :))], ...
              'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        hold off;
        xlabel('Orientation (clockmin)');
        ylabel('Power (\muV^2)');
        title(sprintf('Electrode %d - Mean ± SE', electrode_index));
        grid on;
        nicegraph;

    elseif strcmpi(plot_option, 'multiple')
        for electrode = 1:nChannels
            % Plot mean ± SE for all electrodes
            figure(electrode);
            hold on;
            plot(linspace(-15, 14, nTrials), mean_power(electrode, :), 'b', 'LineWidth', 2);
            patch([linspace(-15, 14, nTrials), fliplr(linspace(-15, 14, nTrials))], ...
                  [mean_power(electrode, :) + stderr(electrode, :), fliplr(mean_power(electrode, :) - stderr(electrode, :))], ...
                  'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            hold off;
            xlabel('Orientation (clockmin)');
            ylabel('Power (\muV^2)');
            title(sprintf('Electrode %d - Mean ± SE', electrode));
            grid on;
            nicegraph;
        end
    else
        error('Invalid plot option. Choose either ''single'' or ''multiple''.');
    end
end