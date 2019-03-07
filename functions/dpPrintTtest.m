function dpPrintTtest(subjMean, group_names, group1, group2, label)

name1 = group_names{group1};
name2 = group_names{group2};

grp1 = subjMean.nanmean_hand( subjMean.Group == group1 );
grp2 = subjMean.nanmean_hand( subjMean.Group == group2 );

% Check that there is only one data point per subject
if  length(unique(subjMean.SN( subjMean.Group == group1 ))) ~= length(grp1) || ...
    length(unique(subjMean.SN( subjMean.Group == group2 ))) ~= length(grp2); 
    error('There is more than one datapoint per subj') 
end


[h,p,ci,stats] = ttest2(grp1, grp2);

ci1 = dp_CI(grp1);
ci2 = dp_CI(grp2);

d = computeCohen_d(grp1, grp2, 'independent');

fprintf('\n%s ttest: %s and %s:\n', label, name1, name2 )
fprintf('%s: Mean = %.2fº [%.2fº, %.2fº] \n', name1, nanmean(grp1), ci1 )
fprintf('%s: Mean = %.2fº [%.2fº, %.2fº]  \n', name2, nanmean(grp2), ci2 )

if p < 0.001    
    fprintf('ttest: t(%d) = %.3f, p < 0.001, d = %.3f \n', stats.df, stats.tstat, d)
else    
    fprintf('ttest: t(%d) = %.3f, p = %.3f, d = %.3f \n', stats.df, stats.tstat, p, d)
end

end