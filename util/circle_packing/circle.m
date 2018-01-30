% generates a n x 2 array of coordinates corresponding to the circle with
% specified center and radius
function coords = circle(center, radius, n)
THETA = linspace(0, 2 * pi, n);
RHO = ones(1, n) * radius;
[X,Y] = pol2cart(THETA, RHO);
X = X + center(1);
Y = Y + center(2);
coords = [X' Y'];