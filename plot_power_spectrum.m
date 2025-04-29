function plot_power_spectrum(pspec, electrode, xlim_interval)
%   PLOT_POWER_SPECTRUM(pspec, electrode, xlim_interval)
%   This function plots the power spectrum from the pspec structure for a given electrode,
%   allowing users to set custom x-axis limits as an interval.
%
%   Inputs:
%       pspec         - Struct containing frequency and power spectrum information from ft_freqanalysis.
%       electrode      - Integer, index of the electrode whose power spectrum will be plotted.
%       xlim_interval   - (Optional) Numeric array, a 2-element array specifying the x-axis limits [xlim_lower, xlim_upper]. 
%                         Default interval is [0, 100].
%
%   Example Usage:
%       plot_power_spectrum(pspec, 1);                % Default x limits (0 to 100Hz)
%       plot_power_spectrum(pspec, 1, [10, 50]);      % Custom x limits (10 to 50Hz)

if electrode <= 0 || electrode > size(pspec.powspctrm, 1)
    error('Invalid electrode index. The index must be between 1 and %d.', size(pspec.powspctrm, 1));
end

% Set default x limits if not provided
if nargin < 3 || isempty(xlim_interval)
    xlim_interval = [0, 100]; % Default interval
elseif length(xlim_interval) ~= 2
    error('xlim_interval must be a 2-element array specifying [xlim_lower, xlim_upper].');
end

figure;
plot(pspec.freq, pspec.powspctrm(electrode,:), 'linewidth', 2);
xlabel('Frequency (Hz)');
xlim(xlim_interval); % Set custom x-axis limits
ylabel('Power (\mu V^2)');
title(sprintf('Electrode %d', electrode));
nicegraph; % Assuming nicegraph is a custom function for enhancing graph appearance
end