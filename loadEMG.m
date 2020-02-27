function emg = loadEMG(start,stop,camdata)
% adc = [time adc_value]
adc = [transpose((1:size(camdata.emg,1))/30000), double(camdata.emg)/20];

if ~(start == 0 && stop >= 9999)
    % Apply time frame to camdata.emg
    [~,startrow] = min(abs(adc(:,1)-start));
    [~,stoprow] = min(abs(adc(:,1)-stop));
    adc = adc(startrow:stoprow,:);
end

% Set EMG and imaging parameters
% fs = 30000;     % EMG sampling frequency
% fps = 1/0.006;   % camera frame rate
% [emg,emgenv] = processEMG(adc,fs,[bplow bphigh]);

% Apply filter
Sampling_rate = 30000;
setpt_cut = 100; % minimum frequency
lowpass_cut = 3000; % maximum frequency 15 Hz (for rat and mouse)
filter_order = 3;
 
% filter emg data
[bh,ah] = butter(filter_order,setpt_cut/(Sampling_rate/2),"low"); % get set-point
setpt_emg = filtfilt(bh,ah,adc(:,2));
[bl,al] = butter(filter_order,lowpass_cut/(Sampling_rate/2),"low"); % lowpass
emg_f = filtfilt(bl,al,adc(:,2));
emg_trace = emg_f - setpt_emg;
[emgenv,~] = envelope(emg_trace,1500,'peak');

% Calculate breathing phase
emg_phase = angle(hilbert(emg_trace));

emg.time = adc(:,1);
emg.trace = emg_trace;
emg.phase = emg_phase;
emg.env = emgenv;

disp('EMG loaded');
end

