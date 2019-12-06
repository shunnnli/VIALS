function [] = plotBouts(datatype,bout,floor,ceiling,camdata)
% plotBouts: plot bout boundaries

if strcmp('swallowbout',datatype)
    for i = 1:size(bout,1)
        for j = 1:2
            if bout(i,j) >= floor && bout(i,j) <= ceiling
                if j == 1
                    xline(frame2time(bout(i,j),camdata),'r');
                else 
                    xline(frame2time(bout(i,j),camdata),'--r');
                end
            end
        end
    end
elseif strcmp('lickbout',datatype)
    for i = 1:size(bout,1)
        for j = 6:7
            if bout(i,j) >= floor && bout(i,j) <= ceiling
                if j == 6
                    xline(frame2time(bout(i,j),camdata),'r');
                else 
                    xline(frame2time(bout(i,j),camdata),'--r');
                end
            end
        end
    end
elseif strcmp('tp',datatype)
    for i = 1:size(bout,1)
        for j = 35:36
            if bout(i,j) >= floor && bout(i,j) <= ceiling
                if j == 35
                    xline(bout(i,j),'g');
                else 
                    xline(bout(i,j),'--g');
                end
            end
        end
    end
end

end

