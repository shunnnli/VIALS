function [b,coeff,score,latent,tsquared,explained,mu] = trajectoryPCA(sessions,version)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
% 1 -> not including phase, 2 -> including phase

% Combine tp.csv from session
% pathLen, tpDevS/B, tpMax, ilmPercent
all = [];
for i = 1:size(sessions,1)
    tp_path = strcat('Videos/',sessions(i),'/tp.csv');
    if isfile(tp_path)
        tp = readmatrix(tp_path);
        if version == 1
            all = [all; tp(:,[6 11 12:14])];
        else
            all = [all; tp(:,[6 11 12:14 17])];
        end
    else
        disp('tp.csv does not exist!');
        disp(strcat('Session: ', sessions(i)));
    end
end
disp(strcat('Total tongue protrusion analyzed:', num2str(size(all,1))));

if version == 1
    [coeff,score,latent,tsquared,explained,mu] = pca(all);
    b = biplot(coeff(:,1:2),'scores',score(:,1:2), ...
        'varlabels',{'pLen','tpDevS','tpMX','tpMY','tpMZ'});
else
    [coeff,score,latent,tsquared,explained,mu] = pca(all);
    b = biplot(coeff(:,1:2),'scores',score(:,1:2), 'varlabels',...
        {'pLen','tpDevS','tpMX','tpMY','tpMZ','ilmPer'});
end

% Full labels
%{
b = biplot(coeff(:,1:2),'scores',score(:,1:2), ...
    'varlabels',{'dur','il','pLen',...
    'ampX','ampY','ampZ','tpDevS','tpDevB','tpMX','tpMY','tpMZ',...
    'pPer','pVel','ilmPer','ilmVel','rPer','rVel'});
%}

end

