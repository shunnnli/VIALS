function [] = plotConditionalTraj(ytype,xaxis,yaxis,condArr)
% plotConditionalTraj: make trajectory black when tongue is protruded
%   INPUT:
%       ytype: specify whether y axis on the final plot is emg or traj 
%       xaxis: the axis of condition array
%       yaxis: the value of plotting trajectory
%       condArr: usually tp

for i = 1:size(condArr,1)
    if strcmp('traj',ytype) 
        plot(xaxis(condArr(i,35):condArr(i,36)),...
            yaxis(condArr(i,35):condArr(i,36)),'Color', 'k');
    elseif strcmp('emg',ytype)
        tptime = xaxis(condArr(i,35):condArr(i,36));
        [~,index] = findClosest(yaxis(:,1),tptime);
        plot(xaxis(condArr(i,35):condArr(i,36)),...
                yaxis(index),'Color', 'k');
    else
        disp('Incorrect ytype value');
    end
end

end

