function newLabel = dpE1_assign_block_from_BN(valuesToLookUp)

% Create mapping of Block numbers for each phase from BN

total_BN = 95;
mapFrom = [1:total_BN];

% map to
baseline_noFB = repmat(1, 1, 1);
baseline_FB = repmat(2, 1, 10);
training = repmat(3, 1, 80);
aftereffect = repmat(4,1,1);
washout = repmat(5, 1, 3);
mapTo = [baseline_noFB, baseline_FB, training, aftereffect, washout];

newLabel = dp_map_values(mapFrom, mapTo, valuesToLookUp)

end