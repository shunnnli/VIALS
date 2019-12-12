function [] = plotTongueTraj(phase,tpid,session,plane)
% plotTongueTraj: plot tongue trajectory given tpid
%   INPUT: 
%       phase: 1 -> separate protrusion, retraction, ILM
%       tpid, loc, tp
%       plane: 0 -> 3d, 1 -> side, 2 -> bottom

%   *: if tpid has only a single row: blue -> orange -> green
%      if tpid has two rows:
%           the first row: yellow -> orange -> red
%           --> licks from smaller PCA clusters (licks w/o ILM and licks w/ little angle)
%           the second row: green -> blue -> purple
%           --> licks from larger PCA clusters

[camdata,loc] = loadLocData(session,0,9999,1);
[tp,~,~,~] = loadLocAnalysis(session,loc,camdata,0);

for i = 1:size(tpid,1)
    for j = 1:size(tpid,2)
        spout = tp(tpid(i,j),(24:26));
        whole = loc((tp(tpid(i,j),35):tp(tpid(i,j),36)),:);
        
        % Separate different phases
        if ~isnan(tp(tpid(i,j),27:32))
            protrusion = loc((tp(tpid(i,j),27):tp(tpid(i,j),28)),:);
            ilm = loc((tp(tpid(i,j),29)-1:tp(tpid(i,j),30)+1),:);
            retraction = loc((tp(tpid(i,j),31):tp(tpid(i,j),32)),:);
        else
            phase = -1;
        end
        
        % Plot tongue trajectory
        if plane == 0
            plot3(spout(1),spout(2),spout(3),'o','DisplayName','Spout');
            hold on
        elseif plane == 1
            plot(spout(2),spout(3),'o','DisplayName','Spout');
            hold on
        else
            plot(spout(1),spout(2),'o','DisplayName','Spout');
            hold on
        end
        
        if i == 1
            % Plot single tp type
            if size(tpid,1) == 1
                if plane == 0
                    if phase == -1
                        % black, can't detect phase
                        plot3(whole(:,6),whole(:,7),whole(:,8),...
                            'k','LineWidth',2);
                        hold on
                    else
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
                elseif plane == 1
                    if phase == -1
                        % black, can't detect phase
                        plot3(whole(:,6),whole(:,7),whole(:,8),...
                            'k','LineWidth',2);
                        hold on
                    else
                        plot(protrusion(:,7),protrusion(:,8),'Color','#0072BD',...
                            'DisplayName','Protrusion', 'LineWidth',2);
                        hold on
                        plot(ilm(:,7),ilm(:,8),'Color','#D95319', ...
                            'DisplayName','Interlick movement','LineWidth',2);
                        hold on
                        plot(retraction(:,7),retraction(:,8),'Color','#77AC30',...
                            'DisplayName','Retraction','LineWidth',2);
                        hold on
                        continue
                    end
                else
                    if phase == -1
                        % black, can't detect phase
                        plot3(whole(:,6),whole(:,7),whole(:,8),...
                            'k','LineWidth',2);
                        hold on
                    else
                        plot(protrusion(:,6),protrusion(:,7),'Color','#0072BD',...
                            'DisplayName','Protrusion', 'LineWidth',2);
                        hold on
                        plot(ilm(:,6),ilm(:,7),'Color','#D95319', ...
                            'DisplayName','Interlick movement','LineWidth',2);
                        hold on
                        plot(retraction(:,6),retraction(:,7),'Color','#77AC30',...
                            'DisplayName','Retraction','LineWidth',2);
                        hold on
                        continue
                    end
                end
            end
            
            % Plot multiple tp type
            if phase == 1
                % yellow -> orange -> red
                if plane == 0
                    plot3(protrusion(:,6),protrusion(:,7),protrusion(:,8),...
                        'Color','#EDB120','LineWidth',2);
                    hold on
                    plot3(ilm(:,6),ilm(:,7),ilm(:,8),'Color','#D95319','LineWidth',2);
                    hold on
                    plot3(retraction(:,6),retraction(:,7),retraction(:,8),...
                        'Color','#A2142F','LineWidth',2);
                    hold on
                elseif plane == 1
                    plot(protrusion(:,7),protrusion(:,8),'Color','#EDB120',...
                        'DisplayName','Protrusion', 'LineWidth',2);
                    hold on
                    plot(ilm(:,7),ilm(:,8),'Color','#D95319', ...
                        'DisplayName','Interlick movement','LineWidth',2);
                    hold on
                    plot(retraction(:,7),retraction(:,8),'Color','#A2142F',...
                        'DisplayName','Retraction','LineWidth',2);
                    hold on
                    continue
                else
                    plot(protrusion(:,6),protrusion(:,7),'Color','#EDB120',...
                        'DisplayName','Protrusion', 'LineWidth',2);
                    hold on
                    plot(ilm(:,6),ilm(:,7),'Color','#D95319', ...
                        'DisplayName','Interlick movement','LineWidth',2);
                    hold on
                    plot(retraction(:,6),retraction(:,7),'Color','#A2142F',...
                        'DisplayName','Retraction','LineWidth',2);
                    hold on
                    continue
                end
            elseif phase == 0
                % single color, no phase separation
                if plane == 0
                    plot3(whole(:,6),whole(:,7),whole(:,8),...
                        'Color','#7E2F8E','LineWidth',2);
                    hold on
                elseif plane == 1
                    plot(whole(:,7),whole(:,8),...
                        'Color','#7E2F8E','LineWidth',2);
                    hold on
                else
                    plot(whole(:,6),whole(:,7),...
                        'Color','#7E2F8E','LineWidth',2);
                    hold on
                end
            else
                % black, can't detect phase
                if plane == 0
                    plot3(whole(:,6),whole(:,7),whole(:,8),...
                        'k','LineWidth',2);
                    hold on
                elseif plane == 1
                    plot(whole(:,7),whole(:,8),...
                        'k','LineWidth',2);
                    hold on
                else
                    plot(whole(:,6),whole(:,7),...
                        'k','LineWidth',2);
                    hold on
                end
            end
        else
            if phase == 1
                % green -> blue -> purple
                if plane == 0
                    plot3(protrusion(:,6),protrusion(:,7),protrusion(:,8),...
                        'Color','#77AC30','LineWidth',2);
                    hold on
                    plot3(ilm(:,6),ilm(:,7),ilm(:,8),'Color','#0072BD','LineWidth',2);
                    hold on
                    plot3(retraction(:,6),retraction(:,7),retraction(:,8),...
                        'Color','#7E2F8E','LineWidth',2);
                    hold on
                elseif plane == 1
                    plot(protrusion(:,7),protrusion(:,8),'Color','#77AC30',...
                        'DisplayName','Protrusion', 'LineWidth',2);
                    hold on
                    plot(ilm(:,7),ilm(:,8),'Color','#0072BD', ...
                        'DisplayName','Interlick movement','LineWidth',2);
                    hold on
                    plot(retraction(:,7),retraction(:,8),'Color','#7E2F8E',...
                        'DisplayName','Retraction','LineWidth',2);
                    hold on
                    continue
                else
                    plot(protrusion(:,6),protrusion(:,7),'Color','#77AC30',...
                        'DisplayName','Protrusion', 'LineWidth',2);
                    hold on
                    plot(ilm(:,6),ilm(:,7),'Color','#0072BD', ...
                        'DisplayName','Interlick movement','LineWidth',2);
                    hold on
                    plot(retraction(:,6),retraction(:,7),'Color','#7E2F8E',...
                        'DisplayName','Retraction','LineWidth',2);
                    hold on
                    continue
                end
            elseif phase == 0
                % single color, no phase separation
                if plane == 0
                    plot3(whole(:,6),whole(:,7),whole(:,8),...
                        'Color','#0072BD','LineWidth',2);
                    hold on
                elseif plane == 1
                    plot(whole(:,7),whole(:,8),...
                        'Color','#0072BD','LineWidth',2);
                    hold on
                else
                    plot(whole(:,6),whole(:,7),...
                        'Color','#0072BD','LineWidth',2);
                    hold on
                end
            else
                % black, can't detect phase
                if plane == 0
                    plot3(whole(:,6),whole(:,7),whole(:,8),...
                        'k','LineWidth',2);
                    hold on
                elseif plane == 1
                    plot(whole(:,7),whole(:,8),...
                        'k','LineWidth',2);
                    hold on
                else
                    plot(whole(:,6),whole(:,7),...
                        'k','LineWidth',2);
                    hold on
                end
            end
        end
    end
    hold on
end

grid on
axis equal
xlabel('ML')
ylabel('AP')
zlabel('DV')
% legend('location','ne')

end

