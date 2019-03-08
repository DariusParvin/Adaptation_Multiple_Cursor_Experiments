function dpE2PrintTtest1(x, label)


ci = dp_CI(x);

d = computeCohen_d(x, zeros(length(x),1), 'paired');

fprintf('\nttest: %s and 0:\n', label)
fprintf('Mean = %.2f [%.2f, %.2f] \n', nanmean(x), ci)
ttest1(x, 0, 2, 'onesample');fprintf(', d = %.3f\n', d );

end