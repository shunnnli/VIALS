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
    for col = 1:size(mato,2)
        % Wipe tongue data if overlap with laryngeal
        if size(mati,2) > 9
            xdiff = abs(mato(row,7) - mato(row,10));
            ydiff = abs(mato(row,8) - mato(row,11));
            diff = xdiff + ydiff;
            if diff < 5
                mato(row,6) = NaN;
                mato(row,7) = NaN;
                mato(row,8) = NaN;
            end
        end
        
        % Wipe data if likelihood < cutoff
        if (col == 5 || col == 9) && (mato(row,col) < cutoff)
            mato(row,col-1) = NaN;
            mato(row,col-2) = NaN;
            mato(row,col-3) = NaN;
        elseif (col == 12 || col == 15) && (mato(row,col) < cutoff)
            mato(row,col-1) = NaN;
            mato(row,col-2) = NaN;
        end
    end
end
end

