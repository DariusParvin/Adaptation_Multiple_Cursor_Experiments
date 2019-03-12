%% Set directory
clearvars; warning('off','all');
addpath(genpath('..'))
% save figures here
figDir = '../Figures/';

%% Load and clean Data

remove_outliers = 'T2 = T1;'; % 'T2 = T' keeps outliers, 'T2 = T1' removes outliers 

load('pre-processed_data/E2_trials.mat');

subj = {'ZT45AG1_K1','ZT45AG2_K5','ZT45AG3_K9','ZT45AY1_K3',...%%% Zero Tgt Correlation%
    'ZT45AY2_K7','ZT45CG1_K4','ZT45CG2_K8','ZT45CY1_K2',...
    'ZT45CY2_K6','ZT45CY3_K10','ZT45AY3_K11','ZT45CG3_K12',...
    'ZT45AG4_K13', 'ZT45CY4_K14', 'ZT45AY4_K15', 'ZT45CG4_K16'};


% Check that # of subject names == # of subjects in datafile
if length(subj) ~= length(unique(T.SN))
    error('DP: please_copy_in_subject_names')
end


% CHOOSE WHICH VARIABLE TO PERFORM ANALYSES ON
T.abs_hand = T.abs_hand_theta_maxv;
T.rel_hand = T.rel_hand_theta_maxv;

remove_vars = {'rel_hand_theta','abs_hand_theta','abs_hand_theta_maxv',...
    'rel_hand_theta_maxv','abs_hand_theta_maxradv','rel_hand_theta_maxradv',...
    'abs_handMaxRadExt','rel_handMaxRadExt','abs_hand_theta_50','rel_hand_theta_50'};
T(:, T.Properties.VariableNames(remove_vars)) = [];

% -----------------------------------------------------
% Preprocessing (flipping targets, outlier removal, flipping CCW)
% -----------------------------------------------------

% FLIP GENERALIZATION TARGETS for CCW group (tiFlipRel and tiFlipIrrel
T.tiFlipRel = T.tiRel;
T.tiFlipIrrel = T.tiIrrel;

% Define values to map
map_from_ACW_tgts = sort([0:15:180 , 35 40 50 55, 125 130 140 145])'; % Baseline and training targets
map_to_CW_tgts = flipud(map_from_ACW_tgts);

% ACW subj index
flip_idx = (T.rot_cond > 0);

% then flip the ACW ones
T.tiFlipRel(flip_idx) = dp_map_values(map_from_ACW_tgts, map_to_CW_tgts, T.tiRel(flip_idx) );
T.tiFlipIrrel(flip_idx) = dp_map_values(map_from_ACW_tgts, map_to_CW_tgts, T.tiIrrel(flip_idx) );


% -----------------------------------------------------
% T1 REMOVE OUTLIERS
T1 = T;

outlier_idx = abs(T1.rel_hand) > 90 ; % Remove trials greater than x degrees
fprintf('Outlier trials removed: %d \n' , sum(outlier_idx))

T1.abs_hand(outlier_idx, 1) = nan;
T1.rel_hand(outlier_idx, 1) = nan;


% -----------------------------------------------------
% T2 FLIP CCW SUBJECTS TO CW
% T2 = T1;
eval(remove_outliers);

flip_idx = T2.rot_cond > 0; % CCW condition index
T2.abs_hand(flip_idx, 1) = T1.abs_hand(flip_idx, 1).*(-1) + 180; % Flip trials .*(-1)
T2.rel_hand(flip_idx, 1) = T1.rel_hand(flip_idx, 1).*(-1); % Flip trials .*(-1)


% -----------------------------------------------------
% T3 BASELINE SUBTRACTION
T3 = T2;
baseBN = 6:8; %%%% Baseline cycles to subtract

base_idx = T2.BN >= min(baseBN) & T2.BN <= max(baseBN); % index of baseline cycles
base_mean = varfun(@nanmean,T2(base_idx ,:),'GroupingVariables',{'SN','tiFlipRel'},'OutputFormat','table');

base_tgts = unique(T3.tiFlipRel(base_idx))';

for SN = unique(T3.SN)';
    for ti = base_tgts; % subtract baseline for each target
        trial_idx = (T3.SN==SN & T3.tiFlipRel==ti);
        base_idx = (base_mean.SN==SN & base_mean.tiFlipRel==ti);
        T3.rel_hand(trial_idx) = T2.rel_hand(trial_idx) - base_mean.nanmean_rel_hand(base_idx);
    end
end

% -----------------------------------------------------
% GET DATA FOR FIGS 1, 2, 3
% -----------------------------------------------------
% Training and Aftereffect Generalization
clearvars -except T* fr* subj* figDir
% close all
D = T3;

% -----------------------------------------------------
% GET TRAINING DATA
% subject mean hand angle over blocks
trainSubjMean = varfun(@nanmean,D(D.SN ~= 4,:),'GroupingVariables',{'Group','SN','BN'},...
    'OutputFormat','table');

% Group mean and SEM over subjects
trainGrpMean = varfun(@nanmean,trainSubjMean,'GroupingVariables',{'Group','BN'},...
    'OutputFormat','table');
trainGrpSEM = varfun(@sem,trainSubjMean,'GroupingVariables',{'Group','BN'},...
    'OutputFormat','table');


% -----------------------------------------------------
% GET AFTEREFFECT GENERALIZATION DATA  (Block 49-51)
% Exclude bad subj 4
aeGen = D(D.BN==49 & D.SN ~= 4,:); % Block 49 50 51 are Aftereffect blocks
% aeGen = D(D.BN > 48 & D.BN < 51 ,:); % Block 49 50 51 are Aftereffect blocks

genSubjMean = varfun(@nanmean,aeGen,'GroupingVariables',{'Group','SN','tiFlipRel'},...
    'OutputFormat','table');

% Group mean and SEM over subjects
genGrpMean = varfun(@nanmean,genSubjMean,'GroupingVariables',{'Group','tiFlipRel'},...
    'OutputFormat','table');
genGrpSEM = varfun(@sem,genSubjMean,'GroupingVariables',{'Group','tiFlipRel'},...
    'OutputFormat','table');


% -----------------------------------------------------
% REGRESSION FOR TARGET BETA WEIGHTS
subjs = unique(D.SN)';
for si = 1:length(subjs);
    
    train_idx = (D.SN==subjs(si) & D.BN > 8 & D.BN < 49);
    
    x1 = D.tiFlipRel(train_idx);
    x2 = D.tiFlipIrrel(train_idx);
    
    y = D.abs_hand(train_idx);
    
    X = [ones(size(x1)) x1 x2 ];
    
    [b,bint,r,rint,stats] = regress(y,X);
    
    bRel(si,1) = b(2);
    bIrrel(si,1) = b(3);
    
    bRelRatio(si,1) = b(2)/(b(2) + b(3));
    bIrrelRatio(si,1) = b(3)/(b(2) + b(3));
    
    SN(si,1) = unique(D.SN(train_idx));
    rot_cond(si,1) = unique(D.rot_cond(train_idx));
end
regressTableALL16 = table(SN, rot_cond, bRel, bIrrel, bRelRatio, bIrrelRatio);
regressTable15 = regressTableALL16(regressTableALL16.SN~=4,:);

 %% (not a Figure) Every trial per subj
% clearvars -except T* fr* subj*
% close all
% D = T3;
% 
% %Every subject
% subjs = unique(D.SN)';
% 
% % for si = 1:length(subjs);
% for si = 1;
%     figure(99);set(gcf,'units','centimeters','pos',[5 10 20 10]);
%     
%     dpE2FormatPlot('trials')
%     
%     % Plot data
%     x = D.TN (D.SN == subjs(si)) ;
%     y = D.rel_hand (D.SN == subjs(si)) ;
%     plot(x,y,'.')
%     
%     plot([104.5 304.5], [45 45])
%     
%     str = sprintf('%s, subj id %d' , subj{si}, subjs(si));
%     title(str,'interpreter','none');
%     xlabel('trial number') % x-axis label
%     ylabel('Hand angle (deg)') % y-axis label
%     set(gca,'FontSize',13);
%     
% end

%% FIG 1 Group Cycle vs Hand angle
figure(1); hold all;
set(gcf,'units','centimeters','pos',[5 10 10 5]);
set(gca,'FontSize',10);

% Format axes and reference lines
dpE2FormatPlot('blocks')

% Plot rotation angle
plot([8.5 48.5], [45 45],'k')

% Plot training data
dpE2PlotTraining(trainGrpMean, trainGrpSEM, 1, [0 0 1])

% Title and labels
xlabel('Cycle number'); ylabel('Hand angle (deg)')

% print(sprintf('%sE2_Training',figDir),'-painters','-dpdf')

%% FIG 2 Aftereffect Generalization
close all
figure(2); hold all;
set(gcf,'units','centimeters','pos',[5 10 10 5]);
set(gca,'FontSize',10);

axis([0 180 -7 14])
drawline1(0, 'dir', 'hor', 'linestyle', '-','linewidth',0.1); %0º hand angle

% Shade the relevant and irrelevant training target regions
no_fb_base =patch([35 55 55 35],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
set(no_fb_base,'facecolor',[1 0 0]); set(no_fb_base,'edgealpha',0);
no_fb_post =patch([125 145 145 125],[min(ylim) min(ylim) max(ylim) max(ylim)],zeros(1,4));
set(no_fb_post,'facecolor',[0 1 0]);set(no_fb_post,'edgealpha',0);
alpha(no_fb_base,0.2)
alpha(no_fb_post,0.2)

x = genGrpMean.tiFlipRel;
y = genGrpMean.nanmean_nanmean_rel_hand;
err = genGrpSEM.sem_nanmean_rel_hand;
dpShadedErrorBar(x, y, err, {'color', [0 0 1]}, 'linewidth',1.5 );
plot(x, y, '.', 'color', [0 0 1], 'markersize', 15 );

xlabel('Target angle (deg)'); ylabel('Hand angle (deg)')

% print(sprintf('%sE2_AE_GEN',figDir),'-painters','-dpdf')

%% FIG 3 Example of tracking
figure(3); hold all;
set(gcf,'units','centimeters','pos',[5 10 8 8]);
set(gca,'FontSize',10);

D=T3;

si = 7;

% Plot Hand angle
x = D.TN (D.SN == subjs(si)) ;
y = D.abs_hand (D.SN == subjs(si)) ;
plot(x,y,'k')
plot(x,y,'.k','markersize',20)

% Plot Irrelevant cursor
y = D.abs_hand (D.SN == subjs(si)) + 45 ;
plot(x,y,'color',[0.5 0.5 0.5])
plot(x,y,'.','color',[0.5 0.5 0.5],'markersize',20)

% Plot Relevant cursor
y = D.abs_hand (D.SN == subjs(si)) - 45 ;
plot(x,y,'color',[0.5 0.5 0.5])
plot(x,y,'.','color',[0.5 0.5 0.5],'markersize',20)

% Plot Relevant target
y1 = D.tiRel (D.SN == subjs(si)) ;
plot(x,y1,'r')
plot(x,y1,'.r','markersize',20)

% Plot Irrelevant target
y2 = D.tiIrrel (D.SN == subjs(si)) ;
plot(x,y2,'g')
plot(x,y2,'.g','markersize',20)

axis([220 230 20 160]);

set(gca,'ytick', [45 90 135])

% title('Beta weights')
ylabel('Direction (deg)');
xlabel('Trial number');
% set(gca,'xtick', 1:2 ,'xticklabel',{'Irrelevant','Relevant'},...
%     'xticklabelrotation',45);
% print(sprintf('%sE2_EG_Tracking',figDir),'-painters','-dpdf')

%% FIG 4 Tracking weights bar graph
figure(4); hold all;
set(gcf,'units','centimeters','pos',[5 5 5 8]);
set(gca,'FontSize',10);

bars2plot = {'bIrrel','bRel'};
col = [0 1 0; 1 0 0];

% Plot bars
for bn = 1:2;
    % Get data
    grpData = regressTableALL16.(bars2plot{bn});
    x = bn;
    y = nanmean(grpData);
    err = sem(grpData);
    
    % Plot bar and SEM
    bar(x, y, 'facecolor', col(bn,:))
    plot([x x], [y - err, y + err],...
        'k','linewidth',2);
end

% Plot individual subjects
% x1 = repmat(1, length(grpData),1) + 0.17 + (randn(length(grpData),1)/30); % jitter
x1 = repmat(1, length(grpData),1) + 0.17; % jitter
y1 = regressTableALL16.bIrrel;
% scatterplot(x1 , y1, 'markersize',4, 'markerfill','w');


% Plot individual subjects
% x2 = repmat(2, length(grpData),1) - 0.17 + (randn(length(grpData),1)/30); % jitter
x2 = repmat(2, length(grpData),1) - 0.17; % jitter
y2 = regressTableALL16.bRel;
% scatterplot(x2 , y2, 'markersize',4, 'markerfill','w');

% Line connecting individual subjects
plot([x1 x2]' , [y1 y2]','k');

% Labels and Formatting
axis([0.5 2.5 -0.2 1.1])
ylabel('Regression coefficient');
set(gca,'xtick', 1:2 ,'xticklabel',{'Irrelevant','Relevant'},...
    'xticklabelrotation',45);

% print(sprintf('%sE2BetaBarGraph',figDir),'-painters','-dpdf')

%% FIG 5 Correlation of Weight vs AE
% clearvars -except T* fr* subj*
D = T3(T3.SN~=4,:);

figure(500); hold on;
set(gcf,'units','centimeters','pos',[5 5 11 8]);
set(gca,'FontSize',10);

x1 = regressTable15.bRelRatio;
y1 = D.rel_hand(D.BN==49 & D.tiFlipRel  == 45);

dpE2PlotCorrelation(x1,y1,'r')

x2 = regressTable15.bIrrelRatio;
y2 = D.rel_hand(D.BN==49 & D.tiFlipRel  == 135);

dpE2PlotCorrelation(x2,y2,'g')

% title('Beta weights')
ylabel('Aftereffect (deg)');
xlabel('Normalized beta weight');


% Correlation between beta ratio and AE
[R1,P1] = corrcoef(x1,y1);
[R2,P2] = corrcoef(x2,-y2);

fprintf('\nCorrelation between BetaWeight and AE');
fprintf('\nRelevant target   R = %.3f  p = %.3f\n',R1(1,2),P1(1,2));
fprintf('Irrelevant target   R = %.3f  p = %.3f\n',R2(1,2),P2(1,2));


rel_txt = sprintf('r = %.3f\np = %.3f',R1(1,2),P1(1,2));
text(0.85,2,rel_txt,'FontWeight','bold'); 
irrel_txt = sprintf('r = %.3f\np = %.3f',R2(1,2),P2(1,2));
text(0,10,irrel_txt)

% print(sprintf('%sE2_AE_Corr',figDir),'-painters','-dpdf')

%% Stats
clc
% Print stats to console
fprintf('\n\n*** Stats ***\n');

% Aftereffect ttest at Relevant Target
dpE2PrintTtest1(AE_rel, 'Relevant AE')

% Aftereffect ttest at Irrelevant Target
AE_irrel = genSubjMean.nanmean_rel_hand(genSubjMean.tiFlipRel==135);
dpE2PrintTtest1(AE_irrel, 'Irrelevant AE')

% Aftereffect Relevant vs Irrelevant (in relevant direction) 
dpE2PrintTtest(AE_rel, AE_irrel, 'Relevant', 'Irrelevant', 'Aftereffect')

% Beta weights vs 0
dpE2PrintTtest1(regressTable15.bRel,'Relevant BetaWeight')
dpE2PrintTtest1(regressTable15.bIrrel,'Irrelevant BetaWeight')

% Beta weight ttest
dpE2PrintTtest(regressTable15.bRel, regressTable15.bIrrel, 'Relevant', 'Irrelevant', 'BetaWeight')
