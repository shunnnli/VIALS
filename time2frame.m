function [value,index] = time2frame(time,camdata)
% time2frame: return the frame number closest to the given time

if time == 0
    value = 1; index = 1;
else
    [~,index] = findClosest(camdata.times(:,2),time);
    value = camdata.times(index,1);
end

end

