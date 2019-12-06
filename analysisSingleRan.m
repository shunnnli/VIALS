function [result,bout,freq_mat,summary] = analysisSingleRan(csvfile,time_limit,winsize,freq_cutoff,usd)
% analysisSingleRan: analysis lick performance of a single random ITI session
%   INPUT:  animal, csvfile, date, iti, rp_ON, bin_size, max_reward
%           winsize: sliding window size in ms
%           freq_cutoff: lick frequency threshold in Hz
%   OUTPUT: total_lick, avg_lf
%           bout: [bout_count boutlength boutFreq boutStartx boutStarty boutEndx boutEndy boutStartRow boutEndRow]
%           freq_mat: [winopen_corrected winlick winfreq]
%           summary: [total_lick avg_lf bnum avgblen avgbfreq lickcutoff trialcutoff mostfreq totalConsumed]

seq = readmatrix(csvfile);
summary = [];
start_time = 0;
total_trial = 0;
total_lick = 0;
thresh = 0.95;

freq_mat = [];
winlick = 0;
winabove = 0;

bout = [];
prevlick = 0;
boutON = 0;
bout_count = 0;
boutlength = 0;

for cur = 1:size(seq,1)
    if cur == 1
        start_time = seq(cur,2);
        winopen = start_time;
        winclose = winopen + winsize;
    end
    
    adj_time = (seq(cur,2) - start_time)/1000;  % time since the start of the session in sec
    if adj_time > time_limit
        break;
    end
    adj_y = floor(adj_time/10);                 % which 10s chunk does the lick belongs to
    adj_x = rem(adj_time,10);                   % sec in the 10s chunk
    hold on
    
    if seq(cur,2) > winclose
        winfreq = winlick / (winsize/1000);
        if winfreq >= freq_cutoff
            winabove = winabove + 1;
        end
        winopen_corrected = winopen - start_time;
        new_row = [winopen_corrected winlick winfreq];
        freq_mat = [freq_mat; new_row];
        
        diff = seq(cur,2) - winclose;
        add = ceil(diff/winsize);
        winopen = winopen + add*winsize;
        winclose = winclose + add*winsize;
        winlick = 0;
    end
    
    if seq(cur,1) == 5000
        new_row = [seq(cur,1), adj_x, adj_y];
        summary = [summary; new_row];
        total_trial = total_trial + 1;
        
    elseif seq(cur,1) == 2000 || seq(cur,1) == 0	
        lick_start = seq(cur,2);
        
    elseif seq(cur,1) == 2001
        lick_end = seq(cur,2);
        lick_duration = lick_end - lick_start;
        if lick_duration > 1000
                continue
        end
        
        new_row = [seq(cur,1), adj_x, adj_y];
        summary = [summary; new_row];
        total_lick = total_lick + 1;
        if seq(cur,2) <= winclose && seq(cur,2) > winopen
            winlick = winlick + 1;
        elseif seq(cur,2) > winclose
            disp('Window close error!');
            disp(cur);
        end
        
        % Licking bout analysis
        if boutON == 0 && seq(cur,2) - prevlick < 500
            boutON = 1;
            boutlength = 2;
            boutStart = prevlick;
            boutStartRow = cur - 1;
            boutStartx = adj_x;
            boutStarty = adj_y;
            prevlick = seq(cur,2);
        elseif boutON == 1 && seq(cur,2) - prevlick < 500
            boutlength = boutlength + 1;
            prevlick = seq(cur,2);
        elseif boutON == 1 && seq(cur,2) - prevlick >= 500
            boutON = 0;
            if boutlength >= 4
                boutEnd = seq(cur-1,2);
                boutEndRow = cur - 1;
                boutEndx = adj_x;
                boutEndy = adj_y;
                bout_count = bout_count + 1;
                boutDuration = (boutEnd - boutStart)/1000;
                boutFreq = boutlength / boutDuration;
                new_row = [bout_count boutlength boutFreq boutStartx boutStarty boutEndx boutEndy boutStartRow boutEndRow];
                bout = [bout; new_row];
            end
            boutlength = 0;
            prevlick = seq(cur,2);
        elseif boutON == 0 && seq(cur,2) - prevlick > 500
            prevlick = seq(cur,2);
        end
    else
        continue
    end
end

result = [];
avg_lf = total_lick / time_limit;
bnum = size(bout,1);
totalblength = 0;
totalbfreq = 0;
for i = 1:bnum
    totalblength = totalblength + bout(i,2);
    totalbfreq = totalbfreq + bout(i,3);
end
avgblen = totalblength / bnum;
avgbfreq = totalbfreq / bnum;

lickcutoff = total_lick * thresh;
lc = 0;
rc = 0;
for i = 1:size(seq,1)
    if seq(i,1) == 2000
        lc = lc+1;
        if lc >= lickcutoff
            trialcutoff = (seq(i,2)-start_time)/1000;
            break
        end
    elseif seq(i,1) == 5000
        rc = rc+1;
    end
end
totalConsumed = rc * 0.2 * usd;
mostfreq = lickcutoff/trialcutoff;

new_row = [total_lick avg_lf bnum avgblen avgbfreq ...
    lickcutoff trialcutoff mostfreq totalConsumed];
result = [result; new_row];
% disp((winabove * (winsize/1000))/time_limit);
end

