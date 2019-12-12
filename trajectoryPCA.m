function [b,total,pcadata] = trajectoryPCA(sessions,version,dimension)
% trajectoryPCA: return and plot results of PCA analysis
%   INPUT:
%       sessions: list of sessions to be analyzed
%       version: PCA variable set
%       dimension: dimension of the biplot

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

% Perform PCA analysis 
b = figure;
if version == 1
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total),'VariableWeights','variance');
    biplot(coeff(:,1:dimension),'scores',score(:,1:dimension), 'varlabels',...
        {'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB','ilmPer'});
else
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total),'VariableWeights','variance');
    biplot(coeff(:,1:dimension),'scores',score(:,1:dimension), ...
    'varlabels',{'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB',...
    'pPer','pVel','ilmPer','ilmVel','rPer','rVel'});
end

% Store PCA data in a struct array
pcadata.coeff = coeff;
pcadata.score = score;
pcadata.latent = latent;
pcadata.tsquared = tsquared;
pcadata.explained = explained;
pcadata.mu = mu;

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
2. https://www.researchgate.net/post/What_is_the_best_way_to_scale_parameters_before_running_a_Principal_Component_Analysis_PCA
3. https://stats.stackexchange.com/questions/53/pca-on-correlation-or-covariance
4. https://www.mathworks.com/help/stats/pca.html
%}

end

