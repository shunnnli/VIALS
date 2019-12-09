function [pswallow,threshold] = defineSwallows(loc,tp,camdata)
% defineSwallows: Find putative swallows from corrected laryngeal movements
%   *: designed to be conservative (false positive is acceptable)
%   INPUT: ylplocs (local maxima of corrected laryngeal movement)
%          tp, loc
%   OUTPUT: pswallow = [psid, time, ylarypeaks(i)]

% lary corrected trajectory = Laryngeal - jaw
ylaryvsjaw = loc(:,11) - loc(:,14);

% Find peaks of laryngeal y trajectory
[ylarypeaks,ylplocs] = findpeaks(ylaryvsjaw,...
    'MinPeakDistance',15,'MinPeakProminence',0.1);

% Determine minimum height diff between two markers
% mean height diff among tongueInFrame
threshold = nanmean(ylaryvsjaw(tp(:,36)));
% mean height diff during resting?


% Find whether peaks in ylplocs concurred with tongue protrusion
psid = 0;
pswallow = [];
tpRange = tp(:,35:36);
for i = 1:size(ylplocs)
    frame = ylplocs(i);    % corresponding frame
    inRange = find(frame >= tpRange(:,1) & frame <= tpRange(:,2), 1);
    if isempty(inRange)
        % Filter if lary & jaw are around the same height (tongue must be out)
        if ylarypeaks(i) >= threshold
            continue
        end
        
        % add peak to pswallow if after filtering
        psid = psid + 1;
        new_row = [psid, frame2time(frame,camdata), ylarypeaks(i)];
        pswallow = [pswallow; new_row];
    end
end

end

