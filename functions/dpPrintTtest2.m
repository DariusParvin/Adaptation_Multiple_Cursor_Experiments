function dpPrintTtest2(grp1, grp2, ttestName)

[h,p,ci,stats] = ttest2(grp1, grp2);

fprintf('\n ttest %s\n', ttestName)
fprintf('Sample1: Mean = %.3f, SEM = %.3f \n', nanmean(grp1), sem(grp1) )
fprintf('Sample2: Mean = %.3f, SEM = %.3f \n', nanmean(grp2), sem(grp2) )
fprintf('ttest: df = %d, t = %.3f, p = %.3f \n', stats.df, stats.tstat, p)

end


