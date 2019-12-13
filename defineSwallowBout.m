function bout = defineSwallowBout(loc,dlarydx,windowsize,threshold)
%defineSwalllowBout
% INPUT:
%       loc, dlarydx (y-axis), windowsize, threshold
% OUTPUT:
%       bout = [boutstart boutend restlaryx restlaryy restjawx restjawy]

% bout start if: 
%   sum of absolute value of next 20 derivatives > 10
%   and sum of absolute changes in location of next 20 frames > 10
% Resting marker location:
%   averaged marker location during preceeding bout interval

bout = [];
bouton = 0;
boutstart = 0;
boutend = 0;

for i = 1:size(dlarydx,1)
    % If potential boutend (i+windowsize) larger than dlarydx
    if i + windowsize > size(dlarydx,1)
        if bouton == 1
            boutend = size(dlarydx,1);
            % Get resting marker location
            %{
            low = bout(size(bout,1)-1,2);
            high = boutend;
            restlaryx = mean(loc(low:high,10),'omitnan');
            restlaryy = mean(loc(low:high,11),'omitnan');
            restjawx = mean(loc(low:high,13),'omitnan');
            restjawy = mean(loc(low:high,14),'omitnan');
            %}
            % Write bout
            % new_row = [boutstart boutend restlaryx restlaryy restjawx restjawy];
            new_row = [boutstart boutend];
            bout = [bout;new_row];
        end
        break
    end
    
    [sum,~] = sumabs(dlarydx(i:i+windowsize));
    diff = abs(loc(i,11)-loc(i+windowsize,11));
    % start bout if the condition is satisfied
    if sum > threshold && bouton == 0 && diff > 0.35
        bouton = 1; 
        boutstart = i;
        boutend = i + windowsize;
        % switch previous boutend and boutstart
        if size(bout,1) > 0 && boutstart < bout(size(bout,1),2)
            temp = boutstart;
            boutstart = bout(size(bout,1),2);
            bout(size(bout,1),2) = temp;
        end
    % continue bout and extend potential boutend
    elseif sum > threshold && bouton == 1
        if i+windowsize > boutend
            boutend = i + windowsize;
        end
    % end bout
    elseif sum < threshold && bouton == 1
        bouton = 0;
        % Get resting marker location
        %{
        if size(bout,1) == 0
            if boutstart == 0
                disp('No preceeding interval!');
            end
            low = 1;
            high = boutstart;
        else
            low = bout(size(bout,1),2);
            high = boutstart;
        end
        restlaryx = mean(loc(low:high,10),'omitnan');
        restlaryy = mean(loc(low:high,11),'omitnan');
        restjawx = mean(loc(low:high,13),'omitnan');
        restjawy = mean(loc(low:high,14),'omitnan');
        %}
        % Write bout
        % new_row = [boutstart boutend restlaryx restlaryy restjawx restjawy];
        new_row = [boutstart boutend];
        bout = [bout;new_row];
    end
end

end

