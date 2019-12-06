function [] = plotTongueTraj(phase,tpid,loc,tp)
% plotTongueTraj: plot tongue trajectory given tpid
%   INPUT: 
%       phase: 1 -> separate protrusion, retraction, ILM
%       tpid, loc, tp

%   *: if tpid has only a single row: blue -> orange -> green
%      if tpid has two rows:
%           the first row: yellow -> orange -> red
%           --> licks from smaller PCA clusters (licks w/o ILM and licks w/ little angle)
%           the second row: green -> blue -> purple
%           --> licks from larger PCA clusters

for i = 1:size(tpid,1)
    for j = 1:size(tpid,2)
        spout = tp(tpid(i,j),(24:26));  
        % Separate different phases
        protrusion = loc((tp(tpid(i,j),27):tp(tpid(i,j),28)),:);
        ilm = loc((tp(tpid(i,j),29)-1:tp(tpid(i,j),30)+1),:);
        retraction = loc((tp(tpid(i,j),31):tp(tpid(i,j),32)),:);
        whole = loc((tp(tpid(i,j),35):tp(tpid(i,j),36)),:);
        
        % Plot tongue trajectory
        plot3(spout(1),spout(2),spout(3),'o','DisplayName','Spout');
        hold on
        
        if i == 1
            if size(tpid,1) == 1
                plot3(protrusion(:,6),protrusion(:,7),protrusion(:,8),...
                    'Color','#0072BD', 'DisplayName','Protrusion', 'LineWidth',2);
                hold on
                plot3(ilm(:,6),ilm(:,7),ilm(:,8),'Color','#D95319', ...
                    'DisplayName','Interlick movement','LineWidth',2);
                hold on
                plot3(retraction(:,6),retraction(:,7),retraction(:,8),...
                    'Color','#77AC30','DisplayName','Retraction','LineWidth',2);
                hold on
                continue
            end
            if phase == 1
                % yellow -> orange -> red
                plot3(protrusion(:,6),protrusion(:,7),protrusion(:,8),...
                    'Color','#EDB120','LineWidth',2);
                hold on
                plot3(ilm(:,6),ilm(:,7),ilm(:,8),'Color','#D95319','LineWidth',2);
                hold on
                plot3(retraction(:,6),retraction(:,7),retraction(:,8),...
                    'Color','#A2142F','LineWidth',2);
                hold on
            else
                plot3(whole(:,6),whole(:,7),whole(:,8),...
                    'Color','#7E2F8E','LineWidth',2);
                hold on
            end
        else
            if phase == 1
                % green -> blue -> purple
                plot3(protrusion(:,6),protrusion(:,7),protrusion(:,8),...
                    'Color','#77AC30','LineWidth',2);
                hold on
                plot3(ilm(:,6),ilm(:,7),ilm(:,8),'Color','#0072BD','LineWidth',2);
                hold on
                plot3(retraction(:,6),retraction(:,7),retraction(:,8),...
                    'Color','#7E2F8E','LineWidth',2);
                hold on
            else
                plot3(whole(:,6),whole(:,7),whole(:,8),...
                    'Color','#0072BD','LineWidth',2);
                hold on
            end
        end
    end
    hold on
end

grid on
axis equal
legend

end

