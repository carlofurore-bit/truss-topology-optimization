function a = analyzeDesign(x,p)
% Nested state solve: every load case uses the same design/stiffness.
a.K=buildStiffnessMatrix(p.nodes,p.elements,x);
nc=numel(p.loads); nd=2*size(p.nodes,1);
a.u=zeros(nd,nc); a.F=zeros(nd,nc); a.C=zeros(nc,1);
a.stress=zeros(p.n_el,nc);
for c=1:nc
    [a.u(:,c),a.F(:,c),a.free]=computeStructure(p.constr,p.loads{c},a.K);
    a.C(c)=a.F(:,c)'*a.u(:,c);
    a.stress(:,c)=computeStress(a.u(:,c),x,p.nodes,p.elements);
end
a.gradient=gradOf(a.u,p.nodes,p.elements)*p.weights;
a.objective=p.weights'*a.C;
a.volume=p.lengths'*x;
end
