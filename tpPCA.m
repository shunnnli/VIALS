function [b,total,pcadata,kmdata] = tpPCA(sessions,version,dim)
% trajectoryPCA: return and plot results of PCA analysis
%   INPUT:
%       sessions: list of sessions to be analyzed
%       version: PCA variable set
%       dimension: dimension of the biplot

% Combine tp.csv from session
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
if version == 1
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total),'VariableWeights','variance');
    varlabels = {'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB','ilmPer'};
    b = biplot(coeff(:,1:dim),'scores',score(:,1:dim),'varlabels',varlabels);
else
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total),'VariableWeights','variance');
    varlabels = {'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB',...
    'pPer','pVel','ilmPer','ilmVel','rPer','rVel'};
    b = biplot(coeff(:,1:dim),'scores',score(:,1:dim),'varlabels',varlabels);
end

% Find the number of PC needed to explain >90% of variance
sum = 0;
majorPC = 0;
for i = 1:size(explained,1)
    sum = sum + explained(i);
    if sum >= 90
        majorPC = i;
        break
    end
end
disp(strcat(num2str(majorPC),'PCs were required to explain >90% of total variance.'));

% Find optimal number of k-means clusters
tpPC = score(:,1:2);
clust = zeros(size(tpPC,1),6);
for i=1:6
    clust(:,i) = kmeans(tpPC,i,'emptyaction','singleton','replicate',5);
end
eva = evalclusters(tpPC,clust,'CalinskiHarabasz');
disp(eva);

% Perform k-means clustering
[cluster,centroid] = kmeans(tpPC,eva.OptimalK);

% Plot k-means clusters
figure
gscatter(tpPC(:,1),tpPC(:,2),cluster);
hold on
plot(centroid(:,1),centroid(:,2),'kx','MarkerSize',10,'LineWidth',2,'DisplayName','Centroids');
legend
xlabel('First Principal Component');
ylabel('Second Principal Component');

% Store PCA data
pcadata.coeff = coeff;
pcadata.score = score;
pcadata.latent = latent;
pcadata.tsquared = tsquared;
pcadata.explained = explained;
pcadata.mu = mu;

% Store K-means data
kmdata.majorPC = majorPC;
kmdata.eva = eva;
kmdata.cluster = cluster;
kmdata.centroid = centroid;

% Full labels
%{
b = biplot(coeff(:,1:2),'scores',score(:,1:2), ...
    'varlabels',{'dur','il','pLen',...
    'ampX','ampY','ampZ','tpDevS','tpDevB','tpMX','tpMY','tpMZ',...
    'pPer','pVel','ilmPer','ilmVel','rPer','rVel'});
%}

% Related materials
%{
PCA materials:
1. https://courses.engr.illinois.edu/bioe298b/sp2018/Lecture%20Examples/23%20PCA%20slides.pdf
2. https://www.researchgate.net/post/What_is_the_best_way_to_scale_parameters_before_running_a_Principal_Component_Analysis_PCA
3. https://stats.stackexchange.com/questions/53/pca-on-correlation-or-covariance
4. https://www.mathworks.com/help/stats/pca.html

K-means materials:
1. https://www.mathworks.com/products/demos/machine-learning/cluster-genes.html
%}

end

