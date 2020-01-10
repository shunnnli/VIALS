function [b,total,pcadata,kmdata] = tpClustering(sessions,version,dim)
% trajectoryPCA: return and plot results of PCA analysis
%   INPUT:
%       sessions: list of sessions to be analyzed
%       version: PCA variable set
%       dimension: dimension of the biplot
%   OUTPUT:
%       total = [sid tpid dur pLen ampX/Y/Z tpDevS/B ilmPer]
%       total = [sid tpid dur pLen ampX/Y/Z tpDevS/B pPer/Vel ilmPer/Vel rPer/Vel]

% Combine tp.csv from session
total = [];
for i = 1:size(sessions,1)
    tp_path = strcat('Videos/',sessions(i),'/tp.csv');
    if isfile(tp_path)
        tp = readmatrix(tp_path);
        disp(strcat('Session: ', sessions(i)));
        sid(1:size(tp,1),1) = i;
        disp(size(sid,1));
        if version == 1
            total = [total; sid tp(:,[1 5 6:11 17])];
        else
            total = [total; sid tp(:,[1 5 6:11 15:20])];
        end
    else
        disp('tp.csv does not exist!');
        disp(strcat('Session: ', sessions(i)));
    end
    sid = 0;
end

% removes tp that tpDevS/B is NaN
total(any(isnan(total(:,8:9)),2),:) = [];
disp(strcat('Total tongue protrusion analyzed:', num2str(size(total,1))));

% Perform PCA analysis
if version == 1
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total(:,3:10)),'VariableWeights','variance');
    varlabels = {'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB','ilmPer'};
    b = biplot(coeff(:,1:dim),'scores',score(:,1:dim),'Varlabels',varlabels);
else
    [coeff,score,latent,tsquared,explained,mu] = pca(zscore(total(:,3:15)),'VariableWeights','variance');
    varlabels = {'dur','pLen','ampX','ampY','ampZ','tpDevS','tpDevB',...
    'pPer','pVel','ilmPer','ilmVel','rPer','rVel'};
    b = biplot(coeff(:,1:dim),'scores',score(:,1:dim),'Varlabels',varlabels);
end
tpPC = score(:,1:2);

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
disp(strcat(num2str(majorPC),' PCs were required to explain >90% of total variance.'));

% Store PCA data
pcadata.coeff = coeff;
pcadata.score = score;
pcadata.latent = latent;
pcadata.tsquared = tsquared;
pcadata.explained = explained;
pcadata.mu = mu;

% Find optimal number of clusters
% CK: mid = left = 4
% DaviesBouldin: mid = 4, left = 3
% gap: left = 3
% silhouette: mid = 4; left = 2
eva = evalclusters(tpPC,'kmeans','CalinskiHarabasz','KList',1:6);
disp(eva);

% GMM clustering
% Fit GMM
options = statset('Display','final'); 
gm = fitgmdist(tpPC,eva.OptimalK,'Options',options);

% Cluster data using fitted GMM
idx = cluster(gm,tpPC);
cluster1 = (idx == 1); % |1| for cluster 1 membership
cluster2 = (idx == 2); % |2| for cluster 2 membership
cluster3 = (idx == 3); 
cluster4 = (idx == 4); 

figure
gscatter(tpPC(:,1),tpPC(:,2),idx,'rbck','+o^.');
legend('C1','C2','C3','C4')

% Estimate cluster membership posterior probabilities
P = posterior(gm,tpPC); 

figure
scatter(tpPC(cluster1,1),tpPC(cluster1,2),10,P(cluster1,1),'+')
hold on
scatter(tpPC(cluster2,1),tpPC(cluster2,2),10,P(cluster2,1),'o')
hold on
scatter(tpPC(cluster3,1),tpPC(cluster3,2),10,P(cluster3,1),'^')
hold on
scatter(tpPC(cluster4,1),tpPC(cluster4,2),10,P(cluster4,1),'.')
hold off
clrmap = jet(80);
colormap(clrmap(9:72,:))
ylabel(colorbar,'Component 1 Posterior Probability')
legend('C1','C2','C3','C4')
title('Scatter Plot and Cluster 1 Posterior Probabilities')


% k-means
%{
% Find optimal number of k-means clusters
clust = zeros(size(tpPC,1),6);
for i=1:6
    clust(:,i) = kmeans(tpPC,i,'emptyaction','singleton','replicate',5);
end
eva = evalclusters(tpPC,clust,'CalinskiHarabasz');
disp(eva);

% Perform k-means clustering
[cluster,centroid,~,d] = kmeans(tpPC,eva.OptimalK);

% Plot k-means clusters
figure
gscatter(tpPC(:,1),tpPC(:,2),cluster);
hold on
plot(centroid(:,1),centroid(:,2),'kx','MarkerSize',10,'LineWidth',2,'DisplayName','Centroids');
legend
xlabel('First Principal Component');
ylabel('Second Principal Component');

% Store K-means data
kmdata.majorPC = majorPC;
kmdata.eva = eva;
kmdata.cluster = cluster;
kmdata.centroid = centroid;
kmdata.d = d;
%}

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
2. https://medium.com/@dmitriy.kavyazin/principal-component-analysis-and-k-means-clustering-to-visualize-a-high-dimensional-dataset-577b2a7a5fe2
3. http://datamining.rutgers.edu/publication/internalmeasures.pdf
%}

end

