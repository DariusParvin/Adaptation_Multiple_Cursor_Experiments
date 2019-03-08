function dpE2PrintTtest(grp1, grp2, name1, name2, variable)

[h,p,ci,stats] = ttest2(grp1, grp2);

ci1 = dp_CI(grp1);
ci2 = dp_CI(grp2);

d = computeCohen_d(grp1, grp2, 'independent');

fprintf('\n%s ttest: %s and %s\n', variable, name1, name2 )
fprintf('%s: Mean = %.2f [%.2f, %.2f] \n', name1, nanmean(grp1), ci1 )
fprintf('%s: Mean = %.2f [%.2f, %.2f]  \n', name2, nanmean(grp2), ci2 )

if p < 0.001    
    fprintf('ttest: t(%d) = %.3f, p < 0.001, d = %.3f \n', stats.df, stats.tstat, d)
else    
    fprintf('ttest: t(%d) = %.3f, p = %.3f, d = %.3f \n', stats.df, stats.tstat, p, d)
end

end