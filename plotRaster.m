function [rp,aligned] = plotRaster(tp,pswallow,emgswallow,camdata)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% Fix reward interval
iti = mean(diff(camdata.reward));   % Determine ITI
tpaligned = sortrows(alignTP(tp,camdata,iti),2);

if ~isempty(pswallow)
    psaligned = alignSwallow(pswallow,camdata,iti);
else
    psaligned = [1 1];
end

if ~isempty(emgswallow)
    esaligned = alignSwallow(emgswallow,camdata,iti);
else
    esaligned = [];
end
islick = find(tpaligned(:,2) > 0,1);

rp = figure('Name','Summary of events');
xline(0,'-k','LineWidth',1,'DisplayName','Reward onset');
hold on
if size(camdata.licking,1) < 2
    scatter(tpaligned(:,5),tpaligned(:,4),'.',...
        'MarkerEdgeColor','#0072BD','DisplayName','Lick');
else
    scatter(tpaligned(1:islick,5),tpaligned(1:islick,4),...
        '.','MarkerEdgeColor','#4DBEEE','DisplayName','Spout-missed lick');   % not lick
    hold on
    scatter(tpaligned(islick+1:size(tpaligned,1),5),...
        tpaligned(islick+1:size(tpaligned,1),4),...
        '.','MarkerEdgeColor','#0072BD','DisplayName','Spout-hit lick');   % is lick
end
hold on
if ~isempty(pswallow)
    scatter(psaligned(:,3),psaligned(:,2),'or','DisplayName','VIALS-detected swallow');
end
hold on
if ~isempty(emgswallow)
    scatter(esaligned(:,3),esaligned(:,2),'ok','DisplayName','EMG-detected swallow');
end

xlim([-iti/2 iti/2]);
ylim([0 max(tpaligned(size(tpaligned,1),4),psaligned(size(psaligned,1),2))]);
xlabel('Time from reward (s)');
ylabel('Reward number');

aligned.tp = tpaligned;
aligned.es = esaligned;
aligned.ps = psaligned;

end

