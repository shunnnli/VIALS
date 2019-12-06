function [aligned] = alignSwallow(pswallow,camdata,iti)
% alignpswallow: Group pswallows into corresponding reward
%   OUTPUT: aligned = [pswallowid rewardnum lag]

% Group pswallows into corresponding rewards
reward = camdata.reward;
aligned = [];
rewardnum = 1;

for i = 1:size(pswallow,1)
    outtime = pswallow(i,2);
    lag = outtime - reward(rewardnum);
    % if pswallow happens before the first reward
    if outtime - reward(1) < 0
        % remove pswallow if outtime is long before the first reward
        if abs(outtime - reward(1)) > iti/2
            continue
        end
        new = [pswallow(i,1) rewardnum outtime-reward(1)];
        aligned = [aligned; new];
    % if pswallow happens in the first iti/2s after the reward
    elseif lag <= iti/2 && lag > 0
        new = [pswallow(i,1) rewardnum lag];
        aligned = [aligned; new];
    % if pswallow happens in the second iti/2s after the reward and rewardnum
    % has not been updated
    elseif lag > iti/2 && lag > 0
        while outtime - reward(rewardnum) > iti/2 
            rewardnum = rewardnum + 1;
            lag = outtime - reward(rewardnum);
        end
        if rewardnum > size(reward,1)
            rewardnum = size(reward,1);
            new = [pswallow(i,1) rewardnum+1 lag];
            aligned = [aligned; new];
        else
            new = [pswallow(i,1) rewardnum lag];
            aligned = [aligned; new];
        end
    % if pswallow happens in the second iti/2s after the reward and rewardnum
    % has been updated 
    elseif lag < 0 && abs(lag) < iti/2
        if rewardnum > size(reward,1)
            rewardnum = size(reward,1);
            new = [pswallow(i,1) rewardnum+1 lag];
            aligned = [aligned; new];
        else
            new = [pswallow(i,1) rewardnum lag];
            aligned = [aligned; new];
        end
    else
        disp(strcat('alignSwallow error!'));
        disp(strcat('lag=', num2str(lag)));
        disp(strcat('rewardnum=', num2str(rewardnum)));
        disp(strcat('pswallowid=', num2str(pswallow(i,1))));
    end
end

end


