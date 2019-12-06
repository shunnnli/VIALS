function [aligned,binned,bout,bout_freq,lick_rate,total_trial,result,freq_mat] = analysisSingleFix(animal,csvfile,date,iti,bin_size,duration,writeAlign,usd,instanFreq)
% analysisSingleFix: analysis lick performance of a single fix ITI session
%   INPUT:  animal, csvfile, date, iti, rp_ON, bin_size, max_reward
%   OUTPUT: 
%       aligned: [lick_id start_aligned start_binned reward_id+1 lick_duration lick_interval last_reward lick_start]
%       bout: [bout_count boutlength boutFreq boutStartRow boutEndRow]
%             ***: boutStartRow / boutEndRow correspond to row in aligned.csv
%       result: [totalLick overallLickFreq bnum avgblen avgbfreq totalLick*thresh trialcutoff mostfreq totalConsumed]

seq = readmatrix(csvfile);
thresh = 0.95;
[aligned,freq_mat,total_trial] = align(seq, iti, bin_size,instanFreq);
if writeAlign == 1
    aligned_path = strcat(animal, '/', 'Data_tables/', date, '_aligned.csv');
    csvwrite(aligned_path, aligned);
end

[binned,bout,bout_freq] = bin(aligned, iti, bin_size);
lick_rate = binned/total_trial;

totalLick = size(aligned, 1);
overallLickFreq = totalLick/duration;
bnum = size(bout,1);
totalblength = 0;
totalbfreq = 0;
for i = 1:bnum
    totalblength = totalblength + bout(i,2);
    totalbfreq = totalbfreq + bout(i,3);
end
avgblen = totalblength / bnum;
avgbfreq = totalbfreq / bnum;

start_time = seq(1,2);
lickcutoff = totalLick * thresh;
trialcutoff = (aligned(round(lickcutoff),8) - start_time)/1000;
totalConsumed = (trialcutoff/(iti/1000)) * 0.2 * usd;
mostfreq = lickcutoff/trialcutoff;

result = [];
new_row = [totalLick overallLickFreq bnum avgblen avgbfreq ...
            totalLick*thresh trialcutoff mostfreq totalConsumed];
result = [result; new_row];

end

