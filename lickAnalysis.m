%% Initializing
licklog = readmatrix('/Users/shunli/Desktop/licklog.xlsx');
initialWeight = [22.46 27.52 25.45 26.35 23.68 ...
                 14.94 19.76 20.84 24.85 19.71 ...
                 20.05 27.85 20.60];
bin_size = 500;
%% Enter new sessions
animal_prompt = 'Enter animal id: ';
animal = input(animal_prompt, 's');
animalNum = str2num(animal);

date_prompt = 'Enter the date of the csv file: ';
date = input(date_prompt, 's');
csvfile = strcat(animal, '/', date, '.csv');

ranON = 0;                          % Random (1) or fixed (0) ITI
iti = 10;                           % Enter iti in s
duration = 2500;                    % Enter the duration of the trial in s
time_limit = duration;

weight = 17.65;                     % Enter the weight in g
fweight = weight / initialWeight(animalNum);
water = 200;                        % Enter amount of water in ul after session
sucrose = 0;                        % Sucrose (1) or water (0) reward
usd = 10;                           % Enter USD in ms
rewardUnit = usd * 0.2;             % Volume of each reward

%% Perform single session lick analysis
rp_ON = 1;  % raster plot
writeAlign = 1;
writelog = 1;
max_reward = time_limit/iti;
winsize = 500;
freq_cutoff = 3;

% ---------------------- Fix ITI ------------------------
if ranON == 0
    iti = 1000 * iti;
    instanFreq = [winsize,freq_cutoff];
    [aligned,binned,bout,bout_freq,lick_rate,total_trial,ret,freq_mat] = ...
        analysisSingleFix(animal,csvfile,date,iti,bin_size,duration,writeAlign,usd,instanFreq);
    disp(strcat('Total licks: ', num2str(ret(1,1))));
    % Calculate lick score = (avg_lf-2) + blen*a + bfreq*b + bnum*c
    
    if writelog == 1
        new_row = [animalNum str2num(date) weight water ranON iti duration usd sucrose fweight ...
            ret(1,1) ret(1,2) ret(1,3) ret(1,4) ret(1,5) ret(1,6) ret(1,7) ret(1,8) ret(1,9)];
        licklog = [licklog; new_row];
        llret = sortrows(licklog,1);
        writematrix(llret, '/Users/shunli/Desktop/licklog.xlsx');
    end
    
    % ------------- Plotting whole trial freq plot -------------
    fp = figure('Name', 'Whole trial freq plot');
    set(gca,'box','off','color','w');
    line(freq_mat(:,1)/1000, smooth(freq_mat(:,3),25));
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Licking frequency (licks/s)', 'FontSize', 12);
    fp_path = strcat(animal, '/', 'Data_plots/', date, '_FP');
    saveas(fp, fp_path, 'png');
    
    % ------------- Plotting PSTH -------------
    psth = figure('Name', 'Peri-stimulus Time Histogram');
    plot(lick_rate);
    set(gca,'box','off','color','w');
    xlabel('Time relative to reward (s)', 'FontSize', 12);
    ylabel('Licking rate (licks/s)', 'FontSize', 12);
    psth_path = strcat(animal, '/', 'Data_plots/', date, '_PSTH');
    saveas(psth, psth_path, 'png');
    
    % bpsth = figure('Name', 'Bout Peri-stimulus Time Histogram');
    % plot(bout_freq);
    % set(gca,'box','off','color','w');
    % xlabel('Time relative to reward (s)', 'FontSize', 12);
    % ylabel('Average bout frequency (licks/s)', 'FontSize', 12);
    % bpsth_path = strcat(animal, '/', 'Data_plots/', date, '_boutPSTH');
    % saveas(bpsth, bpsth_path, 'png');

    % ------------- Plotting Bout Analysis --------------
    blenhis = figure('Name', 'Bout length histogram');
    histogram(bout(:,2), 'BinWidth', 1, 'Normalization', 'probability');
    set(gca,'box','off','color','w');
    % xlim([0, 30]);
    xlabel('Number of licks/bout', 'FontSize', 12);
    ylabel('Probability', 'FontSize', 12);
    blen_path = strcat(animal, '/', 'Data_plots/', date, '_blenHis');
    saveas(blenhis, blen_path, 'png');

    bfreqhis = figure('Name', 'Bout frequency histogram');
    histogram(bout(:,3), 'BinWidth', 0.5, 'Normalization', 'probability');
    set(gca,'box','off','color','w');
    % xlim([0, 15]);
    xlabel('Licking frequency per bout (licks/s)', 'FontSize', 12);
    ylabel('Probability', 'FontSize', 12);
    bfreq_path = strcat(animal, '/', 'Data_plots/', date, '_bfreqHis');
    saveas(bfreqhis, bfreq_path, 'png');

    brp = figure('Name', 'Bout start time plot');
    for i = 1:size(bout,1)
        boutStartRow = bout(i,4);
        boutEndRow = bout(i,5);
        startReward = aligned(boutStartRow,4);
        endReward = aligned(boutEndRow,4);
        hold on
        plot([aligned(boutStartRow,2) aligned(boutEndRow,2)],[startReward endReward],'Marker', 'x');
    end
    xlabel('Time relative to reward (ms)', 'FontSize', 12);
    ylabel('Trial number', 'FontSize', 12);
    ylim([0 total_trial]);
    set(gca,'box','off','color','w');
    brp_path = strcat(animal, '/', 'Data_plots/', date, '_BoutRP');
    saveas(brp, brp_path, 'png');
    
    if rp_ON == 1
        disp('Plotting raster plot...');
        rp = figure('Name', 'Whole trial raster plot');
        for cur_row = 1:size(aligned,1)
            cur_reward = aligned(cur_row,4);
            if cur_reward > max_reward
                break
            end
            hold on
            scatter(aligned(cur_row,2), aligned(cur_row,4), '.');
        end
        ylim([0 total_trial]);
        xlabel('Time relative to reward (ms)', 'FontSize', 12);
        ylabel('Trial number', 'FontSize', 12);
        set(gca,'box','off','color','w');
        rp_path = strcat(animal, '/', 'Data_plots/', date, '_singleRP');
        saveas(rp, rp_path, 'png');
    end
    disp('Single fix ITI session analysis DONE');

% ---------------------- Random ITI ------------------------
else
    [ret,bout,freq_mat,summary] = analysisSingleRan(csvfile,time_limit,winsize,freq_cutoff,usd);
    disp(ret(1,1));
    
    if writelog == 1
        new_row = [animalNum str2num(date) weight water ranON iti duration usd sucrose fweight ...
            ret(1,1) ret(1,2) ret(1,3) ret(1,4) ret(1,5) ret(1,6) ret(1,7) ret(1,8) ret(1,9)];
        licklog = [licklog; new_row];
        llret = sortrows(licklog,1);
        writematrix(llret, '/Users/shunli/Desktop/licklog.xlsx');
    end
    
    % ------------- Plotting whole trial freq plot -------------
    fp = figure('Name', 'Whole trial freq plot');
    set(gca,'box','off','color','w');
    line(freq_mat(:,1)/1000, smooth(freq_mat(:,3),25));
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Licking frequency (licks/s)', 'FontSize', 12);
    fp_path = strcat(animal, '/', 'Data_plots/', date, '_FP');
    saveas(fp, fp_path, 'png');
    
    % ------------ Plotting raster plot ------------
    disp('Plotting raster plot...');
    rp = figure('Name', 'Whole trial raster plot');
    for cur = 1:size(summary,1)
        hold on
        if summary(cur,1) == 5000
            scatter(summary(cur,2), summary(cur,3), 'x','black');
        else
            scatter(summary(cur,2), summary(cur,3), '.'); 
        end
    end
    ymax = time_limit / 10; 
    set(gca,'box','off','color','w');
    ylim([0 ymax]);
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Time (10s)', 'FontSize', 12);
    if time_limit == duration
        rp_path = strcat(animal, '/', 'Data_plots/', date, '_RP');
    else
        rp_path = strcat(animal, '/', 'Data_plots/', date, '_partialRP');
    end
    saveas(rp, rp_path, 'png');

    % ------------ Plotting bout analysis ------------
    blenhis = figure('Name', 'Bout length histogram');
    histogram(bout(:,2), 'BinWidth', 1, 'Normalization', 'probability');
    set(gca,'box','off','color','w');
    % xlim([0, 30]);
    xlabel('Number of licks/bout', 'FontSize', 12);
    ylabel('Probability', 'FontSize', 12);
    blen_path = strcat(animal, '/', 'Data_plots/', date, '_blenHis');
    saveas(blenhis, blen_path, 'png');

    bfreqhis = figure('Name', 'Bout frequency histogram');
    histogram(bout(:,3), 'BinWidth', 0.5, 'Normalization', 'probability');
    set(gca,'box','off','color','w');
    % xlim([0, 15]);
    xlabel('Licking frequency per bout (licks/s)', 'FontSize', 12);
    ylabel('Probability', 'FontSize', 12);
    bfreq_path = strcat(animal, '/', 'Data_plots/', date, '_bfreqHis');
    saveas(bfreqhis, bfreq_path, 'png');

    brp = figure('Name', 'Bout raster plot');
    for i = 1:size(bout,1)
        hold on
        plot([bout(i,4) bout(i,6)],[bout(i,5) bout(i,7)],'Marker', 'x');
    end
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Time (10s)', 'FontSize', 12);
    set(gca,'box','off','color','w');
    brp_path = strcat(animal, '/', 'Data_plots/', date, '_BoutRP');
    saveas(brp, brp_path, 'png');
    disp('Single random ITI session analysis DONE');
end

%% Enter target session parameters
 % Enter 233 to replace non-specific parameters
animal_prompt = 'Enter animal id: ';
animal = input(animal_prompt, 's');
animalNum = str2num(animal);

ranON = 0;                          % Random (1) or fixed (0) ITI
iti = 10;                           % Enter iti in s
duration = 2500;                    % Enter the duration of the trial in s
% time_limit = 2000000000000;
time_limit = duration;
sucrose = 0;                        % Sucrose (1) or water (0) reward
usd = 10;                           % Enter USD in ms

targetSessions = [animalNum ranON iti duration usd sucrose];
retname = 'iti';

%% Perform multiple session lick analysis
[filelist,num] = findSessions(licklog, targetSessions);
avg_totallick = mean(filelist(:,11));
avg_avglf     = mean(filelist(:,12));
avg_bnum      = mean(filelist(:,13));
avg_avgblen   = mean(filelist(:,14));
avg_avgbfreq  = mean(filelist(:,15));
ret = [avg_totallick avg_avglf avg_bnum avg_avgblen avg_avgbfreq];
ret_path = strcat(animal, '/', 'Total/',retname,'.csv');
writematrix(ret,ret_path);

%% Plot cross-session analysis
% first 10 days vs avg lick frequency

% Date vs 

%% PCA analysis of session parameters

