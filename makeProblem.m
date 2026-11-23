function p = makeProblem(assignment, parameter)
% MAKEPROBLEM Prepare the geometry, loads, supports and area constraints.
% Units: coordinates in mm, forces in N, Young's modulus in N/mm^2.
%
% The output field names are kept compatible with the original solvers.

% 1. Load the prescribed ground structure.
folder = fileparts(mfilename('fullpath'));
dataFolder = fullfile(folder, 'data', sprintf('assignment%d', assignment));

p.nodes = load(fullfile(dataFolder, 'nodes.txt'));
p.elements = load(fullfile(dataFolder, 'elements.txt'));
p.n_el = size(p.elements, 1);
p.assignment = assignment;
p.E = 210000;

% 2. Specify the appropriate assignment.
if assignment == 1
    p.alpha = parameter;

    % At X = 0, restrain both translations (DOFs 1 and 2) of each node.
    fixedNodes = find(p.nodes(:, 1) == 0);
    fixedDirections = repmat([1; 2], numel(fixedNodes), 1);
    p.constr = [repelem(fixedNodes, 2), fixedDirections];

    % Each row is [node, direction, force]. Direction 2 = vertical.
    p.loads = {[49, 2, -6000]};
    p.weights = 1;

    minimumArea = 0.0001;
    maximumArea = 800;

elseif assignment == 2
    assert(parameter >= 0 && parameter <= 1, ...
        'Weight must lie in [0,1].');

    p.alpha = 0.1;
    p.constr = [17, 1; 17, 2; 9, 2];

    % Separate braking and acceleration load cases; do not add them.
    brakingLoads = [8, 1, -13000; 8, 2, 2000; 9, 1, 9000];
    accelerationLoads = [1, 1, 2000; 1, 2, -8000];
    p.loads = {brakingLoads, accelerationLoads};
    p.weights = [parameter; 1 - parameter];

    minimumArea = 0.001;
    maximumArea = 700;

else
    error('Assignment must be 1 or 2.');
end

% 3. Apply area limits to every element.
p.x_lb = minimumArea * ones(p.n_el, 1);
p.x_ub = maximumArea * ones(p.n_el, 1);

% 4. Compute the volume budget and its gradient.
[p.Vmax, p.lengths] = computeVolume(p.x_ub, p.nodes, p.elements);
p.V = p.alpha * p.Vmax;
p.grad_constr = gradConstr(p.nodes, p.elements);
p.computeVolume = @computeVolume;

% 5. Start with equal areas that use the allowed total volume.
initialArea = p.V / sum(p.lengths);
p.x0 = initialArea * ones(p.n_el, 1);

assert(all(p.x0 >= p.x_lb & p.x0 <= p.x_ub), ...
    'Infeasible volume fraction.');
end
