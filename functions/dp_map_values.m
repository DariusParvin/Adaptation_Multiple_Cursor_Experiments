function mappedVals = dp_map_values(mapFrom, mapTo, valuesToLookUp)

[sortfrom, sortidx] = sort(mapFrom);
sortto = mapTo(sortidx);

mappedVals = interp1(sortfrom, sortto, valuesToLookUp, 'nearest');