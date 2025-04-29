function power_band = compute_band_power(pspec, freq_range, perform_artifact_rejection)
%   power_band = COMPUTE_BAND_POWER(pspec, freq_range, perform_artifact_rejection)
%   This function calculates the average power within a given frequency range.
%   It optionally performs artifact rejection based on the mean and standard deviation
%   of the power across electrodes. Rejected electrodes have NaN power
%   values.
%
%   Inputs:
%       pspec                      - Struct containing frequency and power spectrum data.
%       freq_range                 - 2-element vector specifying the frequency range [low_freq, up_freq].
%       perform_artifact_rejection - Boolean, specify true to perform artifact rejection, false otherwise.
%
%   Output:
%       power_band                 - Array containing the average power for each electrode in the specified band.
%
%   Example Usage:
%       power_alpha = compute_band_power(pspec, [8, 12], true);  % Compute with artifact rejection
%       power_alpha = compute_band_power(pspec, [8, 12], false); % Compute without artifact rejection

% Find indices corresponding to the specified frequency range
low_freq = freq_range(1);
up_freq = freq_range(2);
    
[~, low_index] = min(abs(pspec.freq - low_freq)); % Closest index to low_freq
[~, up_index] = min(abs(pspec.freq - up_freq));   % Closest index to up_freq

% Compute the average power in the specified frequency band
power_band = mean(pspec.powspctrm(:, low_index:up_index), 2);

% Perform artifact rejection if specified
if perform_artifact_rejection
    for i = 1:2  % Repeat artifact rejection twice
        m = mean(power_band, 'omitnan');
        s = std(power_band, 'omitnan');
        for electrode = 1:size(pspec.powspctrm, 1)
            if power_band(electrode) > m + s
                power_band(electrode) = NaN;  % Mark as NaN to indicate an artifact
            end
        end
    end
end

% Plot results
figure();
plot(1:size(pspec.powspctrm, 1), power_band, 'o', 'MarkerSize', 7);
xlabel('Electrode');
ylabel('Power');
title(['Average power in band: ' num2str(low_freq) ' Hz to ' num2str(up_freq) ' Hz']);
nicegraph;
end