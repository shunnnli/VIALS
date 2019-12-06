function [camdata,sideloc,bottomloc,swallowloc] = loadDLC(session,swallowdlc)
% loadDLC: load session deeplabcut data

sidecsv = 'DLC_resnet50_side-tongue-trackingJul31shuffle1_1030000.csv';
bottomcsv = 'DLC_resnet50_bottom-tongue-trackingAug2shuffle1_1030000.csv';
sideraw = readmatrix(strcat('Videos/',session,'/side-',session,sidecsv));
bottomraw = readmatrix(strcat('Videos/',session,'/bottom-',session,bottomcsv));
sideloc = [(sideraw(:,1)+1),sideraw(:,(2:end))];
bottomloc = [(bottomraw(:,1)+1),bottomraw(:,(2:end))];

if swallowdlc == 1 || swallowdlc == 2 || swallowdlc == 3
    if swallowdlc == 1
        swallowcsv = 'DLC_resnet50_swallowing-trackingSep8shuffle1_1030000.csv';
    elseif swallowdlc == 2
        swallowcsv = 'DeepCut_resnet50_swallow-trackingSep18shuffle1_1030000.csv';
    else
        swallowcsv = 'DLC_resnet50_swallow-no-markerNov22shuffle1_1030000.csv';
    end
    swallowraw = readmatrix(strcat('Videos/',session,'/side-',session,swallowcsv));
    swallowloc = [(swallowraw(:,1)+1),swallowraw(:,(2:end))];
elseif swallowdlc == 0
    swallowloc = [];
else
    disp('Incorrect swallowdlc');
end
    
disp('dlc csv loaded');

% camdata.licking/reward = real time of licking/reward
% camdata.times = [dlcframe+1, real time, video time, 
%                   video time breaking down to hour, min, sec]
camdata = load(strcat('Videos/',session,'/times.mat'));
disp('camdata loaded');

end

