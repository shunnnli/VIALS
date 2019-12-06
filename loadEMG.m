function [emg,emgenv] = loadEMG(bplow,bphigh,start,stop,camdata)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% adc = [time adc_value]
adc = [transpose((1:size(camdata.adc,1))/30000), double(camdata.adc)/20];

if ~(start == 0 && stop >= 9999)
    % Apply time frame to camdata.adc
    [~,startrow] = min(abs(adc(:,1)-start));
    [~,stoprow] = min(abs(adc(:,1)-stop));
    adc = adc(startrow:stoprow,:);
end

% Set EMG and imaging parameters
fs = 30000;     % EMG sampling frequency
fps = 1/0.006;   % camera frame rate
[emg,emgenv] = processEMG(adc,fs,[bplow bphigh]);
disp('EMG loaded');

end

