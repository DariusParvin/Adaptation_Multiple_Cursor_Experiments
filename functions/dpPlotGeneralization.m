% Apply some common formatting to figures:
% Set axes
% Shade no feedback trials
% Draw reference lines
function dpPlotGeneralization(genGrpMean, genGrpSEM, gn, col)

    % Plot data
    idx = genGrpMean.Group == gn;
    x = genGrpMean.tiGen(idx);
    y = genGrpMean.nanmean_nanmean_hand(idx)  ;
    err = genGrpSEM.sem_nanmean_hand(idx);
    shadedErrorBar(x, y, err, {'color', col(gn,:)} ); hold all
    
    % plot points
    plot(x,y,'.','color', col(gn,:), 'markersize', 15)
    
    % Reference lines and formatting
    ylim([-4 25]);
    xlim([-50 65]);
    drawline([0], 'dir', 'horz', 'linestyle', '-','linewidth',1);
    drawline([0], 'dir', 'vert', 'linestyle', '-','linewidth',1);
    drawline([45], 'dir', 'vert', 'linestyle', ':','linewidth',1.5);
    
    xlabel('Target Angle (deg)'); ylabel('Hand Angle (deg)'); 
end