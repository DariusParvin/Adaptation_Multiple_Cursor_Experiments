function dp_E1_print_anova(dataMatrix, variable_label)

[p,tbl,stats] = anova1(dataMatrix,[],'off');
fprintf('\nANOVA for %s\n',variable_label)
fprintf('ttest: F(%d, %d) = %.3f, p = %.3f \n', tbl{2,3}, tbl{3,3}, tbl{2,5}, p);

end




