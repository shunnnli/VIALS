function [tp] = defineLicks(loc,camdata,threshold)
% defineLicks: Identify licks and tongue protrusion based on loc, calculate
% movement parameters for each tongue protrusion event.

%   INPUT: loc, camdata
%   OUPUT: 
%       tp = [tpid, isLick, spoutContact, duration, ici,
%               pathLen (6), amplitude (x,y,z), tpDevianceS/B, tpMax (x,y,z),
%               pPercent (15), pSpeed, ilmPercent, ilmSpeed, rPercent, rSpeed,
%               mouthLocation (21-23), spout (24-26), 
%               pStart (27), pEnd, ilmStart, ilmEnd, rStart, rEnd (32),
%               tongueOutTime (33), tongueInTime, 
%               tongueOutFrame (35), tongueInFrame, lastReward, spoutContactTime]

%       ** : duration = tongueInTime - tongueOutTime
%       ** : tongueOut/InFrame is based on camdata.times
%       ** : spoutContact is NaN if isLick == 0
%       ** : amplitude is the maximum location of tip of x,y,z axis
%       ** : tpMax is the location where tip is furthest from mouthLocation
%       ** : mouthLocation is the initial location of the mouth 
%           (location of tongue tip when the tongue first appears)
%       ** : spout is the averaged location of spout
%       ** : tpDevianceS/B is the angle between mouthLocation to spout and 
%            to tpMax from side/bottom view
%       ** : spoutContactTime is the time shown on the camdata.licking
%           where the tongue touches the spout

%   DEFINITION:
%       lick = tongueTip appears (tongueOut) to disappear (tongueIn)
%               && camdata.licking has lick during protrusion (isLick)
%       tp   = tongueTip appears (tongueOut) to disappear (tongueIn)
%               && no lick during protrusion in camdata.licking (isLick)
%       Protrusion: the time from when the tongue is detected upto the first 
%                   minimum in the rate of tongue protrusion (d).
%       Retraction: the time from the last minima of the rate of 
%                   tongue protrusion (d) until the tongue was back.
%       ILM: any movement in between protrusion and retraction
%       ICI: inter-contact interval = tongueOutTime - prevTongueInTime

tp = []; tpid = 0; tpON = 0;
pathLen = 0; mouthLocation = [];
prevTongueOutTime = 0; prevTongueInTime = 0;

for cur = 1:size(loc,1)
    ttl = loc(cur,9);
    
    if cur+1 <= size(loc,1)
        ttlNext = loc(cur+1,9);
    else
        break
    end
    
    if ttl < threshold && tpON == 0
        % check if lick is recorded between current and next frame
        if isempty(camdata.licking)
            isLickBetween = [];
        else
            isLickBetween = find(camdata.licking > camdata.times(cur,2) ...
                & camdata.licking < camdata.times(cur+1,2), 1);
        end
        % if lick is recorded in between --> tongue protrusion starts
        if ~isempty(isLickBetween)
            tpON = 1;
            mouthLocation = [loc(cur,6),loc(cur,7),loc(cur,8)];
            nextloc = [loc(cur+1,6),loc(cur+1,7),loc(cur+1,8)];
            pathLen = pathLen + calcDistance(mouthLocation,nextloc,0);
            tongueOutFrame = cur;
            tongueOutTime = camdata.times(tongueOutFrame,2);
            tpid = tpid + 1;
        end     
        continue
    
    elseif ttl >= threshold && tpON == 0
        % tongue protrusion starts
        tpON = 1;
        mouthLocation = [loc(cur,6),loc(cur,7),loc(cur,8)];
        nextloc = [loc(cur+1,6),loc(cur+1,7),loc(cur+1,8)];
        pathLen = pathLen + calcDistance(mouthLocation,nextloc,0);
        tongueOutFrame = cur;
        tongueOutTime = camdata.times(tongueOutFrame,2);
        tpid = tpid + 1;
    
    elseif ttl >= threshold && tpON == 1
        % tongue protrusion continues
        curloc = [loc(cur,6),loc(cur,7),loc(cur,8)];
        nextloc = [loc(cur+1,6),loc(cur+1,7),loc(cur+1,8)];
        pathLen = pathLen + calcDistance(curloc,nextloc,0);
        continue
    
    elseif ttl < threshold && tpON == 1
        % tongue protrusion continues if the next frame have tongue's tip
        if ttlNext >= threshold
            disp(strcat('Tip detection interrupted:',num2str(cur)));
            curloc = [loc(cur,6),loc(cur,7),loc(cur,8)];
            nextloc = [loc(cur+1,6),loc(cur+1,7),loc(cur+1,8)];
            pathLen = pathLen + calcDistance(curloc,nextloc,0);
            continue
        end
        
        % tongue protrusion ends
        tpON = 0;
        tongueInFrame = cur - 1;
        tongueInTime = camdata.times(tongueInFrame,2);
        if tongueOutFrame == tongueInFrame
            disp(strcat('tongueOutFrame=tongueInFrame=', num2str(tongueInFrame)));
            tpid = tpid - 1;
            continue
        end
        
        % Calculate tongue protrusion amplitude parameters
        tpRange = loc((tongueOutFrame:tongueInFrame),:);
        amplitude = max(tpRange(:,(6:8)));
        [phase,tpMax,pEndLoc] = definePhase(tpRange,mouthLocation);
        % tortuosity = calcTortuosity(tpRange,pathLen);
%         disp('pEndLoc');
        
        % Calculate spout location
        spoutraw = [];
        spoutwindow = 1000;
        if tongueOutFrame - spoutwindow/2 < 1
            for i = 1:min(tongueOutFrame+spoutwindow, size(loc,1))
                if loc(i,5) >= threshold
                    spoutraw = [spoutraw;loc(i,2),loc(i,3),loc(i,4)];
                end
            end
        elseif tongueOutFrame + spoutwindow/2 > size(loc,1)
            for i = max(1,tongueOutFrame - spoutwindow) : size(loc,1)
                if loc(i,5) >= threshold
                    spoutraw = [spoutraw;loc(i,2),loc(i,3),loc(i,4)];
                end
            end
        else
            for i = max(1,tongueOutFrame-spoutwindow/2) : min(tongueOutFrame+spoutwindow/2, size(loc,1))
                if loc(i,5) >= threshold
                    spoutraw = [spoutraw;loc(i,2),loc(i,3),loc(i,4)];
                end
            end
        end
        spout = mean(spoutraw);
        
        % mouth to spout direction vector
        if ~any(isnan(pEndLoc))
            m2s = [spout(1)-mouthLocation(1),spout(2)-mouthLocation(2),...
                            spout(3)-mouthLocation(3)];
            % mouth to tpMax direction vector
            m2m = [pEndLoc(1)-mouthLocation(1),pEndLoc(2)-mouthLocation(2),...
                            pEndLoc(3)-mouthLocation(3)];
            % tpDeviance = atan2d(norm(cross(m2s,m2m)),dot(m2s,m2m));
            tpDevianceS = atan2d(norm(cross([0 m2s(2:3)],[0 m2m(2:3)])),...
                                dot([0 m2s(2:3)],[0 m2m(2:3)]));
            tpDevianceB = atan2d(norm(cross([m2s(1:2) 0],[m2m(1:2) 0])),...
                                dot([m2s(1:2) 0],[m2m(1:2) 0]));
        else
            tpDevianceS = NaN;
            tpDevianceB = NaN;
        end
        
        % Check if camdata.licking recorded lick events
        if ~isempty(camdata.licking)
            isLick = find(camdata.licking > tongueOutTime...
                        & camdata.licking < tongueInTime);
        else
            isLick = [];
        end
        
        % find lastReward
        possibles = camdata.reward < tongueOutTime;
        [posmax, posind] = max(camdata.reward(possibles));
        inddatapos = find(possibles);       % possible indices
        inddata = inddatapos(posind);       % find the index we care about
        if isempty(inddata)
            posmax = NaN;
        end
        lastReward = posmax;
        
        % write tp.csv
        duration = tongueInTime - tongueOutTime;
        % ili = tongueOutTime - prevTongueOutTime;
        % prevTongueOutTime = tongueOutTime;
        ici = tongueOutTime - prevTongueInTime; % (inter-contact interval)
        prevTongueInTime = tongueInTime;
        
        % Tongue failes to touch the spout
        if isempty(isLick)
            % disp(tpid);
            % disp(tongueOutFrame);
            % disp(tongueInFrame);
            new_tp = [tpid,0,NaN,duration,ici,pathLen,amplitude,...
                        tpDevianceS,tpDevianceB,tpMax,...
                        phase(1,3),phase(1,4),phase(2,3),phase(2,4),phase(3,3),phase(3,4),...
                        mouthLocation,spout,...
                        phase(1,1),phase(1,2),phase(2,1),phase(2,2),phase(3,1),phase(3,2),...
                        tongueOutTime,tongueInTime,...
                        tongueOutFrame,tongueInFrame,lastReward,NaN];
            tp = [tp; new_tp];
        % Tongue touches the spout
        elseif length(isLick) == 1
            spoutContact = camdata.licking(isLick) - tongueOutTime;
            spoutContactTime = camdata.licking(isLick);
            new_tp = [tpid,1,spoutContact,duration,ici,pathLen,amplitude,...
                        tpDevianceS,tpDevianceB,tpMax,...
                        phase(1,3),phase(1,4),phase(2,3),phase(2,4),phase(3,3),phase(3,4),...
                        mouthLocation,spout,...
                        phase(1,1),phase(1,2),phase(2,1),phase(2,2),phase(3,1),phase(3,2),...
                        tongueOutTime,tongueInTime,...
                        tongueOutFrame,tongueInFrame,lastReward,spoutContactTime];
            tp = [tp; new_tp];
        else
            disp(strcat(num2str(tpid),': ', num2str(length(isLick)), ' licks detected!'));
            disp(strcat('tongueOutF: ', num2str(tongueOutFrame),' | ', ...
                        'tongueInF: ', num2str(tongueInFrame), ' | ', ...
                        'duration: ', num2str(duration)));
            spoutContact = mean(camdata.licking(isLick)) - tongueOutTime;
            spoutContactTime = mean(camdata.licking(isLick));
            new_tp = [tpid,1,spoutContact,duration,ici,pathLen,amplitude,...
                        tpDevianceS,tpDevianceB,tpMax,...
                        phase(1,3),phase(1,4),phase(2,3),phase(2,4),phase(3,3),phase(3,4),...
                        mouthLocation,spout,...
                        phase(1,1),phase(1,2),phase(2,1),phase(2,2),phase(3,1),phase(3,2),...
                        tongueOutTime,tongueInTime,...
                        tongueOutFrame,tongueInFrame,lastReward,spoutContactTime];
            tp = [tp; new_tp];
        end
    end
    pathLen = 0;
end
end

