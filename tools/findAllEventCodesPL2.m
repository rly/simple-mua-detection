function [eventCodesByPort,eventTimes] = findAllEventCodesPL2(pl2FilePath, doPrint)
% Finds all event times and corresponding event codes stored as a binary 
% variable across Plexon EVT event variables in a Plexon PL2 file
%
% Inputs:
% - pl2FilePath: path to Plexon PL2 data file on filesystem
% - doPrint: boolean, whether to print debugging information
%
% Outputs:
% - eventCodesByPort: M x P of event codes (base 10) for each of the P 
%                     ports and M event times
% - allEventTimes: M x 1 array of event times, in seconds
%
% Written by Ryan Ly, Kastner Lab, Princeton University

if nargin == 1
    doPrint = 0;
end

%% setup, read PL2 file
% read header information of PL2 file
dataInfo = PL2GetFileIndex(pl2FilePath);

% access and store event times for each event variable in PL2 file (has
% format EVTxx) where xx is 01, 02, ...
nEventCh = 0;
for i = 1:numel(dataInfo.EventChannels)
    if dataInfo.EventChannels{i}.NumEvents > 0
        nEventCh = nEventCh + 1;
        if doPrint
            fprintf('%s(%d), ', dataInfo.EventChannels{i}.Name, ...
                    dataInfo.EventChannels{i}.NumEvents);
        end
        assert(strcmp(dataInfo.EventChannels{i}.Name, sprintf('EVT%02d', nEventCh)));
        ts = PL2EventTs(pl2FilePath, dataInfo.EventChannels{i}.Name);
        D.events{nEventCh} = ts.Ts;
    end
end

%% find the event codes, in base 10, on each port, corresponding to the triggered event times
[eventCodesByPort,eventTimes] = findAllEventCodes(D.events);
assert(numel(eventTimes) == size(eventCodesByPort, 1));

%% print how many events exist for each event code
if doPrint
    fprintf('\n');
    uniqueEventCodes = unique(eventCodesByPort, 'rows');
    uniqueEventCodesChar = num2str(uniqueEventCodes); % for ease of printing

    % count number of events for each combination of event codes across
    % ports
    numEventsPerCode = cellfun(@(x) sum(ismember(eventCodesByPort, x, 'rows')), ...
            num2cell(uniqueEventCodes, 2)); % works on rows

    for i = 1:size(uniqueEventCodesChar, 1)
        fprintf('Event code %s: %5d events\n', uniqueEventCodesChar(i,:), ...
                numEventsPerCode(i));
    end
end

% eventTimes(eventCodes == 15) % get all event times that have event code 15