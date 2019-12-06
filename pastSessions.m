% ----------- Session settings -----------
past = readmatrix('/Users/shunli/Desktop/past.xlsx');
bin_size = 500;
winsize = 500;
freq_cutoff = 3;
writeAlign = 0;
initialWeight = [22.46 27.52 25.45 26.35 23.68 14.94 19.76 20.84 24.85];

% ------------- Reading csv -------------
sum = [];
instanFreq = [winsize,freq_cutoff];

for cur = 1:size(past,1)
    disp(cur);
    % Find csv and parameters
    animal = past(cur,1);
    date = past(cur,2);
    dateStr = strcat('0',num2str(date));
    csvfile = strcat(num2str(animal), '/', dateStr, '.csv');
    ranON = past(cur,5);
    iti = past(cur,6);
    duration = past(cur,7);
    fweight = past(cur,3) / initialWeight(animal);
    usd = past(cur,8);
    
    % Perform analysis
    if ranON == 0
        [aligned,binned,bout,bout_freq,lick_rate,total_trial,ret] = analysisSingleFix(animal,csvfile,date,iti,bin_size,duration,writeAlign,usd,instanFreq);
        new_row = [animal date past(cur,3) past(cur,4) ranON iti duration past(cur,8) past(cur,9) fweight ...
            ret(1,1) ret(1,2) ret(1,3) ret(1,4) ret(1,5) ret(1,6) ret(1,7) ret(1,8) ret(1,9)];
        sum = [sum; new_row];
    else
        [ret,bout,freq_mat,summary] = analysisSingleRan(csvfile,duration,winsize,freq_cutoff,usd);
        new_row = [animal date past(cur,3) past(cur,4) ranON iti duration past(cur,8) past(cur,9) fweight ...
            ret(1,1) ret(1,2) ret(1,3) ret(1,4) ret(1,5) ret(1,6) ret(1,7) ret(1,8) ret(1,9)];
        sum = [sum; new_row];
    end
end

writematrix(sum, '/Users/shunli/Desktop/past.xlsx');