function dpPrintTtest(aeSubjMean, group_names, group1, group2, label)

name1 = group_names{group1};
name2 = group_names{group2};

grp1 = aeSubjMean.nanmean_hand( aeSubjMean.Group == group1);
grp2 = aeSubjMean.nanmean_hand( aeSubjMean.Group == group2);

[h,p,ci,stats] = ttest2(grp1, grp2);

fprintf('\n%s ttest: %s and %s:\n', label, name1, name2 )
fprintf('%s: Mean = %.3f, SEM = %.3f \n', name1, nanmean(grp1), sem(grp1) )
fprintf('%s: Mean = %.3f, SEM = %.3f \n', name2, nanmean(grp2), sem(grp2) )
fprintf('ttest: df = %d, t = %.3f, p = %.3f \n', stats.df, stats.tstat, p)

end