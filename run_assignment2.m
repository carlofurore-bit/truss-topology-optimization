function results = run_assignment2(options)
% Equal weights and independent uniform initial designs for a weight sweep.
if nargin<1, options=struct; end
weights=unique([0 0.01 0.05:0.05:0.95 0.99 1]); results=cell(numel(weights),1); compliances=zeros(numel(weights),2);
for i=1:numel(weights)
    p=makeProblem(2,weights(i)); r=solveConlin(p,options); results{i}=r;
    compliances(i,:)=r.analysis.C';
    fprintf('Weight %.2f: C1 %.6f, C2 %.6f N mm (%d iterations)\n',weights(i),r.analysis.C,r.iterations);
end
r=results{find(abs(weights-0.5)<1e-12,1)}; p=r.problem; h=r.history;
figure('Visible','on','Theme','light','Position',[50 50 1400 900]); tiledlayout(2,2,'Padding','loose','TileSpacing','loose');
nexttile; plotStructure(p,r.x,'Equal-weight optimized frame');
nexttile; plot(h.iteration,h.C,'LineWidth',1.5); hold on; plot(h.iteration,h.objective,'k--','LineWidth',1.3);
xlabel('Iteration'); ylabel('Compliance [N mm]'); legend('Braking C1','Acceleration C2','Weighted objective'); grid on;
nexttile; plot(h.iteration,h.volume/p.V,'LineWidth',1.5); hold on; yline(1,'--'); ylim([0 1.1]); xlabel('Iteration'); ylabel('V / Vlimit'); grid on;
figure('Visible','on','Theme','light','Position',[50 50 1400 900]); tiledlayout(2,2,'Padding','loose','TileSpacing','loose');
spec=[1 8;1 9;2 1];
for i=1:size(spec,1)
    c=spec(i,1); node=spec(i,2); ux=squeeze(h.u(2*node-1,c,:)); uy=squeeze(h.u(2*node,c,:));
    nexttile; plot(h.iteration,[ux uy hypot(ux,uy)],'LineWidth',1.5); xlabel('Iteration'); ylabel('Displacement [mm]'); legend('u_x','u_y','Magnitude','Location','best'); grid on;
    title(sprintf('Load case %d, node %d',c,node));
end
figure('Visible','on','Theme','light','Position',[50 50 1400 650]); tiledlayout(1,2,'Padding','loose','TileSpacing','loose');
nexttile; plot(compliances(:,1),compliances(:,2),'-o'); xlabel('C1, braking [N mm]'); ylabel('C2, acceleration [N mm]'); grid on; title('All weights, including endpoints');
nexttile; mask=weights>0 & weights<1; plot(compliances(mask,1),compliances(mask,2),'-o'); xlabel('C1 [N mm]'); ylabel('C2 [N mm]'); grid on; title('Strictly positive weights');
for i=find(ismember(round(100*weights),[1 10 25 50 75 90 99])), text(compliances(i,1),compliances(i,2),sprintf(' %.2g',weights(i)),'FontSize',8); end
end
