function bootstrap_mean_and_CI = dp_calculate_bootstrap_mean_CI(x)

ci = bootci(10000,@mean,x)';

bootstrap_mean_and_CI = [nanmedian(x), ci];
end