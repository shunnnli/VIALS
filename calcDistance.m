function dist = calcDistance(locA,locB,signed)
% calcDistance: Calculate euclidean distance between two points
% if signed == 1, signed distance

if signed == 0
    if size(locA,2) ~= size(locB,2)
        disp('Inconsistant dimension!');
    elseif size(locA,2) == 1
        dist = sqrt((locB(1)-locA(1))^2);
    elseif size(locA,2) == 2
        dist = sqrt((locB(1)-locA(1))^2 + (locB(2)-locA(2))^2);
    else
        dist = sqrt((locB(1)-locA(1))^2 + (locB(2)-locA(2))^2 + (locB(3)-locA(3))^2);
    end
else
    if size(locA,2) ~= size(locB,2)
        disp('Inconsistant dimension!');
    elseif size(locA,2) == 1
        dist = locB(1)-locA(1);
    elseif size(locA,2) == 2
        if locB(2) > locA(2)
            dist = sqrt((locB(1)-locA(1))^2 + (locB(2)-locA(2))^2);
        else
            dist = - sqrt((locB(1)-locA(1))^2 + (locB(2)-locA(2))^2);
        end
    else
        dist = sqrt((locB(1)-locA(1))^2 + (locB(2)-locA(2))^2 + (locB(3)-locA(3))^2);
    end
end

if isnan(locA(1)) || isnan(locB(1))
    dist = 0;
end

end

