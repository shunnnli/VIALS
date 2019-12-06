function [] = plotILI(bid,lickbout,tp,mode)
% plotILI: plot the number of licks in a bout vs inter-lick interval
%   mode: 'num': plot against lick number within the bout
%         'frame': plot against tongueOutFrame within the bout, used to
%                  plot with laryngeal trajectory
%         'vertical': plot vertical lines when diff(ili) > 20

% tpid of the first and last tp of the bout
boutstart = lickbout(bid,4);
boutend = lickbout(bid,5);
floor = lickbout(bid,6);
ceiling = lickbout(bid,7);

num = 1:(boutend-boutstart+1);
frame = tp(boutstart:boutend,35);
ili = tp(boutstart:boutend,5);
ili(1) = NaN; % set the first ili to NaN

% Weijnen et al (1984) Figure 4
if strcmp(mode,'num') || strcmp(mode,'frame')
    if strcmp(mode,'num')
        plot(num,ili);
    elseif strcmp(mode,'frame')
        plot(frame,ili);
    end

% Vertical lines
elseif strcmp(mode,'vertical')
    longILI = diff(ili) > 20;
    
    
end

end

