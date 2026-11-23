function grad_of = gradOf(u,nodes,elements)
% Compliance sensitivity for constant loads: -u_e' * k_e^0 * u_e.
% One column per load case; no FEM perturbation solves are needed.
E = 210e3;
ne = size(elements,1);
grad_of = zeros(ne,size(u,2));
for j=1:ne
    a=elements(j,1); b=elements(j,2);
    delta=nodes(b,:)-nodes(a,:); L=norm(delta);
    c=delta(1)/L; s=delta(2)/L;
    dofs=[2*a-1,2*a,2*b-1,2*b];
    extension=[-c,-s,c,s]*u(dofs,:);
    grad_of(j,:) = -E/L*extension.^2;
end
end
