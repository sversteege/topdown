function plot_time_frequency_analysis(TFRhann, plot_option, electrode_index)
%   PLOT_TIME_FREQUENCY_ANALYSIS(TFRhann, plot_option, electrode_index)
%   This function visualizes the time-frequency representation based on the specified plot_option.
%
%   Inputs:
%       TFRhann        - Struct, time-frequency representation from ft_freqanalysis.
%       plot_option     - String, either 'single' or 'multiple'.
%       electrode_index  - Integer, the index of the electrode to plot if plot_option is 'single'.
%
%   Example Usage:
%       plot_time_frequency_analysis(TFRhann, 'single', 1); % Plot only electrode 1
%       plot_time_frequency_analysis(TFRhann, 'multiple');   % Plot all electrodes

if strcmpi(plot_option, 'single')
    if nargin < 3 || isempty(electrode_index) || electrode_index <= 0 || electrode_index > length(TFRhann.label)
        error('Invalid electrode index. Please provide a valid index for a single plot.');
    end
        
    cfg              = [];
    cfg.baseline     = 'no';  % No baseline correction (change if needed)
    cfg.channel      = TFRhann.label{electrode_index}; % Select the specified channel
        
    figure;
    ft_singleplotTFR(cfg, TFRhann);
    title(sprintf('Time-Frequency Plot for Electrode: %s', TFRhann.label{electrode_index}));

elseif strcmpi(plot_option, 'multiple')
    nChannels = length(TFRhann.label); % Number of channels in the dataset

    for ch = 1:nChannels
        cfg              = [];
        cfg.baseline     = 'no'; % No baseline correction (change if needed)
        cfg.channel      = TFRhann.label{ch}; % Select the current channel
            
        figure;
        ft_singleplotTFR(cfg, TFRhann);
        title(sprintf('Time-Frequency Plot for Electrode: %s', TFRhann.label{ch}));
    end
        
else
    error('Invalid plot_option. Choose either ''single'' or ''multiple''.');
end