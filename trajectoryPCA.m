function [b,total,coeff,score,latent,tsquared,explained,mu] = trajectoryPCA(sessions,version)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
% 1 -> not including phase, 2 -> including phase

% Combine tp.csv from session
% pathLen, tpDevS/B, tpMax, ilmPercent
total = [];
for i = 1:size(sessions,1)
    tp_path = strcat('Videos/',sessions(i),'/tp.csv');
    if isfile(tp_path)
        tp = readmatrix(tp_path);
        if version == 1
            total = [total; tp(:,[5 6:11 17])];
        else
            total = [total; tp(:,[5 6:11 15:20])];
        end
    else
        disp('tp.csv does not exist!');
        disp(strcat('Session: ', sessions(i)));
    end
end

% removes tp that tpDevS/B is NaN
total(any(isnan(total(:,6:7)),2),:) = [];
disp(strcat('Total tongue protrusion analyzed:', num2str(size(total,1))));

if version == 1
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total));
    b = biplot(coeff(:,1:2),'scores',score(:,1:2), 'varlabels',...
        {'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB','ilmPer'});
else
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total));
    b = biplot(coeff(:,1:2),'scores',score(:,1:2), ...
    'varlabels',{'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB',...
    'pPer','pVel','ilmPer','ilmVel','rPer','rVel'});
end

% Full labels
%{
b = biplot(coeff(:,1:2),'scores',score(:,1:2), ...
    'varlabels',{'dur','il','pLen',...
    'ampX','ampY','ampZ','tpDevS','tpDevB','tpMX','tpMY','tpMZ',...
    'pPer','pVel','ilmPer','ilmVel','rPer','rVel'});
%}

% Related materials
%{
1. https://courses.engr.illinois.edu/bioe298b/sp2018/Lecture%20Examples/23%20PCA%20slides.pdf

%}

end

