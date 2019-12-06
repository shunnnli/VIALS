function [dydx] = calcDerivative(x,y)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

dx = diff(x);
dy = diff(y);
dydx = dy./dx;

end

