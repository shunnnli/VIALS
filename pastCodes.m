%% Breathing sesnor
session = "20-200117-1";
camdata = load(strcat('Videos/',session,'/times.mat'));
breathing = [transpose((1:size(camdata.breathing,1))/30000),double(camdata.breathing)/20];

% Apply filter
Sampling_rate = 30000;
setpt_cut = 1; % minimum frequency
lowpass_cut = 15; % maximum frequency 15 Hz (for rat and mouse)
filter_order = 3;
 
breath = breathing(:,2);
 
[bh ah] = butter(filter_order,setpt_cut/(Sampling_rate/2),"low"); % get set-point
setpt_b = filtfilt(bh,ah,breath);
[bl al] = butter(filter_order,lowpass_cut/(Sampling_rate/2),"low"); % lowpass
breath_f = filtfilt(bl,al,breath);
breath_fst = breath_f - setpt_b;
phase_b = angle(hilbert(breath_fst));

%% Draw traces
floor = time2frame(100,camdata);
ceiling = floor + 2000;
time = frame2time(floor:ceiling,camdata);

figure
subplot(2,1,1)
plot(breathing(:,1),breath_fst);
xlim([time(1) time(length(time))]);
subplot(2,1,2)
plot(breathing(:,1),phase_b);
xlim([time(1) time(length(time))]);

%% Displacement of a marker at a given moment from resting location
%{
% Laryngeal 
laryvsrest = [];
for i = 1:size(loc,1)
    xlary = loc(i,10);
    ylary = loc(i,11);
    for j = 1:size(swallowbout,1)
        xrestlary = xlary;
        yrestlary = ylary;
        if i >= swallowbout(j,1) || i <= swallowbout(j,2)
            xrestlary = swallowbout(j,3);
            yrestlary = swallowbout(j,4);
            break
        elseif i <= swallowbout(j,1) && i >= swallowbout(j-1,2)
            xrestlary = swallowbout(j,3);
            yrestlary = swallowbout(j,4);
            break
        end
    end
    laryvsrest = [laryvsrest; calcDistance([xlary,ylary],[xrestlary,yrestlary],1)];
end
disp('laryvsrest[] generated');
%}

%% Past codes: removeOutlier test
%{
remove outliers
xjaw = filloutliers(loc(:,13),'linear','movmedian',15);
yjaw = filloutliers(loc(:,14),'linear','movmedian',15);
xlary = filloutliers(loc(:,10),'linear','movmedian',15);
ylary = filloutliers(loc(:,11),'linear','movmedian',15);

dyjawol = [false(1);isoutlier(diff(yjaw),'gesd')];
% make ol == 1 if frames nearby are also outliers
for i = 1:size(dyjawol)
    if i ~= 1 && dyjawol(i-1) == 1 && dyjawol(i) == 0
        if sum(dyjawol(i:i+5)) > 0
            dyjawol(i) = true(1);
            for j = 1:5
                if dyjawol(i+j) ~= false(1)   
                    break
                else
                    dyjawol(i+j) = true(1);
                end
            end
        end
    else
        continue
    end
end
yjaw = filloutliers(yjaw,'linear','OutlierLocations',dyjawol);

figure
floor = 4400;
ceiling = floor + 100;
plot(loc(floor:ceiling,1),xjaw(floor:ceiling),'DisplayName','xjaw');
hold on 
plot(loc(floor:ceiling,1),loc(floor:ceiling,14),'DisplayName','yjaw');
hold on
plot(loc(floor:ceiling,1),dyjaw(floor:ceiling),'DisplayName','dyjaw');
hold on
plot(loc(floor:ceiling,1),dyjawol(floor:ceiling),'DisplayName','dyjawol');
legend

% figure
% plot(loc(floor:ceiling,1),xlary(floor:ceiling),'DisplayName','xlary');
% hold on 
% plot(loc(floor:ceiling,1),ylary(floor:ceiling),'DisplayName','ylary');
% legend
%}

%% Past codes: raster plot
%{
% Fix reward interval
iti = mean(diff(camdata.reward));   % Determine ITI
tpaligned = sortrows(alignTP(tp,camdata,iti),2);
psaligned = alignSwallow(pswallow,camdata,iti);
esaligned = alignSwallow(emgswallow,camdata,iti);
islick = find(tpaligned(:,2) > 0,1);

figure
xline(0,'-k','LineWidth',1);
hold on
if isempty(camdata.licking)
    scatter(tpaligned(:,5),tpaligned(:,4),'.b');
else
    scatter(tpaligned(1:islick,5),tpaligned(1:islick,4),'.c');   % not lick
end
hold on
scatter(tpaligned(islick+1:size(tpaligned,1),5),...
    tpaligned(islick+1:size(tpaligned,1),4),'.b');   % is lick
hold on
scatter(psaligned(:,3),psaligned(:,2),'or');
hold on
scatter(esaligned(:,3),esaligned(:,2),'ok');

xlim([-iti/2 iti/2]);
ylim([0 max(tpaligned(size(tpaligned,1),4),psaligned(size(psaligned,1),2))]);
%}

%% Past codes: Pre-analysis routine
%{
session = '13-090919-1';
camdata = load(strcat('Videos/',session,'/times.mat'));
wholeloc = readmatrix(strcat('Videos/',session,'/','loc.csv'));
% adc = [time adc_value]
wholeadc = [transpose((1:size(camdata.adc,1))/30000), double(camdata.adc)/20];
disp('loc.csv and adc loaded');

% Enter analysis window (in seconds)
start = 0;
stop = 120;
% duration = stop - start;
if ~(start == 0 && stop >= 9999)
    % Apply time frame to loc
    [~,startframe] = min(abs(camdata.times(:,2)-start));
    [~,stopframe] = min(abs(camdata.times(:,2)-stop));
    loc = wholeloc(startframe:stopframe,:);
    % Apply time frame to camdata.adc
    [~,startrow] = min(abs(wholeadc(:,1)-start));
    [~,stoprow] = min(abs(wholeadc(:,1)-stop));
    adc = wholeadc(startrow:stoprow,:);
end

% Set EMG and imaging parameters
% Based on Lever et al. (2009) 
% https://link.springer.com/article/10.1007/s00455-009-9232-1
fs = 30000;     % EMG sampling frequency
fps = 1/0.006;   % camera frame rate
[emg,emgenv] = processEMG(adc,fs,[100 3000]);

% Calculate derivatives of jaw and lary marker trajectory
dx = diff(loc(:,1));
dxlary = diff(loc(:,10));
dylary = diff(loc(:,11));    % y-axis
dxjaw = diff(loc(:,13));
dyjaw = diff(loc(:,14));     % y-axis
dlarydx = dylary./dx;
djawdx = dyjaw./dx;

% tongue protrusion event log
tp_path = strcat('Videos/',session,'/','tp.csv');
if isfile(tp_path)
    tp = readmatrix(tp_path);
    disp('tp.csv loaded');
else
    tp = defineLicks(loc,camdata,0.99);
    writematrix(tp, tp_path);
    disp('tp.csv created');
end

% tongue protrusion bout log
tpbout_path = strcat('Videos/',session,'/','tpbout.csv');
if isfile(tpbout_path)
    tpbout = readmatrix(tpbout_path);
    disp('tpbout.csv loaded');
else
    tpbout = defineTPBout(tp);
    writematrix(tpbout,tpbout_path);
    disp('tpbout.csv created');
end

% licking lickbout log
if ~isempty(camdata.licking)
    lickbout_path = strcat('Videos/',session,'/','lickbout.csv');
    if isfile(lickbout_path)
        lickbout = readmatrix(lickbout_path);
        disp('lickbout.csv loaded');
    else
        lickbout = defineLickBout(tp);
        writematrix(lickbout,lickbout_path);
        disp('lickbout.csv created');
    end
end

% swallowing bout log
windowsize = 25;
threshold = 0.25;
swallowbout_path = strcat('Videos/',session,'/','swallowbout.csv');
if isfile(swallowbout_path)
    swallowbout = readmatrix(swallowbout_path);
    disp('swallowbout.csv loaded');
else
    swallowbout = defineSwallowBout(loc,dlarydx,windowsize,threshold);
    writematrix(swallowbout,swallowbout_path);
    disp('swallowbout.csv created');
end

% Remove outliers
loc = cutOutliers(loc,0.99); % remove tongue outliers based on likelihood
for i = [10 11 13 14]
    loc = removeOutliers(loc,i);    % remove laryngeal and jaw outliers
end
disp('Outliers removed');

disp('----------------------');
%}

%% Past code: plot single tp trajectory
%{
tpid = 123;
spout = tp(tpid,(24:26));
        
% Separate different phases
protrusion = loc((tp(tpid,27):tp(tpid,28)),:);
ilm = loc((tp(tpid,29)-1:tp(tpid,30)+1),:);
retraction = loc((tp(tpid,31):tp(tpid,32)),:);

% Plot tongue trajectory
figure
plot3(spout(1),spout(2),spout(3),'o', 'DisplayName','Spout');
hold on
plot3(protrusion(:,6),protrusion(:,7),protrusion(:,8), ...
    'Color','#0072BD', 'DisplayName','Protrusion', 'LineWidth',2);
hold on
plot3(ilm(:,6),ilm(:,7),ilm(:,8),'Color','#D95319', ...
    'DisplayName','Interlick movement','LineWidth',2);
hold on
plot3(retraction(:,6),retraction(:,7),retraction(:,8),...
    'Color','#77AC30','DisplayName','Retraction','LineWidth',2);
grid on
axis vis3d equal
hold off
legend;

disp('----------------------');
%}