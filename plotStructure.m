function plotStructure(p,x,label)
% Fixed upper-bound width scale; all bars remain in the numerical model.
hold on;
for j=1:p.n_el
    ids=p.elements(j,:);
    if x(j)<=1.01*p.x_lb(j), color=[0.88 0.88 0.88]; else, color=[0.08 0.25 0.40]; end
    plot(p.nodes(ids,1),p.nodes(ids,2),'-','Color',color,'LineWidth',0.15+6*x(j)/p.x_ub(j));
end
fixed=unique(p.constr(:,1));
plot(p.nodes(fixed,1),p.nodes(fixed,2),'s','MarkerSize',6,'MarkerFaceColor',[0.8 0.3 0.15],'MarkerEdgeColor','none');
if p.assignment==1
    for j=[64 77 82]
        mid=mean(p.nodes(p.elements(j,:),:),1);
        text(mid(1),mid(2)+140,sprintf('E%d',j),'Color',[0.7 0.15 0.1],'FontWeight','bold','HorizontalAlignment','center');
    end
end
axis equal; grid on; xlabel('x [mm]'); ylabel('y [mm]'); title(label);
end
