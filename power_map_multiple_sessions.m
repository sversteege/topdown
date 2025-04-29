function all_power_data = power_map_multiple_sessions(user_path)
% POWER_MAP_MULTIPLE_SESSIONS Loads power data from multiple sessions,
% computes the average power in the alpha band per orientation, and plots
% the results.
%
%   all_power_data = POWER_MAP_MULTIPLE_SESSIONS(user_path)
%
%   Inputs:
%       user_path - (Optional) String, path to the directory containing power data files.
%                   If not provided, defaults to '/Volumes/mbneufy2/Haptic/Data/all_power_data'.
%
%   Outputs:
%       all_power_data - 3D matrix containing the power data for each channel, trial, and session.
%
%   Example Usage:
%       data = power_map_multiple_sessions(); % Use default path
%       data = power_map_multiple_sessions(user_path); % Use custom path

% Default path for loading session data
default_path = '/Volumes/mbneufy2/Haptic/Data/all_power_data';

% Use user-defined path if provided; otherwise, use the default
if nargin < 1 || isempty(user_path)
    PATH = default_path;
else
    PATH = user_path;
end

% Load in all session data
files = dir(fullfile(PATH, 'power_alpha_day*_session*.mat'));
nSessions = length(files);

if nSessions == 0
    error('No session files found in the specified directory.');
end
    
% Initialize variables - nChannels and nTrials will be derived from the first session
first_file_name = fullfile(PATH, files(1).name);
data = load(first_file_name);
field_name = fieldnames(data);
session_data = data.(field_name{1}); % Select the variable within the loaded struct
[nChannels, nTrials] = size(session_data); % Determine sizes based on the first session's data

all_power_data = NaN(nChannels, nTrials, nSessions); 

for i = 1:nSessions
    file_name = files(i).name;
    data = load(fullfile(PATH, file_name));   
    field_name = fieldnames(data);
    session_data = data.(field_name{1}); % Select the variable within the loaded struct
    all_power_data(:, :, i) = session_data; % Store in the all_power_data array
end

% Average over sessions
power = mean(all_power_data, 3, 'omitnan');

% Plot the average power map
figure;
surf(power);
colormap('hot');  % Color map (optional change can be made)
colorbar;  % Display color scale
title('Average Power in Alpha Band');
xlabel('Orientations (clockmin)');
ylabel('Channels');
zlabel('Power (\mu V^2)');

% Adjust x-axis ticks to plot orientations instead of trials
xticks(1:nTrials);
xticklabels(arrayfun(@num2str, linspace(-15, 14, nTrials), 'UniformOutput', false));
end