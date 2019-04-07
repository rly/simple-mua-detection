function [eventCodesByPort,allEventTimes] = findAllEventCodes(eventTimesByChannel)
% Finds all event times and corresponding event codes on each event port
% stored as a binary variable across Plexon EVT event channels
%
% Inputs:
% - eventTimesByChannel: N x 1 (or 1 x N) cell array of vectors of event
%                        times, in seconds, of channels EVT01 to EVTN. 
%                        N must be a multiple of 8
%
% Outputs:
% - eventCodesByPort: M x P of event codes (base 10) for each of the P 
%                     ports and M event times
% - allEventTimes: M x 1 array of event times, in seconds
%
% Written by Ryan Ly, Kastner Lab, Princeton University

allEventTimes = unique(cell2mat(eventTimesByChannel'));

% tolerance level for simultaneous signals: if two event signals are sent 
% on the same port within this number of seconds from each other, they 
% represent the same signal. i have seen events that were intended to be at
% the same time, or as close as possible to the same time, where the event
% on port 1 had time 1.512675075000000e+03 seconds and the event on port 2
% had time 1.512675100000000e+03 seconds, a difference of 25 microseconds. 
simultSignalTol = 0.001;

nChannel = numel(eventTimesByChannel);
nPort = nChannel / 8;
assert(mod(nChannel, 8) == 0);

% pre-allocate vars
eventCodesByPort = nan(numel(allEventTimes), nPort);

for i = 1:numel(allEventTimes)
    isFoundEvt = false(nChannel, 1);
    foundEvts = cell(nChannel, 1);
    foundEvtTimes = cell(nChannel, 1);
    
    % find the event on each channel that is at the same time (within
    % tolerance) of current event time
    for j = 1:nChannel
        foundEvts{j} = find(abs(allEventTimes(i) - eventTimesByChannel{j}) < simultSignalTol);
        foundEvtTimes{j} = eventTimesByChannel{j}(foundEvts{j});
        assert(numel(foundEvts{j}) <= 1);
        isFoundEvt(j) = ~isempty(foundEvts{j});
    end
    assert(any(isFoundEvt));
    
    % ensure that all found event times are within the tolerance away from
    % each other
    sortedFoundEvtTimes = sort(cell2mat(foundEvtTimes));
    assert(sortedFoundEvtTimes(end) - sortedFoundEvtTimes(1) < simultSignalTol);
    
    % convert binary code across channels to decimal (base 10) code (1 to 255)
    for j = 1:nPort
        % j == 1: ports are 1:8, j == 2: ports are 9:16
        startPort = (j-1)*8+1;
        endPort = j*8;
        % convert from reversed binary
        % if event 8 is 1 and events 1-7 are 0, then decimal event code is 128
        eventCodesByPort(i,j) = bin2dec(num2str(isFoundEvt(endPort:-1:startPort)'));
    end
end