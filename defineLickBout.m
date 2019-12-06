function lickbout = defineLickBout(tp)
% defineLickBout: Extract licking bout info based on camdata.licking
%   INPUT: tp
%   OUTPUT:
%       bout:[bout_count boutlength boutFreq 
%               boutStart boutEnd boutStartFrame boutEndFrame]
%       boutStart/boutEnd are tpids
%       boutlength is the number of licks within a bout

% remove non-lick tp
licktp = tp;
licktp(licktp(:,2) == 0,:) = [];

lickbout = [];
prevlick = -999;
boutON = 0;
bout_count = 0;
boutlength = 0;

for cur = 1:size(licktp,1)
    if boutON == 0 && licktp(cur,33) - prevlick < 0.5
        boutON = 1;
        boutlength = 2;
        boutStart = licktp(cur-1,1);
        prevlick = licktp(cur,33);
    elseif boutON == 1 && licktp(cur,33) - prevlick < 0.5
        boutlength = boutlength + 1;
        prevlick = licktp(cur,33);
    elseif boutON == 1 && licktp(cur,33) - prevlick >= 0.5
        boutON = 0;
        if boutlength >= 4
            boutEnd = licktp(cur-1,1);
            bout_count = bout_count + 1;
            boutDuration = (tp(boutEnd,33) - tp(boutStart,33));
            boutFreq = boutlength / boutDuration;
            boutStartFrame = tp(boutStart,35);
            boutEndFrame = tp(boutEnd,36);
            new_row = [bout_count boutlength boutFreq ...
                boutStart boutEnd boutStartFrame boutEndFrame];
            lickbout = [lickbout; new_row];
        end
        boutlength = 0;
        prevlick = licktp(cur,33);
    elseif boutON == 0 && licktp(cur,33) - prevlick > 0.5
        prevlick = licktp(cur,33);
    else
        continue
    end
end

end

