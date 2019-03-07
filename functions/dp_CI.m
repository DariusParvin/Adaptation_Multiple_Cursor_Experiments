% Calculate 95% Confidence Intervals
function ci = dp_CI(x)

SEM = std(x)/sqrt(length(x));               % Standard Error
ts = tinv([0.025  0.975],length(x)-1);      % T-Score
ci = mean(x) + ts*SEM;                      % Confidence Intervals

end