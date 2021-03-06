function [loc] = construct3D(side,bottom,swallow)
%construct3D: 3D reconstruction of marker position based on dlc data.
%   x: left/right       --> bottom(i,x)
%   y: forward/backward --> side(i,x) = bottom(i,y)
%   z: up/down          --> side(i,y)
%   OUTPUT:
%       loc = [i xSpout ySpout zSpout lhSpout xTip yTip zTip lhTip
%                xLary yLary lhLary xJaw yJaw lhJaw]

disp('Constructing 3D location...');
loc = [];
[xSpout,ySpout,zSpout,lhSpout,xTip,yTip,zTip,lhTip,...
    xLary,yLary,lhLary,xJaw,yJaw,lhJaw] = deal(0);

% combine x,y,z axis
for i = 1:max([size(side,1),size(bottom,1),size(swallow,1)])
    if ~isempty(bottom)
        xSpout = bottom(i,2);
        xTip = bottom(i,5);
    end
    
    if ~isempty(side)
        ySpout = side(i,2);
        zSpout = side(i,3);
        yTip = side(i,5);
        zTip = side(i,6);
    end
    
    if ~isempty(side) && ~isempty(bottom)
        lhSpout = (side(i,4) + bottom(i,4))/2;
        lhTip = (side(i,7) + bottom(i,7))/2;
    elseif ~isempty(side) && isempty(bottom)
        lhSpout = side(i,4);
        lhTip = side(i,7);
    elseif isempty(side) && ~isempty(bottom)
        lhSpout = bottom(i,4);
        lhTip = bottom(i,7);
    end
    
    if ~isempty(swallow)
        xLary = swallow(i,2);
        yLary = swallow(i,3);
        lhLary = swallow(i,4);

        xJaw = swallow(i,5);
        yJaw = swallow(i,6);
        lhJaw = swallow(i,7);
        
    end

    %{
    if (side(i,4) > 0.95 && bottom(i,4) < 0.95)
        disp(strcat('Spout side:', num2str(i)));
        lhSpout = (side(i,4) + bottom(i,4))/2;
        if lhSpout > 0.95
            disp('---- > 0.95 ----');
        end
    elseif (side(i,4) < 0.95 && bottom(i,4) > 0.95)
        disp(strcat('Spout bottom:', num2str(i)));
        lhSpout = (side(i,4) + bottom(i,4))/2;
        if lhSpout > 0.95
            disp('---- > 0.95 ----');
        end
    else
        lhSpout = (side(i,4) + bottom(i,4))/2;
    end
    
    if (side(i,7) > 0.95 && bottom(i,7) < 0.95)
        disp(strcat('contruct3D TongueTip side:', num2str(i)));
        lhTip = (side(i,7) + bottom(i,7))/2;
        if lhTip > 0.95
            disp('---- > 0.95 ----');
        end
    elseif (side(i,7) < 0.95 && bottom(i,7) > 0.95)
        disp(strcat('contruct3D TongueTip bottom:', num2str(i)));
        lhTip = (side(i,7) + bottom(i,7))/2;
        if lhTip > 0.95
            disp('---- > 0.95 ----');
        end
    else
        lhTip = (side(i,7) + bottom(i,7))/2;
    end
    %}

    % xSpout=2; xTip=6; xLary=10; xJaw=13
    loc = [loc; i xSpout ySpout zSpout lhSpout xTip yTip zTip lhTip...
        xLary yLary lhLary xJaw yJaw lhJaw];

end
end

