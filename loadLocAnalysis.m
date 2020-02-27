function [tp,tpbout,lickbout,skinbout] = loadLocAnalysis(session,loc,camdata,resetON)
% loadLocAnalysis: Load or create files of analysis results of a session

% tongue protrusion event log
tp_path = strcat('Videos/',session,'/','tp.csv');
if isfile(tp_path) && resetON == 0
    tp = readmatrix(tp_path);
    disp('tp.csv loaded');
else
    tp = defineLicks(loc,camdata,0.95);
    writematrix(tp, tp_path);
    disp('tp.csv created');
end

% tongue protrusion bout log
tpbout_path = strcat('Videos/',session,'/','tpbout.csv');
if isfile(tpbout_path) && resetON == 0
    tpbout = readmatrix(tpbout_path);
    disp('tpbout.csv loaded');
else
    tpbout = defineTPBout(tp);
    writematrix(tpbout,tpbout_path);
    disp('tpbout.csv created');
end

% licking lickbout log
if ~isempty(camdata.licking)
    lickbout_path = strcat('Videos/',session,'/','lickbout.csv');
    if isfile(lickbout_path) && resetON == 0
        lickbout = readmatrix(lickbout_path);
        disp('lickbout.csv loaded');
    else
        lickbout = defineLickBout(tp);
        writematrix(lickbout,lickbout_path);
        disp('lickbout.csv created');
    end
else
    lickbout = 0;
end

% swallowing bout log
if size(loc,2) > 9
    windowsize = 20;
    threshold = 10;
    hdiff = loc(:,11) - loc(:,14);
    dhdiffdx = calcDerivative(loc(:,1),hdiff);
    swallowbout_path = strcat('Videos/',session,'/','swallowbout.csv');
    if isfile(swallowbout_path) && resetON == 0
        skinbout = readmatrix(swallowbout_path);
        disp('swallowbout.csv loaded');
    else
        skinbout = defineSkinBout(loc,dhdiffdx,windowsize,threshold);
        writematrix(skinbout,swallowbout_path);
        disp('swallowbout.csv created');
    end
else
    skinbout = [];

end

