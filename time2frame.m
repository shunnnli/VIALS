function [value,index] = time2frame(time,camdata)
% time2frame: return the frame number closest to the given time

[~,index] = findClosest(camdata.times(:,2),time);
value = camdata.times(index,1);

end

