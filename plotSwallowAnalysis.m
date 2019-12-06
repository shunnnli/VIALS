function ap = ...
    plotSwallowAnalysis(floor,ceiling,time,loc,pswallow,longici,emgswallow,emg,emgenv,camdata)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

pks = find(pswallow(:,2) >= time(1) & pswallow(:,2) <= time(size(time,1)));
lici = find(longici(:,3) >= floor & longici(:,4) <= ceiling);

ap = figure;
subplot(2,1,1)
for i = 1:size(lici) 
    xline(frame2time(longici(lici(i),3),camdata),'-b');
    hold on
    xline(frame2time(longici(lici(i),4),camdata),'-b'); 
end
hold on
plotBouts('swallowbout',swallowbout,floor,ceiling,camdata);
hold on
plot(frame2time(loc(:,1),camdata),ylaryvsjaw);
hold on
plot(pswallow(:,2),pswallow(:,3),'or');
hold on
plotConditionalTraj('traj',frame2time(loc(:,1),camdata),ylaryvsjaw,tp);
xlim([time(1) time(length(time))]);

% ylaryvsjaw + EMG
subplot(2,1,2)
plot(emg(:,1),emg(:,2),'Color','#4DBEEE');
hold on
plot(emgenv(:,1),emgenv(:,2),'LineWidth',1);
for i = 1:size(pks,1)
    xline(pswallow(pks(i),2),'-r');
end
hold on
% for i = 1:size(lici) 
%     xline(frame2time(longici(lici(i),3),camdata),'-b');
%     hold on
%     xline(frame2time(longici(lici(i),4),camdata),'-b'); 
% end
hold on
% for i = 1:size(camdata.reward,1)
%     xline(camdata.reward(i),'-k');
% end
hold on
% plotConditionalTraj('emg',frame2time(loc(:,1),camdata),emgenv,tp);
hold on
plot(emgenv(envplocs,1),envpeaks,'oc');
hold on
plot(emgenv(emgswallow(:,3),1),emgswallow(:,4),'ob');
xlim([time(1) time(length(time))]);

end

