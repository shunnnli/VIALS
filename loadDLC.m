function [camdata,sideloc,bottomloc,swallowloc] = loadDLC(session,dlc)
% loadDLC: load session deeplabcut data

if dlc.side ~= 0
    sidecsv = 'DLC_resnet50_side-tongue-trackingJul31shuffle1_1030000.csv';
    sideraw = readmatrix(strcat('Videos/',session,'/side-',session,sidecsv));
    sideloc = [(sideraw(:,1)+1),sideraw(:,(2:end))];
else
    sideloc = [];
end

if dlc.bottom ~= 0
    bottomcsv = 'DLC_resnet50_bottom-tongue-trackingAug2shuffle1_1030000.csv';
    bottomraw = readmatrix(strcat('Videos/',session,'/bottom-',session,bottomcsv));
    bottomloc = [(bottomraw(:,1)+1),bottomraw(:,(2:end))];
else
    bottomloc = [];
end

if dlc.swallow == 1 || dlc.swallow == 2 || dlc.swallow == 3
    if dlc.swallow == 1
        swallowcsv = 'DLC_resnet50_swallowing-trackingSep8shuffle1_1030000.csv';
    elseif dlc.swallow == 2
        swallowcsv = 'DeepCut_resnet50_swallow-trackingSep18shuffle1_1030000.csv';
    else
        swallowcsv = 'DLC_resnet50_swallow-no-markerNov22shuffle1_1030000.csv';
    end
    swallowraw = readmatrix(strcat('Videos/',session,'/side-',session,swallowcsv));
    swallowloc = [(swallowraw(:,1)+1),swallowraw(:,(2:end))];
elseif dlc.swallow == 0
    swallowloc = [];
else
    disp('Incorrect dlc.swallow');
end
    
disp('dlc csv loaded');

% camdata.licking/reward = real time of licking/reward
% camdata.times = [dlcframe+1, real time, video time, 
%                   video time breaking down to hour, min, sec]
camdata = load(strcat('Videos/',session,'/times.mat'));
disp('camdata loaded');

end

