function [value,index] = findClosest(A,B)
% findClosest: Find the closest element of B from A

value = [];
index = [];

for i = 1:size(B,1)
    [~,ind] = min(abs(A-B(i)));
    index = [index;ind];
    value = [value;A(ind)];
end

end

