function tpbout = defineTPBout(tp)
% defineBout: Extract tongue protrusion bout info based on tp
%   INPUT: tp
%   OUTPUT: 
%       bout:[bout_count boutlength boutFreq 
%               boutStart boutEnd boutStartFrame boutEndFrame]
%       boutStart/boutEnd are tpids
%       boutlength is the number of licks within a bout

tpbout = [];
prevlick = -999;
boutON = 0;
bout_count = 0;
boutlength = 0;

for cur = 1:size(tp,1)
    % disp(strcat('Current tpid: ', num2str(cur)));
    if boutON == 0 && tp(cur,33) - prevlick < 0.5
        boutON = 1;
        boutlength = 2;
        boutStart = tp(cur-1,1);
        prevlick = tp(cur,33);
    elseif boutON == 1 && tp(cur,33) - prevlick < 0.5
        boutlength = boutlength + 1;
        prevlick = tp(cur,33);
    elseif boutON == 1 && tp(cur,33) - prevlick >= 0.5
        boutON = 0;
        if boutlength >= 4
            boutEnd = tp(cur-1,1);
            bout_count = bout_count + 1;
            boutDuration = (tp(boutEnd,33) - tp(boutStart,33));
            boutFreq = boutlength / boutDuration;
            boutStartFrame = tp(boutStart,35);
            boutEndFrame = tp(boutEnd,36);
            new_row = [bout_count boutlength boutFreq ...
                boutStart boutEnd boutStartFrame boutEndFrame];
            tpbout = [tpbout; new_row];
        end
        boutlength = 0;
        prevlick = tp(cur,33);
    elseif boutON == 0 && tp(cur,33) - prevlick > 0.5
        prevlick = tp(cur,33);
    end
end

end

