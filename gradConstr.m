function grad_constr = gradConstr(nodes,elements)
% d(V-Vlimit)/dx_j = L_j (Training 5 p.12).
[~,grad_constr] = computeVolume(ones(size(elements,1),1),nodes,elements);
end
