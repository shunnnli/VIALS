%% Pre analysis routine
session = '18-102119-1';
camdata = load(strcat('Videos/',session,'/times.mat'));
Fs = 1/0.006;
swallowcsv = 'DLC_resnet50_swallowing-trackingSep8shuffle1_900000.csv';
swallowraw = readmatrix(strcat('Videos/',session,'/side-',session,swallowcsv));
loc = [(swallowraw(:,1)+1),swallowraw(:,(2:end))];
% loc = cutOutliers(swallowloc,0.95);

dx = diff(loc(:,1));
dlary = diff(loc(:,3));
djaw = diff(loc(:,6));
dlarydx = dlary./dx;
djawdx = djaw./dx;

%% Define bout using derivatives
% bout start if sum of absolute value of next 20 derivatives > 10
bout = [];
bouton = 0;
boutstart = 0;
boutend = 0;
windowsize = 25;
threshold = 7;

for i = 1:size(dlarydx,1)
    if i + windowsize > size(dlarydx,1)
        if bouton == 1
            boutend = size(dlarydx,1);
            new_row = [boutstart boutend];
            bout = [bout;new_row];
        end
        break
    end
    [sum,~] = sumabs(dlarydx(i:i+windowsize));
    diff = abs(loc(i,3)-loc(i+windowsize,3));
    if sum > threshold && bouton == 0 && diff > 10
        bouton = 1; 
        boutstart = i;
        boutend = i + windowsize;
    elseif sum > threshold && bouton == 1
        if i+windowsize > boutend
            boutend = i + windowsize;
        end
    elseif sum < threshold && bouton == 1
        bouton = 0;
        new_row = [boutstart boutend];
        bout = [bout;new_row];
    end
end

% bout = defineSwallowBout(loc,dlarydx,windowsize,threshold);

%% Hilbert transform bout analysis
x = loc(bout(1,1):bout(1,2),3);
Hlary = hilbert(x);

dt = 0.001; % sampling interval [s]
t = dt:dt:1; % time axis [s]
f1 = 2.0; % freq of sinusoid [Hz]
phi0 = 0.0; % initial phase of sinusoid
d = sin(2.0*pi*t*f1 + phi0);
dA = hilbert(d);

phi = angle(Hlary); % Compute phase of analytic signal
amp = abs(Hlary);   % Compute amplitude envelope

figure; 
subplot(4,1,1) % 4x1 plot, 1st plot
plot(x); ylabel('Data');
subplot(4,1,2) % 4x1 plot, 2nd plot plot(real(dA));
hold on; plot(imag(Hlary), 'r');
hold off;
ylabel('Real (blue), Imag (red)'); axis tight

subplot(4,1,3); plot(phi); ylabel('Angle'); axis tight 
subplot(4,1,4); plot(amp); ylabel('Amplitude'); axis tight

%% Jeff Moore
% --------- Parameters ---------------------- %
x = loc(bout(1,1):bout(1,2),3);
Fs = 166;
setpt_cut = 1; % minimum frequency
lowpass_cut = 40; % maximum frequency 40 Hz (for rat and mouse)
filter_order = 3;

% apply filters
[bh,ah] = butter(filter_order,setpt_cut/(Fs/2),'low'); % get set-point
setpt = filtfilt(bh,ah,x);
[bl,al] = butter(filter_order,lowpass_cut/(Fs/2),'low'); % lowpass
xprocl = filtfilt(bl,al,x);

% compute amplitude
xproc = xprocl-setpt; % subtract setpoint
% amp_pp = fan_whiskutil_get_whiskamplitude_DH(xproc);

% compute instantaneous phase
phase = angle(hilbert(xproc));

% compute instantaneous frequency
time = 0:length(x)-1/Fs;
freq_dtime = 0.33;
intphase = unwrap(phase);
totaltime = length(x)/Fs;
freqtimes = 0:freq_dtime:totaltime;
intphase_resamp = interp1(time,intphase,freqtimes);
freq = diff(intphase_resamp)/freq_dtime/(2*pi);
freq_extrapolate = [freq(1), freq, freq(end)];
freqtimepts = freqtimes(1:end-1)+freq_dtime/2;
freqtimepts_extrapolate = [0, freqtimepts, totaltime];
frequency = interp1(freqtimepts_extrapolate,freq_extrapolate,time);

% plot
subplot(2,1,1)
hold on;
plot(time,x,'k',time,xprocl,'b',time,setpt,'r');
% plot(time,setpt+amp_pp'/2,'g',time,setpt-amp_pp'/2,'g');
ylabel('angle (deg)')
legend('raw','filtered','set-point','amplitude')
subplot(2,1,2)
plot(time,frequency);ylim([0 20])
xlabel('time (s)');ylabel('Frequency (Hz)');

%% DFT Bout analysis
% t = 0:0.006:10-0.0006; % Time vector
% x = sin(2*pi*15*t) + sin(2*pi*40*t);      % Signal

xaxis = loc(bout(1,1):bout(1,2),2);
yaxis = loc(bout(1,1):bout(1,2),3);
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

%% Plots
figure
floor = 200;
ceiling = floor + 1000;

subplot(3,1,1)
plot(loc(floor:ceiling,1),loc(floor:ceiling,2));
title('time vs x');
subplot(3,1,2)
plot(loc(floor:ceiling,1),loc(floor:ceiling,3));
title('time vs y');
subplot(3,1,3)
plot(loc(floor:ceiling,1),loc(floor:ceiling,2));
hold on 
plot(loc(floor:ceiling,1),loc(floor:ceiling,3));
title('combined');

hold on 
for i = 1:size(bout,1)
    if bout(i,2) < floor
        continue
    end
    if bout(i,1) > ceiling
        break
    end
    xline(bout(i,1),'--r');
    xline(bout(i,2),'--r');
end

hold on 
% plot(dlarydx(1:1000));
hold on
% plot(loc(floor:ceiling,1),loc(floor:ceiling,6));

%% Test

A = [1,2; 3,4; 5,6];
R = [1 -1];
B = [0 10];

C = bsxfun(@plus,bsxfun(@times,A,R),B)
