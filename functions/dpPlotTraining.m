% Apply some common formatting to figures:
% Set axes
% Shade no feedback trials
% Draw reference lines
function dpPlotTraining(trainGrpMean, trainGrpSEM, gn, col)

    % Plot baseline 
    idx = trainGrpMean.Group == gn & trainGrpMean.BN < 12;
%     x = grpMean.BN(idx);
    x = trainGrpMean.BN(idx);
    y = trainGrpMean.nanmean_nanmean_hand(idx)  ;
    err = trainGrpSEM.sem_nanmean_hand(idx);
    shadedErrorBar(x, y, err, {'color', col(gn,:) } );
    
    % Plot training
    idx = trainGrpMean.Group == gn & trainGrpMean.BN > 11 & trainGrpMean.BN < 92;
%     x = grpMean.BN(idx);
    x = trainGrpMean.BN(idx);
    y = trainGrpMean.nanmean_nanmean_hand(idx)  ;
    err = trainGrpSEM.sem_nanmean_hand(idx);
    shadedErrorBar(x, y, err, {'color', col(gn,:) } ); 
    
    % Plot aftereffect
    idx = trainGrpMean.Group == gn & trainGrpMean.BN == 92;
    x = trainGrpMean.BN(idx);
    y = trainGrpMean.nanmean_nanmean_hand(idx)  ;
    err = trainGrpSEM.sem_nanmean_hand(idx);
    plot(x, y, '.', 'color', col(gn,:), 'markersize', 15 );  
    plot([x x], [y-err y+err], 'color', col(gn,:) );  % Not really visible
    
    % Plot washout
    idx = trainGrpMean.Group == gn & trainGrpMean.BN > 92;
    %     x = grpMean.BN(idx);
    x = trainGrpMean.BN(idx);
    y = trainGrpMean.nanmean_nanmean_hand(idx)  ;
    err = trainGrpSEM.sem_nanmean_hand(idx);
    shadedErrorBar(x, y, err, {'color', col(gn,:) } );
    
end