function [exact_pval] = dp_MC_cluster_analysis(allSubjMean)

grp = unique(allSubjMean.Group)';

nSubj = 12;

numBslBlocks = 11;
numTrainBlocks = 80;
for i=1:numTrainBlocks
    sample1 = allSubjMean.nanmean_hand(allSubjMean.Group==grp(1) & allSubjMean.BN==(i + numBslBlocks) );
    sample2 = allSubjMean.nanmean_hand(allSubjMean.Group==grp(2) & allSubjMean.BN==(i + numBslBlocks) );
    [~,p(i),~,stats] = ttest2(sample1,sample2);
    t_score(i) = stats.tstat;   
end
sig_pval = p < .05;
sig_pval = [0 sig_pval 0];
edges = diff(sig_pval);
rising = find(edges==1);
falling = find(edges==-1);
spanWidth = falling - rising;
wideEnough = spanWidth >= 2;
startPos = rising(wideEnough);
endPos = falling(wideEnough)-1;

if ~isempty(startPos) % If there are clusters    
    for j=1:length(startPos)
        tsum(j) = sum(t_score(startPos(j):endPos(j)));
    end
    [tsum_data,max_cluster_idx] = max(tsum);
    sig_cycles = [startPos(max_cluster_idx): endPos(max_cluster_idx)];    
else % If there are no clusters
    tsum_data=0;
end

%plot real data
figure; hold on
plot(p,'k','linewidth',1.5)
plot(xlim,[0.05 0.05],'-r')
xlabel('Cycle number')
ylabel('p-value')


%create the null distribution
num_iter = 1e3;
for ii=1:num_iter
    
    %shuffle group assignmenets on every iteration
    perm_grp = Shuffle([ones(nSubj,1)*grp(1); ones(nSubj,1)*grp(2)]);
    
    for jj=1:numTrainBlocks
        null_data = allSubjMean.nanmean_hand( allSubjMean.BN==(jj + numBslBlocks) );
        sample1 = null_data(perm_grp == grp(1) );
        sample2 = null_data(perm_grp == grp(2) );
        [~,p_null(jj),~,stats_null] = ttest2(sample1,sample2);
        tscore_null(jj) = stats_null.tstat;
    end
       
    sig_pval = p_null < .05;
    sig_pval = [0 sig_pval 0];
    edges = diff(sig_pval);
    rising = find(edges==1);
    falling = find(edges==-1);
    spanWidth = falling - rising;
    wideEnough = spanWidth >= 2;
    startPos = rising(wideEnough);
    endPos = falling(wideEnough)-1;
    
    if startPos
        for kk=1:length(startPos)
            t_all_sig(kk) = sum(tscore_null(startPos(kk):endPos(kk)));
        end
        tsum_null(ii) = max(t_all_sig);
    else
        tsum_null(ii) = 0;
    end
    t_all_sig = [];
    
end

exact_pval = sum(abs(tsum_null) > abs(tsum_data)) / num_iter;

%plot null distribution
figure; hold on
histogram(tsum_null)
plot([tsum_data tsum_data],ylim,'--r')

% Print results
if tsum_data
    str = sprintf('Significant cluster from cycle %d to %d \np value: %.3f ', min(sig_cycles)+numBslBlocks, max(sig_cycles)+numBslBlocks, exact_pval)
else
    str = sprintf('No significant clusters')
end
sprintf('Cluster analysis on Groups: %d & %d\n%s', grp, str)
