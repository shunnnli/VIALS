function [dydx] = calcDerivative(x,y)

dx = diff(x);
dy = diff(y);
dydx = dy./dx;

end

