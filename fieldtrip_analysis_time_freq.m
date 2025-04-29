%% pipeline for entire session
%1: load in all data for a single day/session
%2: combine trials into single structure
%3: (optional) select condition, cut data, demean data
%A: mtmconvol
    %4: time frequency analysis
    %5: visualization (either single plot or multiple plots)
%B: mtmfft
    %6: compute pspectrum
    %7: visualization
    %8: power in alpha band
    %9: power per orientation in alpha band
    %10: plot power values for each electrode as a function of orientation

%% 1: load in all data with no electric stim
%Due to weird data names, we need a couple of numbers first. This is the
%only thing that changes!:

%# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
%# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

PATH = '/Volumes/mbneufy2/Haptic/Data/day11/touch_orientation 3'; %The directory path where the .ns2 and .nev files are stored.
trial_init = 3; %Trial number of the first trial name corresponding to that session.
offset = 14;  %Difference between trial number en second number in a file name corresponding to that session
num_trials = 70; %Total number of trials in the session (can be 20, 50 or 70).
meta_file = fullfile(fileparts(PATH), 'parameters_24.07.12_B.csv'); %file that contains metadata

%# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
%# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

meta_data = readtable(meta_file);
non_stim_indices = meta_data.trial(meta_data.electrode == 0);
all_data = cell(1, length(non_stim_indices));
orientations = meta_data.angle(non_stim_indices());

for i = 1:length(non_stim_indices)
    trial_idx = non_stim_indices(i) + trial_init -1;
    file_name = sprintf(fullfile(PATH, 'trellis_touch_orientation_Trial_%d_00%d.ns2'), trial_idx, trial_idx + offset);
    cfg = [];
    cfg.dataset = file_name;
    cfg.demean = 'no'; % N.B.: demean!
    all_data{i} = ft_preprocessing(cfg);
end

disp('All non-electric stim data has been loaded.');

%% 2: combine trials into single structure
nTrials = length(all_data);
all_time = cell(1, nTrials); 
all_trial = cell(1, nTrials);

for i = 1:nTrials
    all_time{i} = all_data{i}.time{1}; 
    all_trial{i} = all_data{i}.trial{1};
end

% Rearrange into a new combined structure
data_all = all_data{1}; % Use the first trial's structure as a template
data_all.time = all_time;   % Replace the time field
data_all.trial = all_trial; % Replace the trial field
data_all.hdr.nTrials = nTrials;
clear all_data

disp('Data has been successfully combined into data_all.');

%% (optional) 3: select experimental condition
% you need trialinfo to exist in all_data for this to work 
cfg = [];
cfg.trials = data_all.trial == 1; %condition
all_data_cond= ft_redefinetrial(cfg, data_all);

%% (optional) 3: cut data
cfg = [];
cfg.latency = [0, 5.2]; % Keep the first 5 seconds (adjust this based on your sampling rate)

% Cut the data
data_all = ft_selectdata(cfg, data_all);

%% (optional) 3: manually demean data

for n = 1:nTrials
    trial = data_all.trial{1,n};
    m = mean(trial);
    for chan = 1:96
        trial(chan,:) = trial(chan,:) - m;
    end
    data_all.trial{1,n} = trial;
end


%% A4: time frequency analysis
% 2 cycles per window are selected
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'lfp';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 0:.5:80;
cfg.t_ftimwin    = 7./cfg.foi;  % 7 cycles per time window
cfg.toi          = '50%';
TFRhann = ft_freqanalysis(cfg, data_all);

%% A5: Visualization (singleplot)
cfg              = [];
cfg.baseline     = 'no';
cfg.channel      = 'lfp 1';
figure
ft_singleplotTFR(cfg, TFRhann);

%% A5: Visualization (multiplot)
nChannels = length(TFRhann.label); % Number of channels in the dataset

for ch = 1:nChannels
    cfg              = [];
    cfg.baseline     = 'no'; % No baseline correction (change if needed)
    cfg.channel      = TFRhann.label{ch}; % Select the current channel
    
    figure;
    ft_singleplotTFR(cfg, TFRhann);
    title(sprintf('Time-Frequency Plot: %s', TFRhann.label{ch}));
end

%% B6: mtmfft
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'lfp';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 0:.5:80;
cfg.t_ftimwin    = 7./cfg.foi;  % 7 cycles per time window
cfg.toi          = '50%';
pspec = ft_freqanalysis(cfg, data_all);

%% B7: visualization
electrode = 1;
figure;
plot(pspec.freq, pspec.powspctrm(electrode,:), 'linewidth', 2)
xlabel('Frequency (Hz)')
xlim([0 80])
ylabel('Power (\mu V^2)')
title(sprintf('Electrode %d', electrode));
nicegraph
%{
%now we want to check if averaging over some time window (~ 2 -> 3.5
%s)yields a similar graph:
start_time = 2;
end_time = 3;  

% Get time step and calculate indices
time_step = TFRhann.time(2) - TFRhann.time(1);
time_idx_start = round((start_time - TFRhann.time(1)) / time_step) + 1;
time_idx_end = round((end_time - TFRhann.time(1)) / time_step) + 1;

avg_pow = mean(TFRhann.powspctrm(:, :, time_idx_start:time_idx_end), 3);

figure;
plot(TFRhann.freq, avg_pow(electrode,:)', 'linewidth', 1)
xlabel('Frequency (Hz)')
ylabel('Power (\mu V^2)')
title(sprintf('Electrode %d' ,electrode))
xlim([0 80])
nicegraph
%}
%% B8: Power in alpha band
power_alpha = mean(pspec.powspctrm(:,17:25),2); %17 and 25 correspond with f indices for alpha band
%remove artefact electrodes
for electrode = 1:96
    if power_alpha(electrode) > 20
        power_alpha(electrode) = NaN;
    end
end

figure();
plot(1:96,power_alpha,'o','MarkerSize',7);
nicegraph
xlabel('Electrode')
ylabel('Power')
title('Average power in \alpha-band')

%% B9: power per orientation in alpha band (every trial is an orientation)
power_alpha = zeros(96,30);
for i = 1:30
cfg = [];
cfg.trials = i;
trial_data = ft_selectdata(cfg,data_all);

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'lfp';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 0:.5:80;
cfg.t_ftimwin    = 7./cfg.foi;  % 7 cycles per time window
cfg.toi          = '50%';
pspec_trial = ft_freqanalysis(cfg, trial_data);

power_alpha_trial = mean(pspec_trial.powspctrm(:,17:25),2); %17 and 25 correspond with f indices for alpha band

%remove artefact electrodes
for electrode = 1:96
    if power_alpha_trial(electrode) > 20
        power_alpha_trial(electrode) = NaN; %we do not want it to affect our average, so do not set to zero
    end
end
power_alpha(:,i) = power_alpha_trial;
end

%% B10: Plot power values for each electrode as a function of orientation
electrodes = 1:5;

%resort order first
[orientations_sorted, I] = sort(orientations);
power_alpha_sorted = power_alpha(:,I);
figure;
hold on;

for electrode = electrodes
    plot(orientations_sorted, power_alpha_sorted(electrode, :), 'o-', 'LineWidth', 2);
end
hold off;
grid on
xlabel('Orientation');
ylabel('Power (\muV^2)');
title('Average power in Alpha Band Across Orientations for Each Electrode');
legend(arrayfun(@(x) sprintf('Electrode %d', x), electrodes, 'UniformOutput', false), 'Location', 'northeastoutside');







