function [breathing] = loadBreathing(start,stop,camdata)

raw = [transpose((1:size(camdata.breathing,1))/30000),double(camdata.breathing)/20];

if ~(start == 0 && stop >= 9999)
    % Apply time frame to camdata.adc
    [~,startrow] = min(abs(raw(:,1)-start));
    [~,stoprow] = min(abs(raw(:,1)-stop));
    raw = raw(startrow:stoprow,:);
end

% Apply filter
Sampling_rate = 30000;
setpt_cut = 1; % minimum frequency
lowpass_cut = 15; % maximum frequency 15 Hz (for rat and mouse)
filter_order = 3;
 
% filter raw breathing data
[bh,ah] = butter(filter_order,setpt_cut/(Sampling_rate/2),"low"); % get set-point
setpt_b = filtfilt(bh,ah,raw(:,2));
[bl,al] = butter(filter_order,lowpass_cut/(Sampling_rate/2),"low"); % lowpass
breath_f = filtfilt(bl,al,raw(:,2));
breath = breath_f - setpt_b;

% Calculate breathing phase
bphase = angle(hilbert(breath));

% Calculate instaneous breathing frequency
bcount = islocalmin(bphase,'MinSeparation',2000,'FlatSelection','center');
bstart = find(bcount == 1);

time = [0:length(raw)-1]/Sampling_rate;
% Baseline frequency 350/min: https://www.karger.com/article/pdf/330586
freq_dtime = 0.17;
intphase = unwrap(bphase);
totaltime = length(raw)/Sampling_rate;
freqtimes = [0:freq_dtime:totaltime];

intphase_resamp = interp1(time,intphase,freqtimes);
freq = diff(intphase_resamp)/freq_dtime/(2*pi);
freq_extrapolate = [freq(1), freq, freq(end)];
freqtimepts = freqtimes(1:end-1)+freq_dtime/2;
freqtimepts_extrapolate = [0, freqtimepts, totaltime];
frequency = interp1(freqtimepts_extrapolate,freq_extrapolate,time);

% Calculate derivative of breathing
dbreathing = [0; calcDerivative(raw(:,1),breath)];

breathing.raw = raw;
breathing.trace = breath;
breathing.phase = bphase;
breathing.d = dbreathing;
breathing.count = bstart;
breathing.frequency = smoothdata(frequency);
disp('Breathing loaded');

end

