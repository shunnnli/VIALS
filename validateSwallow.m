function [emgswallow] = validateSwallow(emgenv,loc,tp,camdata)
% Find putative swallow based on EMG
% find EMG envelope peak without tongue protrusion
%   OUTPUT:
%       emgswallow = [esid, time, envplocs(i), envpeaks(i), nextpeak]

maxlag = 0.2;   % 150 ms

% lary corrected trajectory = Laryngeal - jaw
yjaw = loc(:,14);
revjaw = loc(:,11) - yjaw;

% If jaw marker is too low --> not swallowing
alljh = yjaw(tp(:,36));  % all jaw height during tongueInFrame
jawthreshold = nanmean(alljh);  % mean
% jawthreshold = prctile(alljh,25); % 25%
% jawthreshold = min(alljh);

% Find peaks of EMG envelope
[envpeaks,envplocs] = findpeaks(emgenv(:,2),...
    'MinPeakDistance',3000,'MinPeakProminence',30);
% Find peaks of laryngeal y trajectory
[peaks,locs] = findpeaks(revjaw,'MinPeakDistance',15,'MinPeakProminence',5);

% Find whether peaks in ylplocs concurred with tongue protrusion
esid = 0;
emgswallow = [];
tpRange = tp(:,35:36);
for i = 1:size(envplocs)
    time = emgenv(envplocs(i),1);    % corresponding time
    frame = time2frame(time,camdata);
    maxframe = time2frame(time+maxlag,camdata);
    % find the first traj peak after EMG peak
    nextpeakloc = find(locs > frame & locs <= maxframe,1);
    nextpeak = locs(nextpeakloc);
    if ~isempty(nextpeak)
        istp = find(nextpeak >= tpRange(:,1) & nextpeak <= tpRange(:,2), 1);
        if isempty(istp)
            % Filter if lary & jaw are around the same height (tongue must be out)
            if yjaw(nextpeakloc) <= jawthreshold
                continue
            end
            % add peak to emgswallow if after filtering
            esid = esid + 1;
            new_row = [esid, time, envplocs(i), envpeaks(i), nextpeak];
            emgswallow = [emgswallow; new_row];
        end
    else
        % add peak to emgswallow if after filtering
        esid = esid + 1;
        new_row = [esid, time, envplocs(i), envpeaks(i), NaN];
        emgswallow = [emgswallow; new_row];
    end
end

end

