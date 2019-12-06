function [time] = frame2time(frame,convertmat)
% frame2time: Convert frames into actual time
%   INPUT:
%       frame: row number of convertmat
%       convertmat: camdata.times or adc
%   OUTPUT: time

if size(convertmat,1) == 1
    % convertmat is camdata.times
    time = convertmat.times(frame,2);
else
    % convertmat is adc
    time = convertmat(frame,1);

end