% Apply some common formatting to figures:
% Set axes
% Shade no feedback trials
% Draw reference lines
function dpPlotGeneralization(genGrpMean, genGrpSEM, gn, col)
    hold on;

    % Plot data
    idx = genGrpMean.Group == gn;
    x = genGrpMean.tiGen(idx);
    y = genGrpMean.nanmean_nanmean_hand(idx)  ;
    err = genGrpSEM.sem_nanmean_hand(idx);
    dpShadedErrorBar(x, y, err, {'color', col(gn,:),'linewidth',1.5} ); hold all
    
    % plot points
    plot(x,y,'.','color', col(gn,:), 'markersize', 15)
    
    % Reference lines and formatting
    ylim([-4 30]);
    xlim([-50 65]);
    drawline1([0], 'dir', 'horz', 'linestyle', '-','linewidth',0.5);
    drawline1([0], 'dir', 'vert', 'linestyle', '-','linewidth',0.5);
    drawline1([45], 'dir', 'vert', 'linestyle', ':','linewidth',0.5);
    
    text(3,21,'Training','FontSize',7,'Rotation',90);
    text(48,12,'Training Solution','FontSize',7,'Rotation',90);
    
    xlabel('Target angle (deg)'); ylabel('Hand angle (deg)');     
end