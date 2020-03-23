function [mato,outliers] = removeOutliers(mati,colnum,smoothON)
% removeOutliers remove outliers of laryngeal or jaw locations
%   INPUT: loc, colnum
%   OUTPUT: loc with the selected col analyzed

mato = mati;

% First step: remove and fill in majority of outliers
col = filloutliers(mati(:,colnum),'linear','movmedian',15);

% Second step: detect remaining outliers using isoutlier(diff(col))
ol = [false(1);isoutlier(diff(col),'gesd')];

% Third step: make ol == 1 if frames nearby are also outliers
for i = 1:size(ol)-5
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
% disp(strcat('Total outliers removed:',num2str(F1+F2)));

% Fifth step: combine analyzed column to loc
if smoothON == 1
    mato(:,colnum) = smoothdata(col,'movmedian',3);
    disp('Data smoothing on: moving median 3');
else
    mato(:,colnum) = col;
end

% Stored removed outliers
outliers.salient = col;
outliers.subtle = ol;
disp(outliers);

end

