function [aligned] = alignTP(tp,camdata,iti)
% alignTP: Group tps into corresponding reward
%   OUTPUT: aligned = [tpid, isLick, tongueOutTime, rewardnum, lag]

% Group TPs into corresponding rewards
reward = camdata.reward;
aligned = [];
rewardnum = 1;

for i = 1:size(tp,1)
   outtime = tp(i,33);
   lag = outtime - reward(rewardnum);
   % if tp happens before the first reward
   if outtime - reward(1) < 0
       % remove tp if outtime is long before the first reward
       if abs(outtime - reward(1)) > iti/2
           continue
       end
       new = [tp(i,1) tp(i,2) tp(i,33) rewardnum outtime-reward(1)];
       aligned = [aligned; new];
   % if tp happens in the first iti/2s after the reward
   elseif lag <= iti/2 && lag > 0
       new = [tp(i,1) tp(i,2) tp(i,33) rewardnum lag];
       aligned = [aligned; new];
   % if tp happens in the second iti/2s after the reward and rewardnum
   % has not been updated
   elseif lag > iti/2 && lag > 0
       rewardnum = rewardnum + 1;
       if rewardnum > size(reward,1)
           rewardnum = size(reward,1);
           new = [tp(i,1) tp(i,2) tp(i,33) rewardnum+1 lag];
           aligned = [aligned; new];
       else
           new = [tp(i,1) tp(i,2) tp(i,33) rewardnum lag];
           aligned = [aligned; new];
       end
   % if tp happens in the second iti/2s after the reward and rewardnum
   % has been updated 
   elseif lag < 0 && abs(lag) < iti/2
       if rewardnum > size(reward,1)
           rewardnum = size(reward,1);
           new = [tp(i,1) tp(i,2) tp(i,33) rewardnum+1 lag];
           aligned = [aligned; new];
       else
           new = [tp(i,1) tp(i,2) tp(i,33) rewardnum lag];
           aligned = [aligned; new];
       end
   else
       disp(strcat('alignTP error!'));
       disp(strcat('lag=', num2str(lag)));
       disp(strcat('rewardnum=', num2str(rewardnum)));
       disp(strcat('tpid=', num2str(tp(i,1))));
   end
end

end

