function dpPrintTtest1(aeSubjMean, group_names, group1, label)

name1 = group_names{group1};

grp1 = aeSubjMean.nanmean_hand( aeSubjMean.Group == group1);

fprintf('\n%s ttest: %s and 0:\n', label, name1 )
ttest1(grp1, 0, 2, 'onesample')

end