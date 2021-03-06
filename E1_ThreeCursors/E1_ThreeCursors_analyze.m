%% Set directory
clc; clearvars; warning('off','all');
addpath(genpath('..'))
% save figures here
figDir = '../Figures/';


%% Load and clean Data
remove_outliers = 'T2 = T1;'; % 'T2 = T' keeps outliers, 'T2 = T1' removes outliers 
hand_variable = 'T.hand = T.hand_theta_maxv;';


load('pre-processed_data/E1_ThreeCursors_trials.mat');

subj = {'1R45CWW_S65','1R45CWW_D3','1R45AWW_S66','1R45AWW_D4','1R45AWW_D5',... %%%%% Single cursor condition (no landmarks)
    '1R45CWW_D6','1R45CWW_K1','1R45AWW_D7','1R45CWW_D8','1R45AWW_D9',...
    '1R45CWW_S11','1R45AWW_S12',...
    '3R45CGO_D4','3R45AGO_S11','3R45CGP_S12','3R45AGP_S14','3R45COG_S13',...  % Rotated / 'unaligned' 45 deg
    '3R45COP_S15','3R45APO_S16','3R45CPG_S17','3R45CPO_S18','3R45AOG_S21',...
    '3R45AOP_S40','3R45APG_S42',...
    '3N45AGO_S1','3N45CGO_S2','3N45AGP_S4','3N45AGP_D2','3N45COG_D3',... %'Not Rot / Aligned 45'
    '3N45COP_S3','3N45COP_D5','3N45CPG_D6','3N45APO_D7','3N45AOG_S22',... %
    '3N45APG_S24','3N45CPO_S67',...
    '3I45AGO_D2','3I45AGP_D4','3I45AOG_K2','3I45AOP_K4','3I45APG_S2',... %%%% 3 cursor Ignore Rotation
    '3I45APO_D6','3I45CGO_D1','3I45CGP_D3','3I45COG_K1','3I45COP_D7',...
    '3I45CPG_S1','3I45CPO_D5'};

% CHOOSE WHICH VARIABLE TO PERFORM ANALYSES ON
% hand_theta is end point hand angle
% T.hand = T.hand_theta;  % This is hand angle at target distance
% T.hand = T.hand_theta_maxv;
eval(hand_variable);


remove_vars = {'hand_theta','hand_theta_maxv','hand_theta_maxradv','handMaxRadExt','hand_theta_50'};
T(:, T.Properties.VariableNames(remove_vars)) = [];

% Creat block labels: 1 = Baseline no FB, 2 = Baseline FB, 3 = Training, 4 = Aftereffect, 5 = Washout
T.block = dpE1_assign_block_number(T.BN);

% Calculate Total trial time (trial start to trial start). 
% + 1 for frozen endpoint feedback. 
% + 0.5 for wait in start position
T.TTT = T.RT + T.MT + T.ST + 1 + 0.5;

% -----------------------------------------------------
% CREATE T.tiFlip and T.tiGen
% T.tiFlip is the target location (T.ti) but flipped around the nearest training target
% T.tiGEN is the same as tiFlip but averaged over the three targets and
% is the target angle relative to the training target

% tiFlip and tiGen are important because the generalization targets need to be
% flipped over for AntiClockwise conditions
% -----------------------------------------------------

% Copy over all the values,
T.tiFlip = T.ti;

% Define values to map
map_from_CW_tgts = [30, 150, 270, 0 15 45 60 75 90 105 120 135 165 180 195 210 225 240 255 285 300 315 330 345];
map_to_ACW_tgts = [30, 150, 270, 60,45,15,0,345,330,195,180,165,135,120,105,90,315,300,285,255,240,225,210,75];

% ACW subj index
flip_idx = (T.rot_cond > 0);

% then flip the ACW ones
T.tiFlip(flip_idx) = dp_map_values(map_from_CW_tgts, map_to_ACW_tgts, T.ti(flip_idx) );

map_from_gen_tgts = [0 15 30 45 60 75 90 105 120 135 150 165 180 195 210 225 240 255 270 285 300 315 330 345];
map_to_rel_gen_tgts = repmat([-30 -15 0 15 30 45 60 -45],1,3) ;

T.tiGen = dp_map_values(map_from_gen_tgts, map_to_rel_gen_tgts, T.tiFlip );

% -----------------------------------------------------
% T1 REMOVE OUTLIERS
T1 = T;
outlier_idx = abs(T1.hand) > 90 ; % Remove trials greater than x degrees
fprintf('Outlier trials removed: %d = %.2f%% \n' , [sum(outlier_idx)], [sum(outlier_idx)]*100/sum(T.Group<5) )
T1.hand(outlier_idx, 1) = nan;

% -----------------------------------------------------
% T2 FLIP CCW SUBJECTS TO CW

% T2 = T1;
eval(remove_outliers);

flip_idx = T2.rot_cond > 0; % CCW condition index
T2.hand(flip_idx, 1) = T1.hand(flip_idx, 1).*(-1); % Flip trials .*(-1)

% -----------------------------------------------------
% T3 BASELINE SUBTRACTION
T3 = T2;
baseBN = 9:11; %%%% Baseline cycles to subtract

base_idx = T3.BN >= min(baseBN) & T3.BN <= max(baseBN); % index of baseline cycles
base_mean = varfun(@nanmean,T2(base_idx ,:),'GroupingVariables',{'SN','ti'},'OutputFormat','table');

for SN = unique(T3.SN)';
    for ti = unique(T3.ti)'; % subtract baseline for each target
        trial_idx = (T3.SN==SN & T3.ti==ti);
        base_idx = (base_mean.SN==SN & base_mean.ti==ti);
        T3.hand(trial_idx) = T2.hand(trial_idx) - base_mean.nanmean_hand(base_idx);
    end
end

% -----------------------------------------------------
% useful Figure References for graphs
fr.group_names = {'One cursor', 'Three cursor', 'Compensate', 'Ignore Rotation',...
    'Single cursor with Aim Report', 'Three cursor with Aim Report'};

fr.blocks1 = [24.5 144.5 264.5 384.5 504.5 528.5]; fr.blocks2 = [24.5 264.5 504.5 528.5 600.5];
fr.cycles1 = [1.5 6.5 11.5 51.5 91.5 92.5]; fr.cycles2 = [1.5 11.5 91.5 92.5];
fr.axes1 = [0 360 -40 40]; fr.axes2 = [0 90 -40 40];

% Colors for each group
fr.col(1,:)= [58/255 84/255 164/255];
fr.col(2,:)= [231/255 145/255 53/255];
fr.col(3,:)= [7/255 210/255 0/255];
fr.col(4,:)= [234/255 0 238/255];


% -----------------------------------------------------
% CREATE DATA FOR FIGS 1, 2, 3
% -----------------------------------------------------

% Training and Aftereffect Generalization
clearvars -except T* fr* subj* figDir*
% close all
D = T3;

% -----------------------------------------------------
% GET TRAINING DATA
% subject mean hand angle over blocks
allSubjMean = varfun(@nanmean,D,'GroupingVariables',{'Group','SN','BN','block'},...
    'InputVariables',{'hand'},'OutputFormat','table');

% Group mean and SEM over subjects
allGrpMean = varfun(@nanmean,allSubjMean,'GroupingVariables',{'Group','BN'},...
    'InputVariables',{'nanmean_hand'},'OutputFormat','table');
allGrpSEM = varfun(@sem,allSubjMean,'GroupingVariables',{'Group','BN'},...
    'InputVariables',{'nanmean_hand'},'OutputFormat','table');

% -----------------------------------------------------
% GET AFTEREFFECT GENERALIZATION DATA  (Block 92)

aeGen = D(D.BN==92,:); % Block 92 are Aftereffect trials

genSubjMean = varfun(@nanmean,aeGen,'GroupingVariables',{'Group','SN','tiGen'},...
    'InputVariables',{'hand'},'OutputFormat','table');

% Group mean and SEM over subjects
genGrpMean = varfun(@nanmean,genSubjMean,'GroupingVariables',{'Group','tiGen'},...
    'InputVariables',{'nanmean_hand'},'OutputFormat','table');
genGrpSEM = varfun(@sem,genSubjMean,'GroupingVariables',{'Group','tiGen'},...
    'InputVariables',{'nanmean_hand'},'OutputFormat','table');

%% (not in paper) View individual subject - Trial vs Hand angle
clearvars -except T* fr* subj* all* gen* figDir*
close all
D = T3;

subs = unique(T.SN);

% for si = 1:length(subs);
for si = 3;
    
    figure;set(gcf,'units','centimeters','pos',[5 10 20 10]);
    hold on;
    
    % Format axes and reference lines
    dpFormatPlot('trials')
    
    % Plot data
    x = D.TN (D.SN == subs(si)) ;
    y = D.hand (D.SN == subs(si)) ;
    plot(x,y,'.')
    
    % Title and labels
    gn = unique(D.Group(D.SN == subs(si))); % group number
    str = sprintf('Group %d - %s, subj id %d',gn , fr.group_names{gn}, subs(si))
    title(str,'interpreter','none');
end

%% PLOT FIG 1 Comparison between 2 groups
dpPlot_compareGroups(allGrpMean,allGrpSEM,genGrpMean, genGrpSEM, [1 2], fr.col)
% print(sprintf('%sFig3Comparison1_%s', figDir, date),'-painters','-dpdf')

dpPlot_compareGroups(allGrpMean,allGrpSEM,genGrpMean, genGrpSEM, [3 4], fr.col)
% print(sprintf('%sFig3Comparison2_%s', figDir, date),'-painters','-dpdf')

dpPlot_compareGroups(allGrpMean,allGrpSEM,genGrpMean, genGrpSEM, [2 3], fr.col)
% print(sprintf('%sFig3Comparison3_%s', figDir, date),'-painters','-dpdf')

%% PLOT FIG 3 Bar graph - Aftereffect at training target Bar graph

figure(300); hold all;
set(gcf,'units','centimeters','pos',[5 5 7 10]);
set(gca,'FontSize',10);

for gn = 1:4;
    % Get data for training target
    grpData = genSubjMean.nanmean_hand( genSubjMean.Group == gn & genSubjMean.tiGen==0);
    x = gn;
    y = nanmean(grpData);
    err = sem(grpData);
    
    % Plot bar and SEM
    bar(x, y, 'facecolor', fr.col(gn,:))
    plot([x x], [y - err, y + err],...
        'k','linewidth',2);
    
    % Plot individual subjects
    x2 = repmat(x, length(grpData),1) + 0.17 + (randn(length(grpData),1)/30); % jitter
    y2 = grpData;
    scatterplot(x2 , y2, 'markersize',4, 'markerfill','w');
    
    % Labels and Formatting
    axis([0.5 4.5 -5 30])
    ylabel('Heading angle (deg)');
    set(gca,'xtick', 1:4 ,'xticklabel',fr.group_names([1 2 3 4]),...
        'xticklabelrotation',45);
end

% print(sprintf('%sFig4AEBarGraph',figDir),'-painters','-dpdf')

%% Stats RT, MT, and TTT (Total Trial Time) 
medianPerSN = varfun(@nanmedian, T3,'GroupingVariables',{'Group','SN','block'},...
    'InputVariables',{'RT','MT','TTT'}, 'OutputFormat','table');

medianPerSN.GroupSN = dp_create_SN_labels(5,12,4);

% make group and block into categorical
medianPerSN.Group = categorical(medianPerSN.Group); medianPerSN.block = categorical(medianPerSN.block);


% RT Anova between groups
group_RTs = unstack(medianPerSN,'nanmedian_RT','Group','GroupingVariable','GroupSN');
dp_E1_print_anova(group_RTs{:,2:5},'RT');

% MT Anova between groups
group_MTs = unstack(medianPerSN,'nanmedian_MT','Group','GroupingVariable','GroupSN');
dp_E1_print_anova(group_MTs{:,2:5},'MT');

% TTT Anova between groups
group_TTTs = unstack(medianPerSN,'nanmedian_TTT','Group','GroupingVariable','GroupSN');
dp_E1_print_anova(group_TTTs{:,2:5},'TTT');


% Median and CI for RT and MT
all_median_CI = varfun(@dp_calculate_bootstrap_mean_CI, medianPerSN,...
    'InputVariables',{'nanmedian_RT','nanmedian_MT','nanmedian_TTT'},...
    'OutputFormat','table');
all_median_in_ms = all_median_CI{:,:}.*1000;

fprintf('\nmedian RT = %3.f ms [%3.f ms, %3.f ms] \n', all_median_in_ms(1), all_median_in_ms(2), all_median_in_ms(3));
fprintf('median MT = %3.f ms [%3.f ms, %3.f ms] \n', all_median_in_ms(4), all_median_in_ms(5), all_median_in_ms(6));
fprintf('median TTT = %3.f ms [%3.f ms, %3.f ms] \n', all_median_in_ms(7), all_median_in_ms(8), all_median_in_ms(9));

% % Median and 95% CI for RT and MT for each block
% block_MT_RT_median_CI = varfun(@dp_calculate_bootstrap_mean_CI, medianRTandMT,...
%     'GroupingVariables',{'block'},...
%     'InputVariables',{'nanmedian_RT','nanmedian_MT'},...
%     'OutputFormat','table')

%% Stats Early, Late Learning and Aftereffects
% clc
% Print stats to console
fprintf('\n\n*** Training Block Stats ***\n');
% -----------------------------------------------------
% Early learning (mean of cycles 3-7)
early_idx = allSubjMean.BN>=14 & allSubjMean.BN<=18;
earlySubjMean = varfun(@nanmean, allSubjMean(early_idx,:),'GroupingVariables',{'Group','SN'},...
    'OutputFormat','table');
earlySubjMean = dpRenameNanMean(earlySubjMean);

% Early learning: One vs Three cursor group
dpPrintTtest(earlySubjMean, fr.group_names, 1, 2, 'Early Learning')


% Training cycles for Ignore group
allTrain_idx = allSubjMean.block == 3;
allSubjMean2 = varfun(@nanmean, allSubjMean(allTrain_idx ,:),'GroupingVariables',{'Group','SN'},...
    'OutputFormat','table');
allSubjMean2 = dpRenameNanMean(allSubjMean2);
dpPrintTtest1(allSubjMean2 , fr.group_names, 4, 'Training')

% Training Cycle 10 for Ignore group
fprintf('\nTraining Block Cycle 10 \n');
train10_idx = allSubjMean.BN == 21;
train10 = varfun(@nanmean, allSubjMean(train10_idx ,:),'GroupingVariables',{'Group','SN'},...
    'OutputFormat','table');
train10 = dpRenameNanMean(train10);
dpPrintTtest1(train10 , fr.group_names, 4, 'Training')

% Training Cycle 11 for Ignore group
fprintf('\nTraining Block Cycle 11 \n');
train11_idx = allSubjMean.BN == 22;
train11 = varfun(@nanmean, allSubjMean(train11_idx ,:),'GroupingVariables',{'Group','SN'},...
    'OutputFormat','table');
train11 = dpRenameNanMean(train11);
dpPrintTtest1(train11 , fr.group_names, 4, 'Training')


% -----------------------------------------------------
% Late learning (mean of last 10 cycles (cycles 82-91) )
late_idx = allSubjMean.BN>=82 & allSubjMean.BN<=91;
lateSubjMean = varfun(@nanmean, allSubjMean(late_idx,:),'GroupingVariables',{'Group','SN'},...
    'OutputFormat','table');
lateSubjMean = dpRenameNanMean(lateSubjMean);
dpPrintTtest(lateSubjMean, fr.group_names, 1, 2, 'Late Learning')


fprintf('\n\n*** Aftereffect Stats ***\n');
% -----------------------------------------------------
% Mean Aftereffect ttest between One and Three cursor groups
train_idx = genSubjMean.tiGen==0;
dpPrintTtest(genSubjMean(train_idx,:), fr.group_names, 1, 2, 'AE')

% -----------------------------------------------------
% Mean Aftereffect ttest to see if significant AE at training tgt
for i = 1:4
    dpPrintTtest1(genSubjMean(train_idx,:), fr.group_names, i, 'AE')
end

% -----------------------------------------------------
% Mean Aftereffect ttest between Three Cursor and Compensate groups
dpPrintTtest(genSubjMean(train_idx,:), fr.group_names, 2, 3, 'AE')


% -----------------------------------------------------
% Three Cursor vs Compensate groups. Early learning and Late training
fprintf('\n\n*** Three Cursor vs Compensate. Early learning and Late training ***\n');
dpPrintTtest(earlySubjMean, fr.group_names, 2, 3, 'Early Learning')
dpPrintTtest(lateSubjMean, fr.group_names, 2, 3, 'Late Learning')

%% -----------------------------------------------------
% Cluster analysis on training between Group 1 (one cursor) and 2 (three cursor)?
% dp_MC_cluster_analysis( allSubjMean( allSubjMean.Group == 2 | allSubjMean.Group == 4,: ) );
%
% dp_MC_cluster_analysis( allSubjMean( allSubjMean.Group == 1 | allSubjMean.Group == 2,: ) );

dp_MC_cluster_analysis_oneGroup( allSubjMean( allSubjMean.Group == 4,: ) );
%%
% Early learning (mean of cycles 3-7)
significant_idx = allSubjMean.BN>=21 & allSubjMean.BN<=22;
driftSubjMean = varfun(@nanmean, allSubjMean(significant_idx,:),'GroupingVariables',{'Group','SN'},...
    'OutputFormat','table');
driftSubjMean = dpRenameNanMean(driftSubjMean);

dpPrintTtest1(driftSubjMean, fr.group_names, 4, 'significant cycles')
%% -----------------------------------------------------
% Fit Exponential to subjects
rng(1) % Set seed
clearvars -except T* fr* subj* all* gen* figDir*

grp1params = dp_MC_fitExp(allSubjMean( allSubjMean.Group == 1,: ));
grp2params = dp_MC_fitExp(allSubjMean( allSubjMean.Group == 2,: ));

dpPrintTtest2(grp1params(:,1) , grp2params(:,1) , 'One vs Three Cursor A fits')
dpPrintTtest2(grp1params(:,2) , grp2params(:,2) , 'One vs Three Cursor B fits')
%% -----------------------------------------------------
% Fit Exponential to Bootstrapped Data
rng(1) % Set seed
tic
clearvars -except T* fr* subj* all* gen* figDir*
rng(1)
for gi = 1:3
    grpParams = dp_MC_fitExpBootstrap(allSubjMean( allSubjMean.Group == gi,: ));
    sprintf('Group %d \nA CI: %.3f, %.3f\nB CI: %.3f, %.3f',gi,...
        prctile(grpParams(:,1),2.5), prctile(grpParams(:,1),97.5),...
        prctile(grpParams(:,2),2.5), prctile(grpParams(:,2),97.5))
end
%% Not in paper: Gaussian fits
%  THIS CELL DOES A BASIC GAUSSIAN FIT ON THE DATA
rng(1) % Set seed
clc
fitted_gen = nan(4,8);
for gn = 1:4;
    idx = genGrpMean.Group == gn;
    AE_gen_data = genGrpMean.nanmean_nanmean_hand(idx);
    target_locations = unique(genGrpMean.tiGen);


    % Initial parameters, upper & lower bounds
    sigma0 = 45; % Width of generalization
    mu0 = 0; % Peak of adaptation
    height0 = 20; % Max adaptation (not including global generalization)
    offset0 = 0; % global adaptation

    init = [sigma0,mu0,height0,offset0];
    LB = [0 0 0 -100];
    UB = [100 100 100 100];

    options=optimset('MaxFunEvals',1e14,'TolFun',1e-14,'TolX',1e-14);
    [soln, fval] = fmincon(@dpGaussianFunc,init,[],[],[],[],LB,UB,[],options,target_locations,AE_gen_data);


    sigma(gn,1) = soln(1); % Width of generalization
    mu(gn,1) = soln(2); % Peak of adaptation
    height(gn,1) = soln(3); % Max adaptation (not including global generalization)
    offset(gn,1) = soln(4); % global adaptation
    fitted_gen(gn,1:8) =  soln(3).*(gaussmf(target_locations,[soln(1) soln(2)])) + soln(4) ; % Fitted values
end

fitGausTable = table(sigma, mu, height, offset, fitted_gen)

%% Bootstrapped Gaussian fits
clearvars -except T* fr* subj* all* gen* figDir*
tic
rng(1) % Set seed

bs_samples = 100;

bsSummary = [];
f = waitbar(0,'fitting bootstraps');

for gn = 1:4;
    
    
    for bi = 1:bs_samples;
        
        waitbar(bi/bs_samples,f,sprintf('fitting bootstraps. Group %d, sample %d',gn, bi));
        
        % -----------------------------------------------------
        % GENERATE BOOTSTRAPPED DATA
        
        % Get unique Subject Numbers from group
        SNs = unique(genSubjMean.SN(genSubjMean.Group == gn,:));
        
        % Generate random samples of Subject Numbers (with replacement)
        rSamp = datasample(SNs, length(SNs));
        
        % Generate bootstrapped group data
        bs_table = table();
        for si = 1:length(rSamp);
            bs_table = [bs_table; genSubjMean(genSubjMean.SN==rSamp(si),:) ];
        end
        
        bs_mean_table = varfun(@nanmean,bs_table,'GroupingVariables',{'tiGen'},...
            'OutputFormat','table');
        
        
        % -----------------------------------------------------
        % FIT BOOTSTRAPPED DATA
        bs_gen_data = bs_mean_table.nanmean_nanmean_hand;
        target_locations = unique(bs_mean_table.tiGen);
        
        % Initial parameters, upper & lower bounds
        sigma0 = 45; % Width of generalization
        mu0 = 0; % Peak of adaptation
        height0 = 20; % Max adaptation (not including global generalization)
        offset0 = 0; % global adaptation
        
        init = [sigma0,mu0,height0,offset0];
        LB = [0 0 0 -100];
        UB = [100 100 100 100];
        
        options=optimset('MaxFunEvals',1e14,'TolFun',1e-14,'TolX',1e-14,'display','off');
        [soln, fval] = fmincon(@dpGaussianFunc,init,[],[],[],[],LB,UB,[],options,target_locations,bs_gen_data);
        
        
        % -----------------------------------------------------
        % SAVE VALUES FROM GAUSSIAN FIT
        
        sigma(bi,1) = soln(1); % Width of generalization
        mu(bi,1) = soln(2); % Peak of adaptation
        gaussHeight(bi,1) = soln(3); % Max adaptation (not including global generalization)
        offset(bi,1) = soln(4); % global adaptation
        fitted_gen(bi,1:8) =  soln(3).*(gaussmf(target_locations,[soln(1) soln(2)])) + soln(4) ; % Fitted values
        
        overallHeight(bi,1) = gaussHeight(bi,1) +  offset(bi,1); % Overall Height of peak
    end
    
    % -----------------------------------------------------
    % CALCULATE MEAN, CI FOR THE GROUP AND SAVE
    
    % Compile the fitted bootstrap samples into a big table
    bsGausFitTable = table(mu,overallHeight, sigma, gaussHeight, offset, fitted_gen);
    
    % Record the group
    groupID = [gn;gn;gn];
    
    % Record the group
    meanCI = [1;2;3];
    
    % Record the group
    meanCI = [1;2;3];
    
    % Calculate mean, upper and lower 95% CI
    meanAndCI = ...
        [mean(bsGausFitTable{:,:});
        prctile(bsGausFitTable{:,:},5);
        prctile(bsGausFitTable{:,:},95)];
    
    % Save in this final table
    bsSummary = [bsSummary ; [groupID meanCI meanAndCI]];
    
end

delete(f)

bsSummaryTable = array2table(bsSummary);

headers = {'Group','meanCI',...
    bsGausFitTable.Properties.VariableNames{1:5},...
    't1','t2','t3','t4','t5','t6','t7','t8'};

bsSummaryTable.Properties.VariableNames = headers

% % Get relevant stats for E1a
% bsSummaryTable(bsSummaryTable.Group==1,:)
% bsSummaryTable(bsSummaryTable.Group==2,:)

toc
