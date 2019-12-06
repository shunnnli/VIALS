%%% load excel data %%%
[~, ~, data] = xlsread('/Users/shunli/Desktop/licklog.xlsx');
parameters = cell2mat(data(:, 5: 9));
lf = cell2mat(data(:, 12));

%%% find behavior setups %%%
[ids, ia, ib] = unique(parameters, 'rows');

%%% find corresponding sessions %%%
lfmean = zeros(1, length(ids));
lfstd = zeros(1, length(ids));
for i = 1: length(ids)
    idt = ib == i;
    lfmean(i) = mean(lf(idt));
    lfstd(i) = std(lf(idt));
end
lfstd(lfstd == 0) = NaN;

%%% mouse id number %%%
mouseid = cell2mat(data(:, 1));
mn = zeros(1, length(ids));
for i = 1: length(ids)
    idt = ib == i;
    mn(i) = length(unique(mouseid(idt)));
end

%%% visualization %%%
figure(1)
clf
bar(lfmean)
hold on
errorbar(lfmean, lfstd / 2, 'linestyle', 'none')
plot(mn, 'ok')





