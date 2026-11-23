# Assignment 1 and Assignment 2: numerical report

## Scope and computational assessment

Both assignments were implemented and executed in MATLAB R2026b using the supplied geometry and the course truss/CONLIN formulation. Assignment 1 has 77 nodes, 200 bars and 144 free displacement DOFs. Assignment 2 has 17 nodes, 55 bars and 31 free DOFs, with two load cases. These are small problems: the first validated run took 1.31-9.43 seconds per Assignment 1 optimization and 0.07-1.23 seconds per motorcycle weight. Total optimization time was about 22 seconds, excluding MATLAB startup, tests, plot export and file I/O. Implementation, source review and verification are the substantial part of the work; these tasks do not require an hour of numerical computation.

## Methods and reproduction

The design variables are bar areas. Both models use axial, pin-jointed, small-displacement linear elasticity with E=210000 N/mm^2. The prescribed geometry, area bounds, support directions and nodal loads are encoded in `makeProblem.m`. Assignment 1 restrains both translations of nodes at x=0 and loads node 49 with -6000 N in y. Assignment 2 restrains node 17 in both directions and node 9 in y, following the support diagram. Braking loads are (-13000,2000) N at node 8 and (9000,0) N at node 9; acceleration is (2000,-8000) N at node 1.

At each iteration the reduced equilibrium system is solved, compliance sensitivities are evaluated analytically, and a reciprocal CONLIN objective is minimized through the scalar volume multiplier. The volume constraint remains exactly linear. A uniform feasible initial design is used independently for every scenario. The original positive lower bounds remain in the numerical model. Stress and displacement results are postprocessing, not additional design constraints.

$$k_j=x_j(E/L_j)b_j^Tb_j,\quad C=F^Tu,\quad V=\sum_jL_jx_j,\quad C_{,j}=-u_j^Tk_j^0u_j.$$

$$q_j=-C_{,j}(x_j^k)^2,\qquad x_j^*(\lambda)=\operatorname{clip}\left(\sqrt{q_j/(\lambda L_j)},x_{min},x_{max}\right),\qquad \sum_jL_jx_j^*(\lambda)=V_{limit}.$$

The template uses `fsolve`. This installation lacks Optimization Toolbox files, so all reported executions used the explicitly declared base-MATLAB `fzero` path to solve that same dual equation. The included `fsolve` path has not been executed here. Thus the mathematical method matches the class, but literal use of the named classroom root solver remains unverified. `run_all('fsolve')` selects it explicitly on an installation with Optimization Toolbox. See README for commands and file roles.

Convergence requires a relative objective change below 1e-9 and a relative, box-aware KKT stationarity residual below 2e-4. The iteration limit is 10000. This replaces the teaching template's fixed 100 history entries with an actual convergence check; it does not alter the model or update formula. Initial history entries correspond to iteration 0.

## Assignment 1 results

| Volume fraction | Compliance [N mm] | Volume [mm^3] | Updates | Relative KKT residual |
|---:|---:|---:|---:|---:|
| 0.05 | 27005.012433 | 6500386.720 | 311 | 0.000169 |
| 0.10 | 13503.584324 | 13000773.439 | 338 | 0.000175 |
| 0.15 | 9450.047988 | 19501160.159 | 740 | 0.0002 |
| 0.20 | 7481.271475 | 26001546.879 | 3230 | 0.000176 |

The volume allowance is active in all four cases. Compliance decreases as the allowance increases, as expected because the feasible set expands. The nearly inverse relation between compliance and volume in the first two cases starts to break down as the area ceiling becomes active.

![Optimized structures](C:/Users/carlo/topology/solutions/results/assignment1/optimized_structures.png)

Figure 1. Optimized ground structures; line widths use a common 800 mm^2 scale. Light grey indicates bars at their lower bound. Squares mark restrained nodes and E labels identify the requested elements. Lower-bound bars remain in all equilibrium calculations.

![Iteration histories](C:/Users/carlo/topology/solutions/results/assignment1/iteration_histories.png)

Figure 2. True compliance and normalized volume histories. The flat volume curves are expected: the initial point and each dual solution exhaust the same allowance while areas are redistributed. Raw histories include the signed constraint V-Vlimit.

### Requested element areas and stresses

| Alpha | Element | Nodes | Area [mm^2] | Signed stress [MPa] |
|---:|---:|---|---:|---:|
| 0.05 | 64 | 46-47 | 406.273615 | 29.536732 |
| 0.05 | 77 | 53-52 | 203.136778 | -29.536732 |
| 0.05 | 82 | 57-24 | 287.278282 | -29.536732 |
| 0.10 | 64 | 46-47 | 800.000000 | 14.999997 |
| 0.10 | 77 | 53-52 | 408.365123 | -14.692730 |
| 0.10 | 82 | 57-24 | 577.514982 | -14.692730 |
| 0.15 | 64 | 46-47 | 800.000000 | 14.447407 |
| 0.15 | 77 | 53-52 | 654.118269 | -9.172651 |
| 0.15 | 82 | 57-24 | 800.000000 | -9.173630 |
| 0.20 | 64 | 46-47 | 800.000000 | 13.185192 |
| 0.20 | 77 | 53-52 | 800.000000 | -7.499998 |
| 0.20 | 82 | 57-24 | 800.000000 | -8.040073 |

Positive stress denotes tension, negative stress compression. At alpha=0.05, elements 64, 77 and 82 are interior to their area bounds and have the same absolute stress (29.536732 MPa), despite different areas. This is the expected KKT result: C_,j=-L_j*sigma_j^2/E and C_,j+lambda*L_j=0 imply abs(sigma_j)=sqrt(E*lambda) for interior areas.

At alpha=0.10, element 64 reaches 800 mm^2 and its stress magnitude is 15 MPa, while interior elements 77 and 82 remain equal at 14.692730 MPa. At alpha=0.15, elements 64 and 82 are at their upper bounds; element 82 happens to be only just beyond the interior stress level. At alpha=0.20, all three selected members are capped, and equal absolute stress is no longer required. An upper-bound bar satisfies sigma_j^2/E >= lambda; a lower-bound bar satisfies the reversed inequality. No stress admissibility limit was prescribed.

## Assignment 2 results

For equal weights, the optimized volume is 761772.537993 mm^3, braking compliance C1=1141.910972 N mm, acceleration compliance C2=1189.255904 N mm, and their mean is 1165.583438 N mm. Convergence took 211 updates.

![Equal-weight solution](C:/Users/carlo/topology/solutions/results/assignment2/equal_weight_structure_histories.png)

Figure 3. Equal-weight structure, both compliances, weighted objective, volume and KKT histories. The loads are solved separately against the same K; no combined-load surrogate is used.

![Loaded-node displacements](C:/Users/carlo/topology/solutions/results/assignment2/loaded_node_displacements.png)

Figure 4. Signed displacement components and magnitudes for each loaded node in its relevant load case. Node 9 has zero vertical motion by the prescribed support, but its horizontal motion is free. Individual displacement components need not decrease monotonically, because the objective is weighted total compliance.

| Load case | Node | ux [mm] | uy [mm] | Magnitude [mm] |
|---|---:|---:|---:|---:|
| Braking | 8 | -0.045568439 | -0.012393823 | 0.047223823 |
| Braking | 9 | 0.063812102 | 0.000000000 | 0.063812102 |
| Acceleration | 1 | -0.149922854 | -0.186137702 | 0.239006498 |

### Weight sweep and trade-off

Twenty-three weights were evaluated: 0, 0.01, 0.05 through 0.95 in steps of 0.05, 0.99, and 1. The selected values below summarize the full CSV/MAT results.

| w1 | C1 [N mm] | C2 [N mm] |
|---:|---:|---:|
| 0.00 | 15084.543995 | 838.649955 |
| 0.01 | 3762.912615 | 850.159894 |
| 0.10 | 1923.310641 | 916.004609 |
| 0.25 | 1452.101755 | 1008.577183 |
| 0.50 | 1141.910972 | 1189.255904 |
| 0.75 | 955.977197 | 1510.408296 |
| 0.90 | 857.646290 | 2012.056605 |
| 0.99 | 787.991205 | 3909.709924 |
| 1.00 | 771.726575 | 30703326.797217 |

![Compliance trade-off](C:/Users/carlo/topology/solutions/results/assignment2/compliance_tradeoff.png)

Figure 5. C1/C2 samples, with a separate view of strictly positive weights so the extreme endpoint does not hide the useful compromise region. Connecting segments guide the eye; they are not additional optimized designs.

Increasing the braking weight lowers C1 and increases C2 in the computed sweep. The trade-off is nonlinear, and equally spaced weights do not produce equally spaced points. Equal weights do not enforce equal compliances. For positive weights, an exact weighted-sum optimum is Pareto efficient: improving one compliance without worsening the other would contradict optimality. At zero weights, only weak efficiency is guaranteed without further uniqueness/tie-breaking information.

The w1=1 design has C2 about 3.07e7 N mm under the ignored acceleration load. This is the unmodified lower-bound truss model becoming extremely flexible in a direction that the objective does not penalize. It is not omitted or replaced by a different bound. Such extreme displacements also invalidate a physical small-displacement interpretation of that ignored-load response; the value should be read as a warning about the single-load design within this linear model, not a prediction of a real welded frame. The w1=0 design likewise sacrifices braking performance, though much less severely.

## Verification and troubleshooting

- A one-bar analytical benchmark checks displacement, signed stress and reactions.
- Tests check symmetry and positive definiteness of the supported stiffness, connectivity reversal invariance, duplicate load accumulation, force/moment equilibrium and compliance/strain-energy identities.
- Central differences test every area derivative in both supplied geometries: relative infinity-norm compliance-gradient errors were 5.03e-9 and 7.77e-9. Volume gradients and the dual-envelope derivative are also checked.
- All 27 final runs satisfy area bounds, volume tolerance, convergence, finite positive compliances, nonincreasing weighted-objective histories within tolerance, and expected cross-case trends.
- Maximum final relative equilibrium residual: 3.39e-14. Maximum relative volume residual over all histories: 3.41e-12. Maximum relative KKT residual: 1.9984e-4.
- These are numerical consistency and optimality checks for the stated mathematical model; they do not establish accuracy of a real motorcycle model with bending and welds.

The supplied stiffness assembly was rewritten with ordered DOF indexing to avoid temporary global matrices. Its original indexing was not a physical error for this two-node axial stiffness, whose blocks are invariant under swapping nodes. Stress evaluation uses E times axial strain, equivalent to the original rotated-force/area expression. The load vector now accumulates repeated entries. Zero-gradient and zero-multiplier edge cases, absent from the incomplete optimizer template, are handled explicitly.

## Source map

- Training 5, pp. 10-11: Assignment 1 specification and requested outputs; pp. 12-16: sensitivities, CONLIN and function roles.
- Training 6, pp. 3-5: geometry/supports, area bounds, material, loads, weighted objective and requested outputs.
- Lecture 4b, pp. 5-10: reciprocal objective, dual minimizer and scalar multiplier equation.
- Lecture 5: fixed-load sensitivity and self-adjoint compliance.
- Training 5 ZIP: original geometry and base FEM functions; Training 6 ZIP: motorcycle geometry.

The provided report template is optional; this report uses Markdown. All numerical tables and figures are generated from executed MATLAB code.
