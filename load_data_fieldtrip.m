function [session_data,orientations] = load_data_fieldtrip(PATH, trial_init, offset, meta_file)
%   [session_data,orientations] = LOAD_DATA_FIELDTRIP(PATH, trial_init, offset, meta_file)
%   loads data from multiple trials of a session and combines them into a single data structure compatible with FielTrip.
%   Returns chronological orientation array as well.
%
%   Inputs:
%       PATH        - String, directory path where the .ns2 files are stored.
%       trial_init  - Integer, initial trial number that corresponds to the session.
%       offset      - Integer, offset between trial number and the second number in file names.
%       meta_file   - String, name of the CSV file containing metadata (i.e., `parameters_24.07.11_A.csv`).
%
%   Outputs:
%       session_data    - Struct, combined data structure containing all trials' data.
%                     Fields include time, trial data, and header information.
%       orientations    - Array, angles of orientation in chronological order as specified in the metadata file.
%
%   Example usage:
%       addpath('/Volumes/mbneufy2/Haptic/Data Analysis');
%       PATH = '/Volumes/mbneufy2/Haptic/Data/day 10/touch_orientation 2';
%       trial_init = 6;          
%       offset = 14;            
%       meta_file = 'parameters_24.07.11_A.csv';
%       [session_data, orientations] = load_data_fieldtrip(PATH, trial_init, offset, meta_file);
%
%   Notes:
%   This function assumes there are 30 trials in a session without electric stimulus,
%   each trial having a different orientation.
%
%   Some meta files may have variables starting with a capital letter (e.g., `Trial`, `Electrode`).
%   Or they have slightly different names (e.g., 'angle' = 'Orientation')
%   Ensure you match these exactly in the code as needed.
%
%   For some reason, in some sessions, the trial index in the filenames
%   skips a value. For example, it goes from 122 to 124. In these cases, you
%   will receive an error, since 123 does not exist. This can be fixed by adding 1 to
%   trial_idx. For the subsequent trials, this has to be done aswell. Therefore, I
%   created a new while loop inside another one. When it is finished, it
%   stops the first while loop.
%   If you receive this error, just uncomment the following section and comment
%   the for loop below.
%{
i=1;
while i < length(non_stim_indices) + 1
    trial_idx = non_stim_indices(i) + trial_init - 1;
    file_name = sprintf(fullfile(PATH, 'trellis_touch_orientation_Trial_%d_00%d.ns2'), trial_idx, trial_idx + offset);   
    try
        cfg = [];
        cfg.dataset = file_name;
        cfg.demean = 'no'; % We do this manually
        all_data{i} = ft_preprocessing(cfg);
        i = i+1;
    catch ME
        %if this happens, the names have skipped a number value. Add 1 to trial
        %_idx gives the solution. This then happens for every subsequent
        %trial
        while i < length(non_stim_indices) + 1
            cfg = [];
            trial_idx = non_stim_indices(i) + trial_init;
            file_name = sprintf(fullfile(PATH, 'trellis_touch_orientation_Trial_%d_00%d.ns2'), trial_idx, trial_idx + offset);
            cfg.dataset = file_name;
            cfg.demean = 'no'; % We do this manually
            all_data{i} = ft_preprocessing(cfg);
            i = i+1;
        end
        break
    end
end
%}

% Load metadata
meta_data = readtable(fullfile(fileparts(PATH), meta_file));
non_stim_indices = meta_data.trial(meta_data.electrode == 0);
    
% Preallocate cell array for all data
all_data = cell(1, length(non_stim_indices));

% Return orientation array (needed later)
orientations = meta_data.angle(non_stim_indices());
    
% Loop over each trial index
for i = 1:length(non_stim_indices)
    trial_idx = non_stim_indices(i) + trial_init - 1;
    file_name = sprintf(fullfile(PATH, 'trellis_touch_orientation_Trial_%d_00%d.ns2'), trial_idx, trial_idx + offset);
    cfg = [];
    cfg.dataset = file_name;
    cfg.demean = 'no'; % We do this manually
    all_data{i} = ft_preprocessing(cfg);
end
    
disp('All non-electric stim data has been loaded.');

% Combine trials into a single structure
nTrials = length(all_data);
all_time = cell(1, nTrials); 
all_trial = cell(1, nTrials);

for i = 1:nTrials
    all_time{i} = all_data{i}.time{1}; 
    all_trial{i} = all_data{i}.trial{1};
end

% Rearrange into a new combined structure
session_data = all_data{1}; % Use the first trial's structure as a template
session_data.time = all_time;   % Replace the time field
session_data.trial = all_trial; % Replace the trial field
session_data.hdr.nTrials = nTrials;

disp('Data has been successfully combined into session_data.');
end