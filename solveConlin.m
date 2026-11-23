function result = solveConlin(p, options)
% SOLVECONLIN Minimize compliance using CONLIN and a scalar dual solve.
% Uses the original FEM and KKT checks; no SIMP, MMA or move limits.

% 1. Set default solver options if the caller did not provide them.
if nargin < 2
    options = struct;
end
if ~isfield(options, 'maxIter')
    options.maxIter = 10000;
end
if ~isfield(options, 'objectiveTolerance')
    options.objectiveTolerance = 1e-9;
end
if ~isfield(options, 'kktTolerance')
    options.kktTolerance = 2e-4;
end
if ~isfield(options, 'dualSolver')
    options.dualSolver = 'auto';
end

% 2. Analyze the initial design and prepare the iteration history.
x = p.x0;
analysis = analyzeDesign(x, p);
lambda = max(-analysis.gradient ./ p.lengths) / 4;

numberOfCases = numel(p.loads);
numberOfDofs = size(analysis.u, 1);
numberOfRecords = options.maxIter + 1; % Includes iteration zero.

history.objective = zeros(numberOfRecords, 1);
history.volume = zeros(numberOfRecords, 1);
history.C = zeros(numberOfRecords, numberOfCases);
history.x = zeros(numberOfRecords, p.n_el);
history.u = zeros(numberOfDofs, numberOfCases, numberOfRecords);
history.lambda = nan(numberOfRecords, 1);
history.kkt = nan(numberOfRecords, 1);

history.objective(1) = analysis.objective;
history.volume(1) = analysis.volume;
history.C(1, :) = analysis.C';
history.x(1, :) = x';
history.u(:, :, 1) = analysis.u;

startTime = tic;
converged = false;

% 3. Repeatedly propose an area update and check the true FEM solution.
for iteration = 1:options.maxIter
    % Pass the current compliance gradient to the dual optimizer.
    p.grad_of = analysis.gradient;
    [lambda, newAreas, method] = solveDual(x, p, lambda, options.dualSolver);

    % Do not judge convergence using only the CONLIN approximation.
    newAnalysis = analyzeDesign(newAreas, p);

    % KKT stationarity for the original objective and the volume multiplier.
    stationarity = newAnalysis.gradient + lambda * p.lengths;

    atLowerBound = newAreas <= p.x_lb + 1e-10;
    atUpperBound = newAreas >= p.x_ub - 1e-8;

    % At the bounds, only the violating direction counts as a residual.
    stationarity(atLowerBound) = min(stationarity(atLowerBound), 0);
    stationarity(atUpperBound) = max(stationarity(atUpperBound), 0);

    kktResidual = max(abs(stationarity) ./ ...
        max(lambda * p.lengths, 1e-14));
    relativeChange = abs(newAnalysis.objective - analysis.objective) / ...
        max(abs(analysis.objective), 1);

    % Store the new design and its true structural response.
    record = iteration + 1;
    history.objective(record) = newAnalysis.objective;
    history.volume(record) = newAnalysis.volume;
    history.C(record, :) = newAnalysis.C';
    history.x(record, :) = newAreas';
    history.u(:, :, record) = newAnalysis.u;
    history.lambda(record) = lambda;
    history.kkt(record) = kktResidual;

    % Continue from the newly analyzed design.
    x = newAreas;
    analysis = newAnalysis;

    if relativeChange < options.objectiveTolerance && ...
            kktResidual < options.kktTolerance
        converged = true;
        break;
    end
end

% 4. Remove unused rows from the preallocated history.
fields = {'objective', 'volume', 'C', 'x', 'lambda', 'kkt'};
for j = 1:numel(fields)
    fieldName = fields{j};
    history.(fieldName) = history.(fieldName)(1:record, :);
end
history.u = history.u(:, :, 1:record);
history.iteration = (0:iteration)';
history.constraint = history.volume - p.V;

% 5. Return the complete result using the original field names.
result.problem = p;
result.x = x;
result.analysis = analysis;
result.history = history;
result.iterations = iteration;
result.converged = converged;
result.lambda = lambda;
result.kkt = kktResidual;
result.seconds = toc(startTime);
result.dualSolver = method;
result.options = options;

if ~converged
    warning('CONLIN:MaxIterations', ...
        'KKT %.3g after %d iterations.', kktResidual, iteration);
end
end
