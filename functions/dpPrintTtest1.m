function dpPrintTtest1(aeSubjMean, group_names, group1, label)

name1 = group_names{group1};

grp1 = aeSubjMean.nanmean_hand( aeSubjMean.Group == group1);

ci = dp_CI(grp1);

d = computeCohen_d(grp1, zeros(length(grp1),1), 'paired');

fprintf('\n%s ttest: %s and 0:\n', label, name1 )
fprintf('%s: Mean = %.2fº [%.2fº, %.2fº] \n', name1, nanmean(grp1), ci)
ttest1(grp1, 0, 2, 'onesample');fprintf(', d = %.3f\n', d );

end