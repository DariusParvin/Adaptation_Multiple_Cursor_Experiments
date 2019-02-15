function dpE2PrintTtest(grp1, grp2, g1name, g2name, variable)

[h,p,ci,stats] = ttest2(grp1, grp2);

fprintf('\n%s ttest: %s and %s\n', variable, g1name, g2name )
fprintf('%s: Mean = %.3f, SEM = %.3f \n', g1name, nanmean(grp1), sem(grp1) )
fprintf('%s: Mean = %.3f, SEM = %.3f \n', g2name, nanmean(grp2), sem(grp2) )
fprintf('ttest: df = %d, t = %.3f, p = %.3f \n', stats.df, stats.tstat, p)

end