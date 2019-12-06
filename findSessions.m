function [filelist,num] = findSessions(licklog,targetSessions)
% findSessions: return a [] of csvfile of desired sessions parameters
%   INPUT:  licklog: [animalNum,str2num(date),weight,water,ranON,iti,
%                       duration,usd,sucrose,fweight,total_lick,avg_lf, 
%                       bnum,avgblen,avgbfreq]
%           targetSessions: [animalNum,ranON,iti,duration,usd,sucrose]
%   OUTPUT: filelist: [cur csvfile]
%           num of sessions returned

filelist = [];
num = 0;
for cur = 1:size(licklog,1)
    if (licklog(cur,1) == targetSessions(1,1) || targetSessions(1,1) == 233) ... 
        && (licklog(cur,5) == targetSessions(1,2) || targetSessions(1,2) == 233) ...
        && (licklog(cur,6) == targetSessions(1,3) || targetSessions(1,3) == 233) ...
        && (licklog(cur,7) == targetSessions(1,4) || targetSessions(1,4) == 233) ...
        && (licklog(cur,8) == targetSessions(1,5) || targetSessions(1,5) == 233) ...
        && (licklog(cur,9) == targetSessions(1,6) || targetSessions(1,6) == 233)
        filelist = [filelist; licklog(cur,:)];
        num = num + 1;
    end
end

end