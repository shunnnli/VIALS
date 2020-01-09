%% Load loc and EMG data
disp('----- Load loc and EMG data -----');

sessions = ["11-062419-1"; "11-062819-1"; "12-070519-2"; "13-090919-1";...
    "14-091519-1"; "18-102119-1"; "18-102519-1"; "18-102519-2";...
    "19-111119-1"];
session = sessions(9);
disp(session);

% Enter analysis window (in seconds)
start = 0;
stop = 120;

% Enter bandpass frequency
% Based on Lever et al. (2009) 
% https://link.springer.com/article/10.1007/s00455-009-9232-1
bplow = 100;
bphigh = 3000;

% Load single session data
[camdata,loc] = loadLocData(session,start,stop,0);
[tp,tpbout,lickbout,skinbout] = loadLocAnalysis(session,loc,camdata,0);
[emg,emgenv] = loadEMG(bplow,bphigh,start,stop,camdata);

% Reset tp.csv for multiple sessions
% for i = 1:size(sessions,1)
%     [camdata,loc] = loadLocData(sessions(i),start,stop,1);
%     [tp,tpbout,lickbout,swallowbout] = loadLocAnalysis(sessions(i),loc,camdata,1);
%     % [emg,emgenv] = loadEMG(bplow,bphigh,start,stop,camdata);
% end

%% Swallowing identification
disp('----- Swallowing identification -----');

% lary corrected trajectory = Laryngeal - jaw
ylaryvsjaw = loc(:,11) - loc(:,14);
% disp('ylaryvsjaw[] generated');

% Find putative swallow
% pswallow = [];
[pswallow,inthres,allpeaks] = defineSwallows(loc,tp,camdata);
% disp('Putative swallow found');

% Further filtering of putative swallow
% 2. if laryngeal does not move

% Find extended ILIs (longer than 20ms)
longici = findExtendedICI(tp,0.02);
% disp('Extended ICI found');

% Validate pswallow using EMG data
% emgswallow = [];
emgswallow = validateSwallow(emgenv,loc,tp,camdata);
% disp('EMG swallow found');

%% Raster plot
disp('----- Raster plot of event summary -----');

% Raster plot
% tp(any(isnan(tp(:,3)),2),:) = [];
[rp,psaligned,esaligned] = plotRaster(tp,pswallow,emgswallow,camdata);
rp_path = strcat('Videos/',session,'/','rp.svg');
legend

%% Swallowing bout visualized
disp('----- Visualization of swallowing bout -----');

% Trajectory plot
%{
19-111119-1;
only es: 5x, 17x, 24, 25, 25, 27, 28, 33, 33, 35, 39, 40, 41
only vs: 110-112s
%}

% Input time
sid = 38;
sdiff = -1;
t = camdata.reward(sid,1) + sdiff - 1;
% t = 95

% False-positive swallows: 78, 111
floor = time2frame(t,camdata);
ceiling = floor + 600;
time = frame2time(floor:ceiling,camdata);

% ylaryvsjaw
pks = find(pswallow(:,2) >= time(1) & pswallow(:,2) <= time(size(time,1)));
lici = find(longici(:,3) >= floor & longici(:,4) <= ceiling);

figure
subplot(2,1,1)
% for i = 1:size(lici) 
%     xline(frame2time(longici(lici(i),3),camdata),'-b');
%     hold on
%     xline(frame2time(longici(lici(i),4),camdata),'-b'); 
% end 
hold on
% plotBouts('swallowbout',skinbout,floor,ceiling,camdata);
hold on
plot(frame2time(loc(:,1),camdata),ylaryvsjaw);
hold on
plot(pswallow(:,2),pswallow(:,3),'or');
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),ylaryvsjaw,tp);
xlabel('Time (s)')
ylabel('Marker height difference (a.u.)')
xlim([time(1) time(length(time))]);

% ylaryvsjaw + EMG

% Find peaks of EMG envelope
[envpeaks,envplocs] = findpeaks(emgenv(:,2),...
    'MinPeakDistance',3000,'MinPeakProminence',20);

subplot(2,1,2)
plot(emg(:,1),emg(:,2),'Color','#4DBEEE');
hold on
plot(emgenv(:,1),emgenv(:,2),'LineWidth',1);
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
hold on
% for i = 1:size(lici) 
%     xline(frame2time(longici(lici(i),3),camdata),'-b');
%     hold on
%     xline(frame2time(longici(lici(i),4),camdata),'-b'); 
% end
hold on
% for i = 1:size(camdata.reward,1)
%     xline(camdata.reward(i),'-k');
% end
hold on
% plotConditionalTraj('emg',frame2time(loc(:,1),camdata),emgenv,tp);
hold on
plot(emgenv(envplocs,1),envpeaks,'oc');
hold on
plot(emgenv(emgswallow(:,3),1),emgswallow(:,4),'ob');
xlabel('Time (s)')
ylabel('EMG amplitude (a.u.)')
xlim([time(1) time(length(time))]);

%% Quantify swallow and licking movement
disp('----- Quantify swallow and lick movement -----');

% Percentage of pswallow in ici threshold ms longer than previous ici
%  5 ms: 84.17%, 10 ms: 82.92%, 15 ms: 82.08%, 20 ms: 81.25%
numerator = 0;
for i = 1:size(pswallow,1)
    inlici = find(pswallow(i,2) >= longici(:,3) & pswallow(i,2) <= longici(:,4),1);
    if ~isempty(inlici)
        numerator = numerator + 1;
    end
end
disp(numerator / size(pswallow,1));

% Percentage vs ici threshold
percentage = [];
for thres = -0.5:0.005:0.5
    testici = findExtendedICI(tp,thres);
    numerator = 0;
    for i = 1:size(pswallow,1)
        inlici = find(pswallow(i,2) >= testici(:,3) & pswallow(i,2) <= testici(:,4),1);
        if ~isempty(inlici)
            numerator = numerator + 1;
        end
    end
    percentage = [percentage; thres, numerator / size(pswallow,1)];
end
figure
plot(percentage(:,1),percentage(:,2));

% Number of tp preceeding pswallow in a bout

%% Tongue trajectory PCA
disp('----- Tongue Trajectory PCA -----');
% path = 

all = ["11-062419-1"; "11-062819-1"; "12-070519-2"; "13-090919-1";...
    "14-091519-1"; "18-102119-1"; "18-102519-1"; "18-102519-2";...
    "19-111119-1"];
mid = ["11-062419-1";"14-091519-1"];  % total: 14856 (8186+)
left = ["11-062819-1"; "12-070519-2"];  % total: 12576 (9074+)
animal = all(2);

% v1: 'dur','pLen','ampX/Y/Z','tpDevS/B','ilmPer'
% v2: 'dur','pLen','ampX/Y/Z','tpDevS/B','pPer/Vel','ilmPer/Vel','rPer/Vel'
version = 2;
dimension = 2;
[b,total,pcadata,kmdata] = tpClustering(mid,version,dimension);

% figure
% bar(1:size(pcadata.explained,1),pcadata.explained);
% xlabel('Principle component');
% ylabel('Percentage of total variance explained');

%% PCA data analysis
disp('------');

% retrieve observations closest to the centroid
[~,sw] = min(kmdata.d(:,1));
[~,se] = min(kmdata.d(:,2));
[~,nw] = min(kmdata.d(:,3));
[~,ne] = min(kmdata.d(:,4));

% Centroid samples
%{
SW: mid: 1-1972 left: 2-2055
SE: mid: 1-5040 left: 1-4501
NW: mid: 2-1850 left: 1-4038
NE: mid: 2-4958 left: 2-1831
%}

% sessions
all = ["11-062419-1"; "11-062819-1"; "12-070519-2"; "13-090919-1";...
    "14-091519-1"; "18-102119-1"; "18-102519-1"; "18-102519-2";...
    "19-111119-1"];
mid = ["11-062419-1";"14-091519-1"];  % total: 14856 (8186+)
left = ["11-062819-1"; "12-070519-2"];  % total: 12576 (9074+)
tp_path = strcat('Videos/',mid(1),'/tp.csv');
tp = readmatrix(tp_path);

% tpid = 
disp(tp(tpid,:));

% form a tp table
% ctp = [];
% ctp = [ctp; tp(total(ne,2),:)];

%% Plot tongue trajectory
disp('----- Plot tongue trajectory -----');

phase = 1;         % separate different lick phases or not

mid = ["11-062419-1";"14-091519-1"];  % total: 14856 (8186+)
left = ["11-062819-1";"12-070519-2"];  % total: 12576 (9074+)
session = mid(1);
disp(session);

% ctpid = transpose(ctp(:,1));
% tpid = ctpid(3);
tpid = 276;
% tpid = [2162 2566 1305 2409 2157; 2823 910 2442 1943 2626] + 17; % 12-070519-2, v1
% tpid = [2841 2873 2880 2874 2856; 2568 2521 1142 2560 2601] + 17; % 12-070519-2, v2

% figure
plotTongueTraj(phase,tpid,session,0,1);

%% Swallowing marker trajectories
% --------------------- Laryngeal complex trajectory ---------------------
%{
figure
subplot(4,1,1)
title('time vs x');
% plotBouts('swallowbout',swallowbout,floor,ceiling);
hold on 
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,10));
hold on
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,13)-5.2);

subplot(4,1,2)
title('time vs y');
% plotBouts('swallowbout',swallowbout,floor,ceiling);
hold on
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,11));
hold on
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,14));

subplot(4,1,3)
title('combined laryngeal');
% plotBouts('swallowbout',swallowbout,floor,ceiling);
hold on
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,10));
hold on 
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,11));

subplot(4,1,4)
title('combined jaw');
% plotBouts('swallowbout',swallowbout,floor,ceiling);
hold on
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,13));
hold on 
plot(frame2time(loc(floor:ceiling,1),camdata),loc(floor:ceiling,14));
%}

% --------------- Laryngeal + tongue trajectory ---------------------
%{
figure
plotBouts('swallowbout',swallowbout,floor,ceiling);
hold on
drawx = 1;
% plot(loc(floor:ceiling,1),loc(floor:ceiling,10),'DisplayName','Laryngeal x');
hold on 
plot(loc(floor:ceiling,1),loc(floor:ceiling,11),'DisplayName','Laryngeal y');
hold on 
% plot(loc(floor:ceiling,1),loc(floor:ceiling,6),'DisplayName','Tongue x');
hold on 
% plot(loc(floor:ceiling,1),loc(floor:ceiling,7),'DisplayName','Tongue y');
hold on
% plot(loc(floor:ceiling,1),loc(floor:ceiling,13),'DisplayName','Jaw x');
hold on
% plot(loc(floor:ceiling,1),loc(floor:ceiling,14),'DisplayName','Jaw y');
hold on 
plotConditionalTraj('tp',loc(:,1),loc(:,11),tp,floor,ceiling);
%}

%% Plot marker trajectory (video)
%{
traj = figure('Name','Trajectory');
ljt = animatedline('Color', 'b');           % lowerJaw trajectory
spt = animatedline('Color', 'g');           % spout trajectory
twt = animatedline('Color', '#EDB120');     % trident whisker trajectory
ttt = animatedline('Color', 'r');           % tongueTip trajectory
yflip = 650;

vid_path = strcat('Videos/',session,'/','trajactories.avi');
myVideo = VideoWriter(vid_path,'Uncompressed AVI');
open(myVideo);

for cur = 1:size(subloc,1)
    hold on
    if subloc(cur,4) >= 0.95
        % addpoints(ljt, subloc(cur,2), yflip+(yflip-subloc(cur,3)));
        addpoints(ljt, subloc(cur,2), subloc(cur,3));
    end
    if subloc(cur,7) >= 0.95
        % addpoints(spt, subloc(cur,5), yflip+(yflip-subloc(cur,6)));
        addpoints(spt, subloc(cur,5), subloc(cur,6));
    end
    if subloc(cur,10) >= 0.95
        % addpoints(twt, subloc(cur,8), yflip+(yflip-subloc(cur,9)));
        addpoints(twt, subloc(cur,8), subloc(cur,9));
    end
    if subloc(cur,13) >= 0.95
        % addpoints(ttt, subloc(cur,11), yflip+(yflip-subloc(cur,12)));
        addpoints(ttt, subloc(cur,11), subloc(cur,12));
    end
    xlim([0, vidWidth]);
    ylim([0,vidHeight]);
    drawnow
    F(cur) = getframe;
end
writeVideo(myVideo, F);
movie(F,1);
close(myVideo);

disp('----------------------');
%}

%% Subclassify tp data
%{
ilmCount = nnz(tp(:,17));
noilmCount = size(tp,1) - ilmCount;
scCount = nnz(tp(:,2));
nscCount = size(tp,1) - scCount;
nsctoscCount = 0;
disp(strcat('ILM/all=',num2str(ilmCount/size(tp,1))));

% ILM licks <-> first/last lick of the lickbout
bsandilm = 0;       % First lick of the lickbout <-> ILM licks
bethenilm = 0;      % Last lick of the lickbout --> ILM licks?
beandnoilm = 0;
for i = 1:size(lickbout,1)
    if tp(lickbout(i,4),17) ~= 0
        bsandilm = bsandilm + 1;
    end
    
    if lickbout(i,5)+1 < size(tp,1) 
        if tp(lickbout(i,5)+1,17) ~= 0
            bethenilm = bethenilm + 1;
        end
    end
    
    if tp(lickbout(i,5),17) == 0
        beandnoilm = beandnoilm + 1;
    end
end
disp('-------');
disp(strcat('ILM/lickboutStart=',num2str(bsandilm/size(lickbout,1))));
disp(strcat('lickboutStart/ILM=',num2str(bsandilm/ilmCount)));
disp(strcat('lickboutEnd+1/ILM=',num2str(bethenilm/ilmCount)));
disp(strcat('ILM/lickboutEnd+1=',num2str(bethenilm/(size(lickbout,1)-1))));
disp(strcat('noILM/lickboutEnd=',num2str(beandnoilm/(size(lickbout,1)))));
disp(strcat('lickboutEnd/noILM=',num2str(beandnoilm/noilmCount)));

% ILM licks <-> isLick=0
nscandilm = 0;
nscthenilm = 0;
scthennoilm = 0;
nsctosctonoilm = 0;
for i = 1:size(tp,1)
   if tp(i,2) == 0
       if tp(i,17) ~= 0
           nscandilm = nscandilm + 1;
       end
       if i+1 < size(tp,1)
           if tp(i+1,17) ~= 0
               nscthenilm = nscthenilm + 1;
           end
       end
   else
       if i+1 < size(tp,1)
           if tp(i+1,17) == 0
               scthennoilm = scthennoilm + 1;
           end
       end
       if i+1 < size(tp,1) && i-1 > 0
           if tp(i-1,2) == 0
               nsctoscCount = nsctoscCount + 1;
               if tp(i+1,17) == 0
                   nsctosctonoilm = nsctosctonoilm + 1;
               end
           end
       end
   end
end
disp('-------');
disp(strcat('noSC/ILM=',num2str(nscandilm/nscCount)));
disp(strcat('noSC+1/ILM=',num2str(nscthenilm/nscCount)));
disp(strcat('SC+1/noILM=',num2str(scthennoilm/noilmCount)));
disp(strcat('noSC->SC->noILM/noSC->SC=',num2str(nsctosctonoilm/nsctoscCount)));
disp(strcat('ILM/noSC+1=',num2str(nscthenilm/nscCount)));
disp(strcat('noILM/SC+1=',num2str(scthennoilm/scCount)));

disp('----------------------');
%}

%% ILI per licking bout
bid = 3;
floor = lickbout(bid,6);
ceiling = lickbout(bid,7);
pks = find(pswallow(:,2) >= floor & pswallow(:,2) <= ceiling);
lici = find(longici(:,3) >= floor & longici(:,4) <= ceiling);

figure
for i = 1:size(lici) 
    xline(longici(lici(i),3),'-r');
    hold on
    xline(longici(lici(i),4),'-r'); 
end
hold on
plotBouts('swallowbout',swallowbout,floor,ceiling);
hold on
plot(loc(floor:ceiling,1),ylaryvsjaw(floor:ceiling),'DisplayName','Laryngeal y corrected');
hold on
plot(pswallow(pks,2),pswallow(pks,3),'or');
hold on
plotConditionalTraj('tp',loc(:,1),ylaryvsjaw,tp,floor,ceiling);

% figure
% plotILI(bid,lickbout,tp,'frame');

disp('----------------------');
%% DFT swallowing bout analysis
%{
% t = 0:0.006:10-0.0006; % Time vector
% x = sin(2*pi*15*t) + sin(2*pi*40*t);      % Signal

xaxis = loc(swallowbout(1,1):swallowbout(1,2),10);
yaxis = loc(swallowbout(1,1):swallowbout(1,2),11);
x = fft(xaxis);
y = fft(yaxis);

% x axis 
magnitude = abs(x);            
x(magnitude < 1e-6) = 0;
phase = unwrap(angle(x));
f = (0:length(x)-1)/(length(x) * 0.006); % Frequency vector

figure
subplot(3,1,1)
plot(xaxis)
title('Trace x')
subplot(3,1,2)
plot(f(2:length(x)/2),magnitude(2:length(x)/2));
title('Magnitude x')
subplot(3,1,3)
plot(f,phase*180/pi)
title('Phase x')

% y axis
magnitude = abs(y);            
y(magnitude < 1e-6) = 0;
phase = unwrap(angle(y));
f = (0:length(y)-1)/(length(y) * 0.006); % Frequency vector

figure
subplot(3,1,1)
plot(yaxis)
title('Trace y')
subplot(3,1,2)
plot(f(2:length(y)/2),magnitude(2:length(y)/2));
title('Magnitude y')
subplot(3,1,3)
plot(f,phase*180/pi)
title('Phase y')
%}

disp('----------------------');

%% Marker 3D trajectory along time
threshold = [10 90];
% jaw
xjaw = loc(floor:ceiling,13); 
yjaw = loc(floor:ceiling,14);
xjawol = isoutlier(xjaw,'percentiles',threshold); 
yjawol = isoutlier(yjaw,'percentiles',threshold);
figure
for i = 1:size(xjaw,1)
    hold on
    if xjawol(i) == 1 && yjawol(i) == 0
        scatter(xjaw(i),yjaw(i),'oc');
    elseif yjawol(i) == 1 && xjawol(i) == 0
        scatter(xjaw(i),yjaw(i),'og');
    elseif yjawol(i) == 1 && xjawol(i) == 1
        scatter(xjaw(i),yjaw(i),'ob');
    else
        scatter(xjaw(i),yjaw(i),'or');
    end
end
% scatter(loc(floor:ceiling,13),loc(floor:ceiling,14));

% laryngeal
xlary = loc(floor:ceiling,10); 
ylary = loc(floor:ceiling,11);
xlaryol = isoutlier(xlary,'percentiles',threshold); 
ylaryol = isoutlier(ylary,'percentiles',threshold);
figure
for i = 1:size(xlary,1)
    hold on
    if xlaryol(i) == 1 && ylaryol(i) == 0
        scatter(xlary(i),ylary(i),'oc');
    elseif ylaryol(i) == 1 && xlaryol(i) == 0
        scatter(xlary(i),ylary(i),'og');
    elseif ylaryol(i) == 1 && xlaryol(i) == 1
        scatter(xlary(i),ylary(i),'ob');
    else
        scatter(xlary(i),ylary(i),'or');
    end
end
% scatter(loc(floor:ceiling,10),loc(floor:ceiling,11));

%% Test
total2 = [];
sid(1:size(tp,1),1) = 2;
total = [total1; sid tp(:,[1 5 6:11 15:20])];

%% Session notes
%{
"11-062419-1"
"11-062819-1"
"12-070519-2"
"13-090919-1"
"14-091519-1"
"18-102119-1"
"18-102519-1"
"18-102519-2"
"19-111119-1"
%}

%% Lick vs no lick
% barplot = [];

% dlc = nnz(tp(:,2));
% nolick = size(tp,1) - lick;
% lickometer = size(camdata.licking,1);
% barplot = [barplot; dlc nolick lickometer];
% session = [1 2 3 4 5];

% Lickometer vs dlc bar plots
%{
figure
bar(session,barplot);
xlabel('Session number');
ylabel('Number of licks detected');
legend('VIALS-detected licks', 'Lickometer-detected licks')
%}

% lick vs no lick pie plots
X = categorical({'Midline','Left-biased'});
X = reordercats(X,{'Midline','Left-biased'});
Y = [4.5 9.6];
barh(X,Y)
xlabel('Percentage of spout-missed licks');

%% Delay of skin signal

es = emgswallow([1:7 9:32 35:36 38 41:52 54:58],:);
estime = es(:,2);
pstime = pswallow([1:31 33:41 43:53],2);
delay = mean(pstime - estime);

%% Remove outlier demonstration
camdata = load(strcat('Videos/',session,'/times.mat'));

% Apply analysis window (in seconds)
% duration = stop - start;
if ~(start == 0 && stop >= 9999)
    % Apply time frame to loc
    wholeloc = readmatrix(strcat('Videos/',session,'/','loc.csv'));
    [~,startframe] = min(abs(camdata.times(:,2)-start));
    [~,stopframe] = min(abs(camdata.times(:,2)-stop));
    loc = wholeloc(startframe:stopframe,:);
else
    loc = readmatrix(strcat('Videos/',session,'/','loc.csv'));
end
disp('loc.csv loaded');

    
% Remove laryngeal and jaw outliers
if size(loc,2) > 9
    for i = [10 11 13 14]
        % Skip if the column is all NaN (18-102119-1)
        if ~isnan(loc(:,i))
            loc = removeOutliers(loc,i);
        end
    end
end
disp('Outliers removed');

%% Test
floor = time2frame(55,camdata);
ceiling = floor + 1000;
time = frame2time(floor:ceiling,camdata);

figure
subplot(2,1,1)
plot(frame2time(loc(:,1),camdata),ylaryvsjaw);
hold on
plot(pswallow(:,2),pswallow(:,3),'or');
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),ylaryvsjaw,tp);
xlim([time(1) time(length(time))]);

figure
subplot(2,1,1)
plot(frame2time(loc(:,1),camdata),loc(:,11));   % ylary
xlabel('Time (s)')
ylabel('Larynx marker height (a.u.)')
xlim([time(1) time(length(time))]);
subplot(2,1,2)
plot(frame2time(loc(:,1),camdata),loc(:,14));   % yjaw
xlabel('Time (s)')
ylabel('Jaw marker height (a.u.)')
xlim([time(1) time(length(time))]);