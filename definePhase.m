function [phase,tpMax] = definePhase(tpRange,mouthLocation,camdata)
% definePhase Identify tpMax and separate protrusion, retraction, and ILM
%   INPUT: tpRange, mouthLocation, camdata
%   OUTPUT: [phase,tpMax]
%       phase: [pStart, pEnd, pPercent, pSpeed; 
%               ilmStart, ilmEnd, ilmPercent, ilmSpeed;
%               rStart, rEnd, rPercent, rSpeed]
%       distance: [d,rate]
%              d: distance from mouthLocation to current tip location
%           rate: rate of tongue protrusion
%   DEFINITION:
%       Protrusion: the time from when the tongue is detected upto the first 
%                   minimum in the rate of tongue protrusion (d).
%       Retraction: the time from the last minima of the rate of 
%                   tongue protrusion (d) until the tongue was back.
%       ILM: any movement in between protrusion and retraction

distance = [];
curLoc = [];
phase = [];
stop = 0;       % stop calculate retraction/ILM if can't detect protrusion

for i = 1:size(tpRange,1)
    curFrameLoc = [tpRange(i,6),tpRange(i,7),tpRange(i,8)];
    curLoc = [curLoc;curFrameLoc];
    d = calcDistance(mouthLocation,curFrameLoc,0);
    
    if i == 1
        rate = d;
    else
        interval = camdata.times(tpRange(i,1),2) - camdata.times(tpRange(i-1,1),2);
        rate = (abs(d-distance(i-1))) / interval;
    end
    distance = [distance; d rate];
end

% if tpRange(1,1) == 355580
%     disp(distance);
% end
[~,maxInd] = max(distance);
tpMax = curLoc(maxInd(1),:);

% define protrusion phase
pEndRow = 0;

% if tpRange only have two frames
if size(tpRange,1) == 2
    disp(strcat('tpRange only has two frames: ',num2str(tpRange(1,1)),'-',num2str(tpRange(size(tpRange,1),1))));
    phase = [NaN NaN NaN NaN; NaN NaN NaN NaN; NaN NaN NaN NaN];
end

for i = 2:size(distance,1)-1
    if distance(i-1,2) > distance(i,2) && distance(i+1,2) > distance(i,2)
        pEnd = tpRange(i,1);
        pEndRow = i;
        pPercent = pEndRow / size(distance,1);
        % calculate avg protrusion speed
        length = 0;
        for j = 2:pEndRow
            prev = tpRange(j-1,(6:8));
            cur = tpRange(j,(6:8));
            length = length + calcDistance(prev,cur,0);
        end
        time = camdata.times(tpRange(pEndRow,1),2) - camdata.times(tpRange(1,1),2);
        pSpeed = length/time;
        phase = [tpRange(1,1) pEnd pPercent pSpeed];
        break
    end
    
    % if can't detect first minima --> tougue already protruded
    if i == size(distance,1)-1
        disp(strcat('No protrusion: ',num2str(tpRange(1,1)),'-',num2str(tpRange(size(tpRange,1),1))));
        phase = [NaN NaN NaN NaN; NaN NaN NaN NaN; NaN NaN NaN NaN];
        stop = 1;
    end
end

% define retraction and ILM phase
for i = size(distance,1)-1:-1:2
    if stop == 1
        stop = 0;
        break
    end
    if distance(i-1,2) > distance(i,2) && distance(i+1,2) > distance(i,2)
        rStart = tpRange(i,1);
        rStartRow = i;
        rPercent = (size(distance,1)-i) / size(distance,1);
        % calculate avg retraction speed
        length = 0;
        for j = rStartRow+1:size(distance,1)
            prev = tpRange(j-1,(6:8));
            cur = tpRange(j,(6:8));
            length = length + calcDistance(prev,cur,0);
        end
        time = camdata.times(tpRange(size(tpRange,1),1),2) - camdata.times(tpRange(rStartRow,1),2);
        rSpeed = length/time;
        
        ilmStart = pEndRow + 1;
        ilmEnd = rStartRow - 1;
        ilmPercent = 1 - rPercent - phase(1,3);
        % calculate avg ilm speed
        length = 0;
        for j = ilmStart+1:ilmEnd
            prev = tpRange(j-1,(6:8));
            cur = tpRange(j,(6:8));
            length = length + calcDistance(prev,cur,0);
        end
        time = camdata.times(tpRange(ilmEnd,1),2) - camdata.times(tpRange(ilmStart,1),2);
        ilmSpeed = length/time;
        
        phase = [phase; tpRange(ilmStart,1),tpRange(ilmEnd,1),ilmPercent ilmSpeed;...
                        rStart,tpRange(size(distance,1),1),rPercent rSpeed];
        break
    end 
end
end

