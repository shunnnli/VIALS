function mato = cutOutliers(mati,cutoff)
% cutOutliers: fill tongue location with NaN is likelihood < cutoff or
%               overlap with laryngeal location

% INPUT: 
%       mati: input matrix
%       cutoff: threshold likelihood
% OUTPUT:
%       mato: output matrix

mato = mati;
for row = 1:size(mato,1)
    % Wipe tongue data if overlap with laryngeal/jaw
    if size(mati,2) > 9
        xldiff = abs(mato(row,7) - mato(row,10));
        yldiff = abs(mato(row,8) - mato(row,11));
        xjdiff = abs(mato(row,7) - mato(row,13));
        yjdiff = abs(mato(row,8) - mato(row,14));
        ldiff = xldiff + yldiff;
        jdiff = xjdiff + yjdiff;
        if ldiff < 5
            % disp(jdiff);
            mato(row,6) = NaN;
            mato(row,7) = NaN;
            mato(row,8) = NaN;
        end
    end
    for col = 1:size(mato,2)        
        % Wipe data if likelihood < cutoff
        if (col == 5 || col == 9) && (mato(row,col) < cutoff)
            mato(row,col-1) = NaN;
            mato(row,col-2) = NaN;
            mato(row,col-3) = NaN;
        end
    end
end
end

