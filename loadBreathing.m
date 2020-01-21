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
 
[bh,ah] = butter(filter_order,setpt_cut/(Sampling_rate/2),"low"); % get set-point
setpt_b = filtfilt(bh,ah,raw(:,2));
[bl,al] = butter(filter_order,lowpass_cut/(Sampling_rate/2),"low"); % lowpass
breath_f = filtfilt(bl,al,raw(:,2));
breath = breath_f - setpt_b;
bphase = angle(hilbert(breath));

dbreathing = [0; calcDerivative(raw(:,1),breath)];

breathing.raw = raw;
breathing.trace = breath;
breathing.phase = bphase;
breathing.d = dbreathing;
disp('Breathing loaded');

end

