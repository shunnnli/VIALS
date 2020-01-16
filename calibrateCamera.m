function [side,bottom,swallow] = calibrateCamera(sideloc,bottomloc,swallowloc,...
                                    ratio,laryheight,jawheight)
%calibrateCamera: Calibrate camera based pixel distance of 5 mm
%   INPUT:
%       sidelen = pixel distance of 5 mm in side camera
%       bottomlen = pixel distance of 5 mm in bottom camera
%       sideloc, bottomloc
%   OUTPUT:
%       side: calibrated marker locations from side view
%       bottom: calibrated marker locations from bottom view

disp('Calibrating camera...');

% reverse y axis
yreverse = [1 1 -1 1 1 -1 1];
ysize = [0 0 480 0 0 480 0];

% apply side/bottom ratio
sscale = [1 ratio(1) ratio(2) 1 ratio(1) ratio(2) 1];
bscale = [1 ratio(3) ratio(4) 1 ratio(3) ratio(4) 1];

% minus marker height in swallowing y axis
marker = [0 0 laryheight 0 0 jawheight 0]; 

if ~isempty(sideloc)
    side = bsxfun(@times,bsxfun(@plus,bsxfun(@times,sideloc,yreverse),ysize),sscale);
else
    side = [];
end

if ~isempty(bottomloc)
    bottom = bsxfun(@times,bsxfun(@plus,bsxfun(@times,bottomloc,yreverse),ysize),bscale);
else
    bottom = [];
end

if ~isempty(swallowloc)
    swallow = bsxfun(@minus,bsxfun(@times,bsxfun(@plus,bsxfun(@times,swallowloc,yreverse),ysize),sscale),marker);
else
    swallow = [];
end

end

