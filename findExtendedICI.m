function [longici] = findExtendedICI(tp,threshold)
% FindExtendedICI: Find extended intercontact interval that longer than the
%                   previous one by a certain threshold
%   INPUT: tp, threshold (in s)
%   OUTPUT: longici = [id icidiff iciStartFrame iciEndFrame prevtpid curtpid]

longici = [];
id = 0;

ici = tp(:,5);
dici = [0;diff(ici)];
longicipos = find(dici > threshold);

for i = 1:size(longicipos,1)
    id = id + 1;
    tpid = longicipos(i);
    if tpid ~= 1
        icidiff = tp(tpid,5) - tp(tpid-1,5);
        iciStartFrame = tp(tpid-1,36);
    else
        icidiff = NaN;
        iciStartFrame = 1;
    end
    iciEndFrame = tp(tpid,35);
    
    new_row = [id,icidiff,iciStartFrame,iciEndFrame,tpid-1,tpid];
    longici = [longici; new_row];
end

end

