function sigma = computeStress(u,x,nodes,elements)
% Axial strain evaluation, equivalent to the supplied R*k_e*u_e / area.
assert(numel(x)==size(elements,1),'One area per element is required.');
sigma=zeros(size(elements,1),size(u,2));
for j=1:size(elements,1)
    a=elements(j,1); b=elements(j,2);
    d=nodes(b,:)-nodes(a,:); L=norm(d); c=d(1)/L; s=d(2)/L;
    idx=[2*a-1,2*a,2*b-1,2*b];
    sigma(j,:)=210e3/L*[-c,-s,c,s]*u(idx,:);
end
end
