function [mato] = removeOutliers(mati,colnum)
% removeOutliers remove outliers of laryngeal or jaw locations
%   INPUT: loc, colnum
%   OUTPUT: loc with the selected col analyzed

mato = mati;

% First step: remove and fill in majority of outliers
col = filloutliers(mati(:,colnum),'linear','movmedian',15);

% Second step: detect remaining outliers using isoutlier(diff(col))
ol = [false(1);isoutlier(diff(col),'gesd')];

% Third step: make ol == 1 if frames nearby are also outliers
for i = 1:size(ol)
    if i ~= 1 && ol(i-1) == 1 && ol(i) == 0
        if sum(ol(i:i+5)) > 0
            ol(i) = true(1);
            for j = 1:5
                if ol(i+j) ~= false(1)   
                    break
                else
                    ol(i+j) = true(1);
                end
            end
        end
    else
        continue
    end
end

% Fourth step: remove and fill in remaining outliers
col = filloutliers(col,'linear','OutlierLocations',ol);

% Fifth step: combine analyzed column to loc
mato(:,colnum) = col;

end

