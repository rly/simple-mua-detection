function x = addBoundedRandom(x, absMaxJitter, bounds)
% given x, add or subtract random value (uniform distribution) up to 
% absMaxJitter, bounded by bounds

lb = max(bounds(1), x - absMaxJitter) - x;
ub = min(bounds(2), x + absMaxJitter) - x;
randChange = rand(size(x)) .* (ub-lb) + lb;

x = x + randChange;