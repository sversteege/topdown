%This is an example script for how to run a fieldtrip analysis.
%First, make sure that you have Fieldtrip installed and automatically loaded each time you boot up matlab.
%Then, make sure that matlab knows where our custom functions are located:

addpath('/Volumes/mbneufy2/Haptic/Data Analysis/matlab');

%As you might already see, you need to connect to the server mbneufy2 first. To do
%this (on Mac), press cmd+k. Then find smb://mbneufy2-srv.science.ru.nl.
%The data is stored there. I would advise uploading your own data there
%aswell, since this code will work then, and the data takes up a lot of
%space.

% This example script uses either fieldtrip functions or custom made
% functions. Fieldtrip functions start with ft_... and require configuration
% structures (cfgs) as input. Documentation is available online for ft functions.
% Documentation for custom made functions is available aswell in the .m files.
% Be sure to check the documentation before using the functions. This
% script uses blocks to execute steps in the pipeline. Just press cmd+enter
% or ctrl+enter to execute a block of code. Certain blocks can be skipped,
% depending on what you want to analyze.

%% 1: load in data in fieldtrip compatible format (see function documentation):

PATH = '/Volumes/mbneufy2/Haptic/Data/day 10/touch_orientation 2';
trial_init = 6;          
offset = 14;           %20-6=14
meta_file = 'parameters_24.07.11_A.csv';

[session_data, orientations] = load_data_fieldtrip(PATH, trial_init, offset, meta_file);

%% 2: cut the data

cfg = [];
cfg.latency = [0, 5.2]; % Keep the first 5.2 seconds

session_data = ft_selectdata(cfg, session_data);

%% 3: substract channel mean from each trial

session_data = rereference_session_data(session_data);

%% 4: time-frequency analysis
% see fieldtrip function documentation for your options:
% https://github.com/fieldtrip/fieldtrip/blob/master/ft_freqanalysis.m

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'lfp';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 0:.5:100;         %frequency interval and resolution
cfg.t_ftimwin    = 7./cfg.foi;       %moving time window, 7 cycles per time window
cfg.toi          = '50%';            %time window overlap percentage        

TFRhann = ft_freqanalysis(cfg, session_data);

%% 5: plotting timefreq analysis

plot_time_frequency_analysis(TFRhann, 'single', 23); % Plot only electrode 15
%plot_time_frequency_analysis(TFRhann, 'multiple');   % Plot all electrodes

%% 6: mtmfft
%power spectra averaged over trials in a session

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'lfp';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 0:.5:100;
cfg.t_ftimwin    = 7./cfg.foi;
cfg.toi          = '50%';

pspec = ft_freqanalysis(cfg, session_data);

%% 7: plot single electrode spectrum

electrode = 15;
plot_power_spectrum(pspec, electrode);  

%% 8: compute average power in a frequency band for each electrode
%also perform artefact rejection, see function documentation for more
%details

fmin = 8;
fmax = 12;
artefact_rejection = true;

power_alpha = compute_band_power(pspec, [fmin, fmax], artefact_rejection);

%% 9: compute average power in a frequency band for each electrode and orientation
% this function uses ft_freqanalysis. if you want to set a specific t_ftimwin
% or toi, go to the function compute_power_per_orientation.m itself.
% you can change the cfg structure of ft_freqanalysis there.

fmin = 8;
fmax = 12;
artefact_rejection = true;
power_alpha = compute_power_per_orientation(session_data, [fmin,fmax], artefact_rejection);

%% 10: plot and save power as a function of orientation for 3 electrode groups
%For this, a red, green and blue electrode group have been defined,
%according to the correlation maps of the Jan Antolink group. See function
%documentation for the precise definition of these electrode groups. Also,
%if you want to store the data on a different place than the server, you
%can optionally provide these pathnames. In addition, note that this
%function plots power deviation from overall group mean and saves
%just the power values.

name1 = 'power_alpha_example.mat';
name2 = 'power_plot_example.svg';
save_data = false;

plot_and_save_power(name1, name2, orientations, power_alpha,save_data);
%plot_and_save_power(name1, name2, orientations, power_alpha, save_data, '/custom/path/power_data', '/custom/path/figures');

%% 11: average power map over sessions

all_power_data = power_map_multiple_sessions();
%all_power_data = power_map_multiple_sessions('user_path');

%% 12: average power over sessions with standard error for an electrode

plot_average_power_with_se(all_power_data, 'single', 96); % Plot for electrode 1
%plot_average_power_with_se(all_power_data, 'multiple'); 
























