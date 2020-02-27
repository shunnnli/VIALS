function [pswallow,jawthreshold,allpeaks] = defineSwallows(loc,tp,camdata)
% defineSwallows: Find putative swallows from corrected laryngeal movements
%   INPUT: ylplocs (local maxima of corrected laryngeal movement)
%          tp, loc
%   OUTPUT: pswallow = [psid, time, ylarypeaks(i), sli]

% lary corrected trajectory = Laryngeal - jaw
yjaw = loc(:,14);
hdiff = loc(:,11) - yjaw;

% Find peaks of laryngeal y trajectory
[ylarypeaks,ylplocs,ylpw,ylpp] = findpeaks(hdiff,...
    'MinPeakDistance',15,'MinPeakProminence',5);

% If jaw marker is too low --> not swallowing
% calculate by the average of the middle of tongueInFrame and the next
% frame of tongueInFrame
jawtif = nanmean(yjaw(tp(:,36)));  % mean jaw height during tongueInFrame
jawtin = nanmean(yjaw(tp(:,36)+1));    % mean jaw height during tIF+1
jawthreshold = (jawtif+jawtin)/2;
% jawthreshold = prctile(alljh,25); % 25%
% jawthreshold = min(alljh);

% Find whether peaks in ylplocs concurred with tongue protrusion
psid = 0; pswallow = [];
tpRange = tp(:,35:36); sli = [];
for i = 1:size(ylplocs)
    frame = ylplocs(i);    % corresponding frame
    cursli = calcSLI(frame,loc,tp,'cont');
    tpid = find(frame >= tpRange(:,1) & frame <= tpRange(:,2), 1);
    
    if isempty(tpid)
        % Filter if lary & jaw are around the same height (tongue must be out)
        if yjaw(frame) <= jawthreshold
            sli = [sli;cursli,1];   % tongue doesnot appear but exceed thres
            continue
        end
        
        % add peak to pswallow if after filtering
        sli = [sli;cursli,2];
        psid = psid + 1;
        new_row = [psid,frame2time(frame,camdata),ylarypeaks(i),ylpp(i),cursli];
        pswallow = [pswallow; new_row];
    else
        sli = [sli;cursli,0];   % tongue appears
    end
end

% Store data of all peaks
allpeaks.pks = ylarypeaks;
allpeaks.locs = ylplocs;
allpeaks.w = ylpw;  % width
allpeaks.p = ylpp;  % prominance
allpeaks.sli = sli; % swallow likelihood index
disp('Putative swallow found');
end

