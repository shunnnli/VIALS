function sli = calcSLI(frame,loc,tp,mode)
% calcSLI: calculate swallow likelihood index (SLI) of a given larynx
% marker elevation (licking/oral phase/pharyngeal phase)
%       *: step/continuous
% Design of logistic function:
%       x0 = the x-value of the sigmoid's midpoint
%       L = the curve's maximum value, and
%       k = the logistic growth rate or steepness of the curve
% SLI continuous design:
%       SLI = logistic(ylaryper,lthper,0.5) + logistic(yjawper,jthper,0.5)...
%             relu(logistic((tplloc*10-8),5,1)) ...
%               - relu(logistic(plenper,0,1));

% Reverse percentile: [0,10]
rpctile = @(array,value) reshape(mean(bsxfun(@le,array(:),value(:).'))*10,size(value));
% Logistic function: -10 + 20./(1 + e^(-1(x-5)))
logistic = @(x,x0,k) -10 + 20./(1 + exp(-k*(x-x0)));

xlary = loc(:,10); ylary = loc(:,11); 
xjaw = loc(:,13); yjaw = loc(:,14); % hdiff = loc(:,11) - loc(:,14);
xlaryloc = loc(frame,10); ylaryloc = loc(frame,11); 
xjawloc = loc(frame,13); yjawloc = loc(frame,14); plen = tp(:,6);
tplloc = loc(frame,9)*10; % hdiffloc = hdiff(frame);

jawtif = nanmean(loc(tp(:,36),[13,14]));  % mean jaw position during tongueInFrame
jawtin = nanmean(loc(tp(:,36)+1,[13,14]));    % mean jaw position during tIF+1
xjawthres = (jawtif(1)+jawtin(1))/2;
yjawthres = (jawtif(2)+jawtin(2))/2;
xjthper = rpctile(xjaw,xjawthres);
yjthper = rpctile(yjaw,yjawthres);

larytif = nanmean(loc(tp(:,36),[10,11]));  % mean lary position during tongueInFrame
larytin = nanmean(loc(tp(:,36)+1,[10,11]));    % mean lary position during tIF+1
xlarythres = (larytif(1)+larytin(1))/2;
ylarythres = (larytif(2)+larytin(2))/2;
xlthper = rpctile(xlary,xlarythres);
ylthper = rpctile(ylary,ylarythres);
% hdiffthres = larythres - jawthres;
% hthper = rpctile(hdiff,hdiffthres);

tpRange = tp(:,35:36);
tpid = find(frame >= tpRange(:,1) & frame <= tpRange(:,2), 1);
if isempty(tpid)
    plenloc = 0;
else
    plenloc = tp(tpid,6);
end

if strcmp(mode,'step')
    % nothing for now
elseif strcmp(mode,'cont')
    xlaryper = rpctile(xlary,xlaryloc);
    xjawper = rpctile(xjaw,xjawloc);
    ylaryper = rpctile(ylary,ylaryloc);
    yjawper = rpctile(yjaw,yjawloc);
    % hdiffper = rpctile(hdiff,hdiffloc);
    % disp(ylarythres);
    
    if tplloc < 8.5
        tplloc = 5; % logistic(5,5,1) = 0
    end
    if plenloc <= 0
        % if plen = 0, does not penalize
        plenlog = 0; 
    else
        % if plen > 0, penalize
        plenper = rpctile(plen,plenloc);
        plenlog = logistic(plenper,0,2);
        if plenlog <= 0
            plenlog = 0;
        end
    end
    sli = logistic(xlaryper,xlthper,0.5)...
         + logistic(ylaryper,ylthper,0.5) + logistic(yjawper,yjthper,0.5)...
         - logistic(tplloc,5,1) - plenlog;
else
    disp('Mode input error!');
end
    

end

