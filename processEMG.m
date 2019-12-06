function [emg,emgenv] = processEMG(adc,fs,cutfreqs)
% processEMG: Apply frequency filter to EMG data
%   INPUT: 
%       fs: sampling frequency
%       cutfreqs: [lowpass highpass]
%   OUTPUT: emg, emgenv (upper envelope of emg)

% https://www.mathworks.com/matlabcentral/fileexchange/68245-digital-processing-of-electromyographic-signals-for-control
% Bandstop filter: 60Hz (done in Licking_parse)

time = adc(:,1);
emgraw = adc(:,2);
% ts = 1/fs; % sampling period
% N = length(emgraw);
% f0 = fs/N;    % frequency per sample

% Offset elimination
emgraw = detrend(emgraw);

% Bandpass filter
[b,a] = butter(4,[cutfreqs(1)*2/fs cutfreqs(2)*2/fs]);
emg = [time abs(filtfilt(b,a,emgraw))];

% Calculate upper envelope of EMG
disp('Calculating EMG envelope...');
[emgenv,~] = envelope(emg,1000,'peak');

% Plotting regions
%{
% ceiling = 5000;
% figure
% plot(adc(1:100000,1),emgraw(1:100000));

figure
plot(adc(1:ceiling,1),emgraw(1:ceiling));
hold on
plot(adc(1:ceiling,1),emgf1(1:ceiling));

freqraw = fft(emgraw);
freqf1 = fft(emgf1);

figure
plot(adc(1:ceiling,1),adc(1:ceiling,2));
hold on
plot(adc(1:ceiling,1),emgf1(1:ceiling));
hold on
% plot(adc(1:ceiling,1),emgf2(1:ceiling));

figure
% plot(f0*(0:N-1),abs(freqraw));
hold on
plot(f0*(0:N-1),abs(freqf1));
xlim([20 100])
%}
end

