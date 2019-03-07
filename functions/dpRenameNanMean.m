% When using 'varfun' multiple times, you may end up with
% 'nanmean_nanmean_hand'. This will just rename it back to 'nanmean_hand'
function handData = dpRenameNanMean(handData)

idx = strcmp('nanmean_nanmean_hand', handData.Properties.VariableNames);

handData.Properties.VariableNames(idx) = {'nanmean_hand'};

end