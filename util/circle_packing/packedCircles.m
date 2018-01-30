function [centerCoords, ratio] = packedCircles(N)

cciFile = fopen(sprintf('cci%d.txt', N));
A = textscan(cciFile, '%d %f %f');
fclose(cciFile);
centerCoords = [A{2} A{3}];

ratioFile = fopen(sprintf('ratio.txt'));
A = textscan(ratioFile, '%d %f');
fclose(ratioFile);
assert(A{1}(N) == N);
ratio = A{2}(N);