function [binned,bout,bout_freq] = bin(aligned, iti, bin_size)
    binned = zeros(iti/bin_size,1);
    boutfreq = zeros(iti/bin_size,1);
    boutid_count = zeros(iti/bin_size,1);
    bout = [];
    
    prevlick = 0;
    boutON = 0;
    bout_count = 0;
    boutlength = 0;
    
    for cur = 1:size(aligned,1)
        start_binned = aligned(cur,3);
        if start_binned == iti/2
            bid = (iti/bin_size) - (((iti/2)-start_binned)/bin_size);
        else
            bid = (iti/bin_size) - (((iti/2)-start_binned)/bin_size) + 1;
        end
        binned(bid,1) = binned(bid,1) + 1;
        
        % Licking bout analysis
        if boutON == 0 && aligned(cur,8) - prevlick < 500
            % if first lick happens before 500ms
            if cur == 1
                prevlick = aligned(cur,8);
                continue
            end
            % other situation
            boutON = 1;
            boutlength = 2;
            boutStart = prevlick;
            boutStartRow = cur - 1;
            prevlick = aligned(cur,8);
            boutid = bid;
        elseif boutON == 1 && aligned(cur,8) - prevlick < 500
            boutlength = boutlength + 1;
            prevlick = aligned(cur,8);
        elseif boutON == 1 && aligned(cur,8) - prevlick >= 500
            boutON = 0;
            if boutlength >= 4
                boutEnd = aligned(cur-1,8);
                boutEndRow = cur - 1;
                bout_count = bout_count + 1;
                boutDuration = (boutEnd - boutStart)/1000;
                boutFreq = boutlength / boutDuration;
                new_row = [bout_count boutlength boutFreq boutStartRow boutEndRow];
                bout = [bout; new_row];
            end
            boutlength = 0;
            prevlick = aligned(cur,8);
        elseif boutON == 0 && aligned(cur,8) - prevlick > 500
            prevlick = aligned(cur,8);
        end
        
%         % Licking bout analysis (bin)
%         if boutON == 0 && aligned(cur,2) - prevlick < 500
%             boutON = 1;
%             boutlength = 2;
%             boutStart = prevlick;
%             boutid = bid;
%             prevlick = aligned(cur,2);
%         elseif boutON == 1 && aligned(cur,2) - prevlick < 500 && aligned(cur,3) == aligned(cur-1,3)
%             boutlength = boutlength + 1;
%             prevlick = aligned(cur,2);
%         elseif boutON == 1 && aligned(cur,2) - prevlick > 500 || aligned(cur,3) ~= aligned(cur-1,3)
%             boutON = 0;
%             if boutlength >= 4
%                 boutEnd = aligned(cur-1,2);
%                 boutDuration = (boutEnd - boutStart)/1000;
%                 boutFreq = boutlength / boutDuration;
%                 boutfreq(boutid,1) = boutfreq(boutid,1) + boutFreq;
%                 boutid_count(boutid,1) = boutid_count(boutid,1) + 1;    
%             end
%             boutlength = 0;
%             prevlick = aligned(cur,2);
%         elseif boutON == 0 && aligned(cur,2) - prevlick > 500
%             prevlick = aligned(cur,2);
%         end
    end
    
    bout_freq = boutfreq;
    for i = 1:size(boutfreq,1)
        if boutid_count(i,1) == 0
            bout_freq(i,1) = 0;
        else
            bout_freq(i,1) = bout_freq(i,1) / boutid_count(i,1);
        end
    end
end