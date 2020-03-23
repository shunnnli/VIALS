function [camdata,loc] = loadLocData(session,start,stop)

camdata = load(strcat('Videos/',session,'/times.mat'));

% Apply analysis window (in seconds)
% duration = stop - start;
if ~(start == 0 && stop >= Inf)
    % Apply time frame to loc
    wholeloc = readmatrix(strcat('Videos/',session,'/','loc.csv'));
    [~,startframe] = min(abs(camdata.times(:,2)-start));
    [~,stopframe] = min(abs(camdata.times(:,2)-stop));
    loc = wholeloc(startframe:stopframe,:);
else
    loc = readmatrix(strcat('Videos/',session,'/','loc.csv'));
end
disp('loc.csv loaded');

% Remove tongue outliers
loc = cutOutliers(loc,0.95);

% Remove laryngeal and jaw outliers
if size(loc,2) > 9
    for i = [10 11 13 14]
        % Skip if the column is all NaN (18-102119-1)
        if ~isnan(loc(:,i))
            % can choose whether the data needs to be smoothed or not
            % [loc,outliers] = removeOutliers(loc,i,0);
        end
    end
end

end

