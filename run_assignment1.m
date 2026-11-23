function results = run_assignment1(options)
% RUN_ASSIGNMENT1 Optimize all four material fractions for Assignment 1.
% Returns a cell array of solver results and displays the required plots.

if nargin < 1
    options = struct;
end

materialFractions = [0.05, 0.10, 0.15, 0.20];
elementsToReport = [64, 77, 82];

results = cell(numel(materialFractions), 1);
selectedResults = zeros(numel(materialFractions) * numel(elementsToReport), 6);

% 1. Solve and plot each material-budget case.
figure('Visible', 'on', 'Theme', 'light', 'Position', [50, 50, 1400, 950]);
tiledlayout(2, 2, 'Padding', 'loose', 'TileSpacing', 'loose');

for caseIndex = 1:numel(materialFractions)
    alpha = materialFractions(caseIndex);

    problem = makeProblem(1, alpha);
    solution = solveConlin(problem, options);
    results{caseIndex} = solution;

    fprintf('Alpha %.2f: compliance %.6f N mm (%d iterations)\n', ...
        alpha, solution.analysis.objective, solution.iterations);

    nexttile;
    plotTitle = sprintf('alpha = %.2f; C = %.2f N mm', ...
        alpha, solution.analysis.objective);
    plotStructure(problem, solution.x, plotTitle);

    % Save the member connectivity, area and signed stress for reporting.
    for selectedIndex = 1:numel(elementsToReport)
        elementIndex = elementsToReport(selectedIndex);
        tableRow = numel(elementsToReport) * (caseIndex - 1) + selectedIndex;

        selectedResults(tableRow, :) = [ ...
            alpha, ...
            elementIndex, ...
            problem.elements(elementIndex, :), ...
            solution.x(elementIndex), ...
            solution.analysis.stress(elementIndex) ...
        ];
    end
end

% 2. Plot objective and volume histories for the four cases.
figure('Visible', 'on', 'Theme', 'light', 'Position', [50, 50, 1400, 950]);
tiledlayout(2, 2, 'Padding', 'loose', 'TileSpacing', 'loose');

for caseIndex = 1:numel(materialFractions)
    solution = results{caseIndex};
    history = solution.history;

    nexttile;
    yyaxis left;
    plot(history.iteration, history.objective, 'LineWidth', 1.5);
    ylabel('Compliance [N mm]');

    yyaxis right;
    plot(history.iteration, history.volume / solution.problem.V, 'LineWidth', 1.5);
    hold on;
    yline(1, '--');
    ylim([0, 1.1]);
    ylabel('V / Vlimit');

    xlabel('Iteration');
    grid on;
    title(sprintf('alpha = %.2f', materialFractions(caseIndex)));
end

% 3. Print the required area/stress table.
columnNames = {'Alpha', 'Element', 'NodeA', 'NodeB', 'Area_mm2', 'Stress_MPa'};
disp(array2table(selectedResults, 'VariableNames', columnNames));
end
