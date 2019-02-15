function dpPlot_compareGroups(allGrpMean,allGrpSEM,genGrpMean, genGrpSEM, gn, col)

figure(); hold all;
set(gcf,'units','centimeters','pos',[5 5 20 5]);
set(gca,'FontSize',10);


for i = 1:length(gn);
    % PLOT TRAINING FIGS ON THE LEFT
    subplot(1,2,1)
    
    % Format axes and reference lines
    dpFormatPlot('blocks')
    
    % Plot training data
    dpPlotTraining(allGrpMean, allGrpSEM, gn(i), col)
    
    % PLOT GENERALIZATION FIGS ON THE RIGHT
    subplot(1,2,2)
    dpPlotGeneralization(genGrpMean, genGrpSEM, gn(i), col)
end

end