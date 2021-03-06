%% Load data
disp('----- Load loc and EMG data -----');

sessions = ["11-062019-1"; "11-062119-1"; "11-062219-1"; "11-062419-1"; "11-062819-1";...
    "12-070519-2"; "13-090419-1"; "13-090919-1"; "14-091519-1"; "18-102119-1";...
    "18-102519-1"; "18-102519-2"; "19-111119-1"; "20-200115-2"; "20-200117-1";...
    "20-200121-1"; "20-200121-2"; "20-200121-3"; "21-012720-1"; "21-013020-1"];
swallow3303 = ["22-0228-1"; "22-0301-1"; "23-0305-1"];
swallowemg = ["19-111119-1"; "23-0314-1"; "23-0314-2"; "23-0315-1"];

session = swallow3303(3);
disp(session);

% Enter analysis window (in seconds)
start = 0;
stop = Inf;

% Enter bandpass frequency
% Based on Lever et al. (2009) 

% https://link.springer.com/article/10.1007/s00455-009-9232-1
% bplow = 100;
% bphigh = 3000;

% Load single session data
[camdata,loc] = loadLocData(session,start,stop);
[tp,tpbout,lickbout,skinbout] = loadLocAnalysis(session,loc,camdata,0);
emg = loadEMG(start,stop,camdata);
breathing = loadBreathing(start,stop,camdata);

% Reset tp.csv for multiple sessions
% for i = 1:size(sessions,1)
%     [camdata,loc] = loadLocData(sessions(i),start,stop);
%     [tp,tpbout,lickbout,swallowbout] = loadLocAnalysis(sessions(i),loc,camdata,1);
%     % [emg,emgenv] = loadEMG(bplow,bphigh,start,stop,camdata);
% end

% Swallowing identification
disp('----- Swallowing identification -----');

hdiff = loc(:,11) - loc(:,14); % Marker height diff = Laryngeal - jaw
inspiration = find(breathing.trace > 0);
expiration = find(breathing.trace <= 0);

% Accelaration of vertical jaw and hdiff
velyjaw = [0; calcDerivative(frame2time(loc(:,1),camdata),loc(:,14))];
accyjaw = [0; calcDerivative(frame2time(loc(:,1),camdata),velyjaw)];
velhdiff = [0; calcDerivative(frame2time(loc(:,1),camdata),hdiff)];
acchdiff = [0; calcDerivative(frame2time(loc(:,1),camdata),velhdiff)];

% Find putative swallow
% pswallow = [];
[pswallow,inthres,allpeaks] = defineSwallows(loc,tp,camdata);
% save('allpeaks'); disp('allpeaks saved');

% Further filtering of putative swallow
% 2. if laryngeal does not move

% Find extended ILIs (longer than 20ms)
% longici = findExtendedICI(tp,0.02);
% disp('Extended ICI found');

% Validate pswallow using EMG data
% emgswallow = [];
emgswallow = validateSwallow(emg,loc,tp,camdata);
% disp('EMG swallow found');

%% Raster plot
disp('----- Raster plot of event summary -----');

% Raster plot
% tp(any(isnan(tp(:,3)),2),:) = [];
[rp,aligned] = plotRaster(tp,pswallow,emgswallow,camdata);
% colormap(jet); colorbar
rp_path = strcat('Videos/',session,'/','rp.svg');
legend

%% Swallowing + breathing
% Input time
% rewardid = 1; rdiff = -1;
% t = camdata.reward(rewardid,1) + rdiff - 1;
t = 133;
floor = time2frame(t,camdata);
ceiling = min(floor + 1000, size(loc,1));
time = frame2time(floor:ceiling,camdata);

% hdiff
% pks = find(pswallow(:,2) >= time(1) & pswallow(:,2) <= time(size(time,1)));
sliswallow = find(allpeaks.sli(:,1) >= 0);
pks = find(allpeaks.locs(sliswallow) >= floor & allpeaks.locs(sliswallow) <= ceiling);
% lici = find(longici(:,3) >= floor & longici(:,4) <= ceiling);

figure
subplot(3,1,1)
yyaxis left
% for i = 1:size(lici) 
%     xline(frame2time(longici(lici(i),3),camdata),'-b');
%     hold on
%     xline(frame2time(longici(lici(i),4),camdata),'-b'); 
% end 
hold on
% plotBouts('swallowbout',skinbout,floor,ceiling,camdata);
hold on
plot(frame2time(loc(:,1),camdata),hdiff,'LineWidth',1);
hold on
scatter(frame2time(allpeaks.locs(sliswallow),camdata),allpeaks.pks(sliswallow),...
    36,allpeaks.sli(sliswallow,1),'o','LineWidth',2);
% scatter(frame2time(allpeaks.locs,camdata),allpeaks.pks,36,...
%     allpeaks.sli(:,1),'o','LineWidth',1);
% scatter(frame2time(allpeaks.locs(sliswallow),camdata),allpeaks.pks(sliswallow),'or','LineWidth',1);
colormap(flipud(hot)); colorbar
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),hdiff,tp);
ylim([-70 10]);
ylabel('Marker height difference (a.u.)')

yyaxis right
plot(breathing.raw(:,1),breathing.trace);
hold on 
yline(0,'--','Color','#B85741');
ylabel('Breathing (a.u.)')
xlabel('Time (s)')
xlim([time(1) time(length(time))]);

% subplot(4,1,2)
% plot(breathing.raw(inspiration,1),breathing.trace(inspiration),'Color','#B85741');
% hold on
% plot(breathing.raw(expiration,1),breathing.trace(expiration),'Color','#274E13');
% hold on
% for i = 1:size(pks,1)
%     xline(frame2time(allpeaks.locs(sliswallow(pks(i))),camdata),'-r');
% end
% ylabel('Breathing (a.u.)')
% xlim([time(1) time(length(time))]);

subplot(3,1,2)
plot(breathing.raw(:,1),breathing.phase);
hold on
for i = 1:size(pks,1)
    xline(frame2time(allpeaks.locs(sliswallow(pks(i))),camdata),'-r');
end
% scatter(breathing.raw(breathing.count,1),breathing.phase(breathing.count),'or');
ylabel('Breathing phase')
xlim([time(1) time(length(time))]);

subplot(3,1,3)
plot(breathing.raw(:,1),breathing.frequency);
hold on
for i = 1:size(pks,1)
    xline(frame2time(allpeaks.locs(sliswallow(pks(i))),camdata),'-r');
end
ylabel('Breathing frequency (Hz)')
xlim([time(1) time(length(time))]);

%% Swallowing + EMG
% Input time
% rewardid = 1; rdiff = -1;
% t = camdata.reward(rewardid,1) + rdiff - 1;
t = 110;
floor = time2frame(t,camdata);
ceiling = min(floor + 1000, size(loc,1));
time = frame2time(floor:ceiling,camdata);

% hdiff
pks = find(pswallow(:,2) >= time(1) & pswallow(:,2) <= time(size(time,1)));
% lici = find(longici(:,3) >= floor & longici(:,4) <= ceiling);

figure
subplot(2,1,1)
hold on
plot(frame2time(loc(:,1),camdata),hdiff);
hold on
scatter(frame2time(allpeaks.locs,camdata),allpeaks.pks,36,...
    allpeaks.sli(:,1),'o','LineWidth',1);
colormap(jet); colorbar;
scatter(pswallow(:,2),pswallow(:,3),36,'or','LineWidth',1);
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),hdiff,tp);
xlabel('Time (s)')
ylabel('Marker height difference (a.u.)')
xlim([time(1) time(length(time))]);

% hdiff + EMG
% Find peaks of EMG envelope
[envpeaks,envplocs] = findpeaks(emg.env,'MinPeakDistance',4000,'MinPeakProminence',20);
subplot(2,1,2)
% yyaxis left
% yyaxis right
% plot(emg.time,camdata.emg); ylim([0 max(camdata.emg)]);
plot(emg.time,emg.trace,'Color','#4DBEEE');
hold on
plot(emg.time,emg.env,'LineWidth',1);
% for i = 1:size(pks,1)
%     xline(pswallow(pks(i),2),'-r');
% end
hold on
%{
for i = 1:size(lici) 
    xline(frame2time(longici(lici(i),3),camdata),'-b');
    hold on
    xline(frame2time(longici(lici(i),4),camdata),'-b'); 
end
hold on
% for i = 1:size(camdata.reward,1)
%     xline(camdata.reward(i),'-k');
% end
hold on
% plotConditionalTraj('emg',frame2time(loc(:,1),camdata),emgenv,tp);
hold on
%}
plot(emg.time(envplocs),envpeaks,'oc');
hold on
% plot(emg.time(emgswallow(:,3)),emgswallow(:,4),'ob');
xlabel('Time (s)')
ylabel('EMG amplitude (a.u.)')
xlim([time(1) time(length(time))]); ylim([-max(emg.env) max(emg.env)]);

%% Breathing and swallowing
swins = 0;
% psb = [];
% for i = 1:size(pswallow,1)
%     [~,index] = findClosest(breathing.raw(:,1),pswallow(i,2));
%     % if swallow happens during in inspiration (dbreathing < -500)
%     if breathing.d(index) <= -500
%         swins = swins + 1;
%     end
%     psb = [psb; pswallow(i,1) pswallow(i,2),...
%         breathing.trace(index) breathing.phase(index) breathing.d(index)];
% end

slib20 = [];
sliswallow = find(allpeaks.sli(:,1) >= 10);
for i = 1:size(sliswallow,1)
    [~,index] = findClosest(breathing.raw(:,1),frame2time(allpeaks.locs(sliswallow(i)),camdata));
    % if swallow happens during in inspiration (dbreathing < -500)
    if breathing.d(index) <= -500
        swins = swins + 1;
    end
    slib20 = [slib20; sliswallow(i),frame2time(allpeaks.locs(sliswallow(i)),camdata),...
        breathing.trace(index) breathing.phase(index) breathing.d(index)];
end

totalslib20 = [slib14;slib15;slib16];
totalslib21 = [slib19;slib20];
totalslib = [totalslib20;totalslib21];

figure
% p = polarscatter(slib(:,4)+pi,abs(allpeaks.pks(sliswallow)),36,allpeaks.sli(sliswallow));
% p = polarscatter(psb(:,4),abs(allpeaks.pks(pswallow(:,1))));
% colormap(flipud(hot)); colorbar; rlim([0 20]);

p = polarhistogram(totalslib(:,4)+pi,30);
% p.DisplayStyle = 'stairs'; 
% hold on
% a1 = polarhistogram(totalslib20(:,4)+pi,30);
% a1.DisplayStyle = 'stairs'; 
% hold on
% a2 = polarhistogram(totalslib21(:,4)+pi,30);
% a2.DisplayStyle = 'stairs'; 
% p = polarhistogram(psb(:,4)+pi,30);
p.DisplayStyle = 'stairs'; 

p = gca; 
p.ThetaAxisUnits = 'radians'; 
p.ThetaTick = [0 0.5*pi pi 1.5*pi];
p.ThetaTickLabel = {'0 / 2\pi','0.5\pi','\pi','1.5\pi'};

figure
histogram(totalslib(:,4)+pi,30);
xlim([0 2*pi]);

xlabel('Phase')

%% Breathing rate during baseline vs drinking
drinkbf = [];
restbf = [];
for i = 1:size(skinbout,1)
    [~,bstartindex] = findClosest(breathing.raw(:,1),frame2time(skinbout(i,1),camdata));
    [~,bendindex] = findClosest(breathing.raw(:,1),frame2time(skinbout(i,2),camdata));
    drinkbf = [drinkbf; mean(breathing.frequency(bstartindex:bendindex))];
    
    if i - 1 > 0
        [~,rstartindex] = findClosest(breathing.raw(:,1),frame2time(skinbout(i-1,2),camdata));
        rendindex = bstartindex -1;
        
        restbf = [restbf; mean(breathing.frequency(rstartindex:rendindex))];
    end
end

prepostbf14 = [];
for i = 2:size(restbf,1)
    prepostbf14 = [prepostbf14; restbf(i-1) drinkbf(i) restbf(i)];
end

%%
total = [prepostbf14;prepostbf16;prepostbf19;prepostbf20];
[p,tbl,stats] = anova1(total);

figure
y = [nanmean((nanmean(total(:,1))+nanmean(total(:,3)))/2) nanmean(total(:,2)); ...
    nanmean(total(:,1)) nanmean(total(:,2)); ...
    nanmean(total(:,3)) nanmean(total(:,2))];
bar(y);


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
    percentage = [percentage; thres, numerator/size(pswallow,1)];
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
[b,total,pcadata,kmdata] = tpClustering(left,version,dimension);

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
plot(loc(floor:ceiling,1),hdiff(floor:ceiling),'DisplayName','Laryngeal y corrected');
hold on
plot(pswallow(pks,2),pswallow(pks,3),'or');
hold on
plotConditionalTraj('tp',loc(:,1),hdiff,tp,floor,ceiling);

% figure
% plotILI(bid,lickbout,tp,'frame');

disp('----------------------');

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

%% Trace

floor = time2frame(30,camdata);
ceiling = floor + 1000;
time = frame2time(floor:ceiling,camdata);
pks = find(pswallow(:,2) >= time(1) & pswallow(:,2) <= time(size(time,1)));

figure
subplot(4,2,[1 2])
plot(frame2time(loc(:,1),camdata),hdiff);
hold on
scatter(frame2time(allpeaks.locs,camdata),allpeaks.pks,36,...
    allpeaks.sli(:,1),'o','LineWidth',1);
colormap(jet); colorbar;
% scatter(pswallow(:,2),pswallow(:,3),36,'or','LineWidth',1);
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),hdiff,tp);
xlim([time(1) time(length(time))]);
xlabel('Time (s)')
ylabel('Marker height difference (a.u.)')

% figure
subplot(4,2,3)
plot(frame2time(loc(:,1),camdata),loc(:,11));   % ylary
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),loc(:,11),tp);
hold on
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
xlabel('Time (s)')
ylabel('Larynx marker height (a.u.)')
xlim([time(1) time(length(time))]);

subplot(4,2,4)
plot(frame2time(loc(:,1),camdata),loc(:,14));   % yjaw
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),loc(:,14),tp);
hold on
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
xlabel('Time (s)')
ylabel('Jaw marker height (a.u.)')
xlim([time(1) time(length(time))]);

subplot(4,2,5)
plot(frame2time(loc(:,1),camdata),loc(:,10)); % xlary
hold on
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
xlabel('Time (s)')
ylabel('xLary (a.u.)')
xlim([time(1) time(length(time))]);

subplot(4,2,6)
plot(frame2time(loc(:,1),camdata),loc(:,13)); % xjaw
hold on
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
xlabel('Time (s)')
ylabel('xjaw (a.u.)')
xlim([time(1) time(length(time))]);

% subplot(4,2,5)
% plot(frame2time(loc(:,1),camdata),smoothdata(velhdiff));   % velhdiff
% hold on
% for i = 1:size(pks,1)
%     xline(pswallow(pks(i),2),'-r');
% end
% xlabel('Time (s)')
% ylabel('Velocity of hdiff (a.u.)')
% xlim([time(1) time(length(time))]);
% 
% subplot(4,2,6)
% plot(frame2time(loc(:,1),camdata),smoothdata(velyjaw));   % velyjaw
% hold on
% for i = 1:size(pks,1)
%     xline(pswallow(pks(i),2),'-r');
% end
% xlabel('Time (s)')
% ylabel('Velocity of yjaw (a.u.)')
% xlim([time(1) time(length(time))]);

subplot(4,2,7)
plot(frame2time(loc(:,1),camdata),smoothdata(acchdiff));   % acchdiff
hold on
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
xlabel('Time (s)')
ylabel('Accelaration of hdiff (a.u.)')
xlim([time(1) time(length(time))]);

subplot(4,2,8)
plot(frame2time(loc(:,1),camdata),smoothdata(accyjaw));   % accyjaw
hold on
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
xlabel('Time (s)')
ylabel('Accelaration of yjaw (a.u.)')
xlim([time(1) time(length(time))]);

%% pswallow distribution

[pswallow,inthres,allpeaks] = defineSwallows(loc,tp,camdata);

figure
for i = 1:size(allpeaks.sli)
    hold on
    if allpeaks.sli(i,2) == 0
        scatter(allpeaks.sli(i,1),allpeaks.locs(i),'ok');
    elseif allpeaks.sli(i,2) == 1
        scatter(allpeaks.sli(i,1),allpeaks.locs(i),'ob');
    else
        scatter(allpeaks.sli(i,1),allpeaks.locs(i),'or');
    end
end
xlabel('Swallow likelihood index');

figure
for i = 1:size(allpeaks.sli)
    hold on
    if allpeaks.sli(i,2) == 0
        scatter(allpeaks.sli(i,1),loc(allpeaks.locs(i),11),'ok');
    elseif allpeaks.sli(i,2) == 1
        scatter(allpeaks.sli(i,1),loc(allpeaks.locs(i),11),'ob');
    else
        scatter(allpeaks.sli(i,1),loc(allpeaks.locs(i),11),'or');
    end
end
xlabel('Swallow likelihood index');
ylabel('Height of larynx marker (a.u.)');

figure
for i = 1:size(allpeaks.sli)
    hold on
    if allpeaks.sli(i,2) == 0
        scatter(allpeaks.sli(i,1),loc(allpeaks.locs(i),14),'ok');
    elseif allpeaks.sli(i,2) == 1
        scatter(allpeaks.sli(i,1),loc(allpeaks.locs(i),14),'ob');
    else
        scatter(allpeaks.sli(i,1),loc(allpeaks.locs(i),14),'or');
    end
end
xlabel('Swallow likelihood index');
ylabel('Height of jaw marker (a.u.)');

figure
for i = 1:size(allpeaks.sli)
    hold on
    if allpeaks.sli(i,2) == 0
        scatter(allpeaks.sli(i,1),hdiff(allpeaks.locs(i)),'ok');
    elseif allpeaks.sli(i,2) == 1
        scatter(allpeaks.sli(i,1),hdiff(allpeaks.locs(i)),'ob');
    else
        scatter(allpeaks.sli(i,1),hdiff(allpeaks.locs(i)),'or');
    end
end
xlabel('Swallow likelihood index');
ylabel('Marker height difference (a.u.)');

%% Test
t = 0;
floor = time2frame(t,camdata);
ceiling = min(floor + 1000, size(loc,1));
time = frame2time(floor:ceiling,camdata);

figure
subplot(2,1,1)
plot(frame2time(loc(:,1),camdata),hdiff);
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),hdiff,tp);
hold on
% scatter(frame2time(allpeaks.locs,camdata),allpeaks.pks,36,...
%     allpeaks.sli(:,1),'o','LineWidth',1);
% colormap(jet); colorbar;
scatter(pswallow(:,2),pswallow(:,3),36,'or','LineWidth',1);
xlabel('Time (s)')
ylabel('Larynx marker height (a.u.)')
xlim([time(1) time(length(time))]);

subplot(2,1,2)
plot(frame2time(loc(:,1),camdata),hdiff);
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),hdiff,tp);
hold on
scatter(frame2time(allpeaks.locs,camdata),allpeaks.pks,36,...
    allpeaks.sli(:,1),'o','LineWidth',1);
colormap(jet); colorbar;
% scatter(pswallow(:,2),pswallow(:,3),36,'or','LineWidth',1);
xlabel('Time (s)')
ylabel('Larynx marker height (a.u.)')
xlim([time(1) time(length(time))]);

% subplot(2,1,2)
% plot(frame2time(loc(:,1),camdata),loc(:,14));
% hold on
% plotConditionalTraj('traj',frame2time(loc(:,1),camdata),loc(:,14),tp);
% hold on
% % scatter(frame2time(allpeaks.locs,camdata),loc(allpeaks.locs,14),36,...
% %     allpeaks.sli(:,1),'o','LineWidth',1);
% % colormap(jet); colorbar;
% scatter(pswallow(:,2),loc(time2frame(pswallow(:,2),camdata),14),36,'or','LineWidth',1);
% % yline(inthres);
% xlabel('Time (s)')
% ylabel('Larynx marker height (a.u.)')
% xlim([time(1) time(length(time))]);

%% Make movie
close all
N = 550;    % Number of frames
floor = time2frame(0.5,camdata); ceiling = floor + N;

time = frame2time(floor:ceiling,camdata);
alltime = frame2time(loc(:,1),camdata);
pks = find(pswallow(:,2) >= time(1) & pswallow(:,2) <= time(size(time,1)));
a1 = animatedline('Color','#0072BD');
a2 = animatedline('Color','k');

for i = floor:ceiling
    addpoints(a1,frame2time(loc(i,1),camdata),hdiff(i));
%     addpoints(a2,alltime(tp(i,35):tp(i,36)),hdiff(tp(i,35):tp(i,36)));
    drawnow
    
    xlabel('Time (s)')
    ylabel('Larynx marker height (a.u.)')
    xlim([time(1) time(length(time))]); ylim([-30 30]);

    % Store the frame
    M(i) = getframe(gcf); % leaving gcf out crops the frame in the movie
end
% movie(M);

%% Remove outlier test
yyaxis left
% for i = 1:size(lici) 
%     xline(frame2time(longici(lici(i),3),camdata),'-b');
%     hold on
%     xline(frame2time(longici(lici(i),4),camdata),'-b'); 
% end 
hold on
% plotBouts('swallowbout',skinbout,floor,ceiling,camdata);
hold on
plot(frame2time(loc(:,1),camdata),hdiff,'LineWidth',1);
hold on
% scatter(frame2time(allpeaks.locs(sliswallow),camdata),allpeaks.pks(sliswallow),...
%     36,allpeaks.sli(sliswallow,1),'o','LineWidth',1);
% scatter(frame2time(allpeaks.locs,camdata),allpeaks.pks,36,...
%     allpeaks.sli(:,1),'o','LineWidth',1);
scatter(frame2time(allpeaks.locs(sliswallow),camdata),allpeaks.pks(sliswallow),'or','LineWidth',1);
% colormap(flipud(hot)); % colorbar
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),hdiff,tp);
ylabel('Marker height difference (a.u.)')

yyaxis right
plot(breathing.raw(:,1),breathing.trace);
ylabel('Breathing (a.u.)')
xlabel('Time (s)')
xlim([time(1) time(length(time))]);

