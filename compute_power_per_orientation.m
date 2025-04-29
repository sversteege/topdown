function power_alpha = compute_power_per_orientation(data_all, freq_range, perform_artifact_rejection)
%   power_alpha = COMPUTE_POWER_PER_ORIENTATION(data_all, freq_range, perform_artifact_rejection)
%   This function calculates the average power within a given frequency range for each orientation (=trial),
%   and optionally performs artifact rejection based on the mean and standard deviation.
%
%   Inputs:
%       data_all                 - Struct containing all trial data structured for FieldTrip.
%       freq_range               - 2-element vector specifying the frequency range [low_freq, up_freq].
%       perform_artifact_rejection - Boolean, specify true to perform artifact rejection, false otherwise.
%
%   Output:
%       power_alpha              - Matrix containing the average power for each electrode (rows) per orientation (columns).
%
%   Example Usage:
%       power_alpha = compute_power_per_orientation(data_all, [8, 12], true);  % Compute with artifact rejection
%       power_alpha = compute_power_per_orientation(data_all, [8, 12], false); % Compute without artifact rejection

nTrials = size(data_all.trial, 2);
low = freq_range(1);
up = freq_range(2);
power_alpha = zeros(96, nTrials); % Initialize power_alpha array

for i = 1:nTrials
    cfg = [];
    cfg.trials = i; % Select current trial
    trial_data = ft_selectdata(cfg, data_all); % Extract data for this trial

    % Perform frequency analysis
    cfg = [];
    cfg.output       = 'pow';
    cfg.channel      = 'lfp';
    cfg.method       = 'mtmfft';
    cfg.taper        = 'hanning';
    cfg.foi          = low:0.5:up;
    cfg.t_ftimwin    = 7 ./ cfg.foi;  % 7 cycles per time window
    cfg.toi          = '50%';
        
    pspec_trial = ft_freqanalysis(cfg, trial_data); % Frequency analysis for the trial

        
    % Calculate the average power in the specified frequency band
    power_alpha_trial = mean(pspec_trial.powspctrm, 2); 

    % Perform artifact rejection if specified
    if perform_artifact_rejection
        for j = 1:2 % Repeat artifact rejection twice
            m = mean(power_alpha_trial, 'omitnan');
            s = std(power_alpha_trial, 'omitnan');
            for electrode = 1:size(pspec_trial.powspctrm, 1)
                if power_alpha_trial(electrode) > m + s
                    power_alpha_trial(electrode) = NaN; % Mark as NaN to indicate an artifact
                end 
            end
        end
    end
        
    % Store the results for the current trial
    power_alpha(:, i) = power_alpha_trial;
end
end