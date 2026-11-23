
function [lambda, x, method] = solveDual(xk, p, previous, requested)

% Solve the CONLIN dual equation using fsolve.
% We want to find lambda such that the updated volume equals p.V.

method = 'fsolve';

% Check whether the volume constraint is inactive.
[volumeResidual, x] = gradPhi(0, xk, p);

if volumeResidual <= 0
    lambda = 0;
    return
end

% Scale lambda to improve numerical conditioning.
scale = max(previous, 1e-12);

% Normalized dual equation.
dualEquation = @(t) gradPhi(t * scale, xk, p) / p.V;

% Solve for lambda.
options = optimset('Display', 'off', ...
    'TolFun', 1e-11, ...
    'TolX', 1e-11);

t = fsolve(dualEquation, 1, options);

lambda = t * scale;

% Compute updated areas using the calculated multiplier.
[~, x] = gradPhi(lambda, xk, p);

end
