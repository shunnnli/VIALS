function [speed] = calcSpeed(loc,tp,tpid,camdata)
%calcSpeed calculate speed and accelatration during one tongue protrusion
%   INPUT: tp, tpid
%   OUTPUT: [frame instSpeed accel]

speed = [];
tongueOutFrame = tp(tpid,22);
tongueInFrame = tp(tpid,23);

tpRange = loc((tongueOutFrame:tongueInFrame),:);
for i = 1:size(tpRange,1)
    if i == 1
        speed = [1,0,0];
        continue
    end
    
    prev = tpRange(i-1,(6:8));
    cur = tpRange(i,(6:8));
    d = calcDistance(prev,cur);
    interval = camdata.times(tpRange(i,1),2) - camdata.times(tpRange(i-1,1),2);
    
    instSpeed = d/interval;
    accel = (instSpeed-speed(i-1,2)) / interval;
    speed = [speed; i, instSpeed, accel];
end

end