function [g,x_star] = gradPhi(lambda,x_k,problem)
% Training 5 pp.13-15: minimize each separable CONLIN Lagrangian term.
% A*x + B/x combines all four derivative-sign cases, including zeros.
% In these assignments dC<=0 and dV=L>0, hence x=sqrt(q/(lambda*L)).
lambda = max(0,lambda);
a=problem.grad_of(:); b=problem.grad_constr(:); x_k=x_k(:);
A=max(a,0)+lambda*max(b,0);
B=(-min(a,0)-lambda*min(b,0)).*x_k.^2;
x_star=problem.x_lb;
both=A>0 & B>0;
x_star(both)=sqrt(B(both)./A(both));
x_star(A==0 & B>0)=problem.x_ub(A==0 & B>0);
% A=B=0: choose the lower bound, a valid minimizer of a constant term.
x_star=min(problem.x_ub,max(problem.x_lb,x_star));
g=problem.computeVolume(x_star,problem.nodes,problem.elements)-problem.V;
end
