% Apply some common formatting to figures:
% Set axes
% Shade no feedback trials
% Draw reference lines
function dpE2PlotTraining(trainGrpMean, trainGrpSEM, gn, col)

    % Plot baseline 
    idx = trainGrpMean.Group == gn & trainGrpMean.BN < 9;
    x = trainGrpMean.BN(idx);
    y = trainGrpMean.nanmean_nanmean_rel_hand(idx)  ;
    err = trainGrpSEM.sem_nanmean_rel_hand(idx);
    shadedErrorBar(x, y, err, {'color', col(gn,:) } );
    
    % Plot training
    idx = trainGrpMean.Group == gn & trainGrpMean.BN > 8 & trainGrpMean.BN < 49;
    x = trainGrpMean.BN(idx);
    y = trainGrpMean.nanmean_nanmean_rel_hand(idx)  ;
    err = trainGrpSEM.sem_nanmean_rel_hand(idx);
    shadedErrorBar(x, y, err, {'color', col(gn,:) } ); 
    
    % Plot aftereffect and washout
    idx = trainGrpMean.Group == gn & trainGrpMean.BN > 48;
    x = trainGrpMean.BN(idx);
    y = trainGrpMean.nanmean_nanmean_rel_hand(idx)  ;
    err = trainGrpSEM.sem_nanmean_rel_hand(idx);
    shadedErrorBar(x, y, err, {'color', col(gn,:) } );
    
end