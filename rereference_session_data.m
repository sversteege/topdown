function session_data = rereference_session_data(session_data)
%   session_data = REREFERENCE_SESSION_DATA(session_data)
%   This function modifies the session_data structure by re-referencing
%   the first 96 channels. The mean across these channels is subtracted
%   from each channel's data.
%
%   Inputs:
%       session_data - Struct, input data structure containing trial data 
%                      where each trial is an array of shape (channels x time).
%
%   Outputs:
%       session_data - Struct, modified data structure with re-referenced trial data.
%
%   Example usage:
%       session_data = rereference_session_data(session_data);

nTrials = length(session_data.trial);              

for n = 1:nTrials
    trial = session_data.trial{1, n};              % Extract the current trial data
    m = mean(trial(1:96,:), 1);                    % Calculate mean across the first 96 channels (no analog channels)
    for chan = 1:96
        trial(chan,:) = trial(chan,:) - m;         % Subtract mean
    end
    session_data.trial{1, n} = trial;              % Update the trial data in session_data
end

disp('Session data has been re-referenced.')
end