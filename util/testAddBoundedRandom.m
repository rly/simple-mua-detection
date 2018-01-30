x = 1:10;
nSim = 10000;
x2 = nan(nSim, numel(x));
for i = 1:nSim
    x2(i,:) = addBoundedRandom(1:10, 5, [0 10]);
end

for j = 1:size(x,2)
    figure;
    histogram(x2(:,j));
end
