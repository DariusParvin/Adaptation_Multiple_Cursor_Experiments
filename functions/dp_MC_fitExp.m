function subjParams = dp_MC_fitExp(subjMean)

grp = unique(subjMean.Group)';
sn = unique(subjMean.SN)';

numBslBlocks = 11;
numTrainBlocks = 80;

    f = waitbar(0,'fitting subjects');
    
for si = 1:length(sn)
    
    waitbar(si/length(sn),f,sprintf('fitting subject %d',si));
    
% for si = 4
    idx = subjMean.SN == sn(si) & subjMean.BN > numBslBlocks & subjMean.BN <= numBslBlocks + numTrainBlocks;
    trials = [1 : numTrainBlocks]';
    y_data = subjMean.nanmean_hand(idx);
    
    lb = [0 -1];
    ub = [90 0];
    
    best_err = inf;
    
    for kk = 1:100 % Repeat with different initial parameters
        %Initial values
        initials = (rand(1, length(ub) ) - 1) .*2.*ub;
        
        % Options to enter the minimizer
        options=optimset('MaxFunEvals',1e16,'TolFun',1e-16,'TolX',1e-16,'Display','off');
        
        %Optimizer
        [params, err] = fmincon(@squared_err, initials,[],[], [], [], lb, ub, [], options, trials, y_data);
        
        %     all_params(kk,:) = params;
        
        if err < best_err
            subjParams(si,:) = params;
        end
        
    end
    
end

delete(f)

% % To plot a subject
% plotSubjNum = 1
% figure; hold on;
% A = subjParams(plotSubjNum,1);
% B = subjParams(plotSubjNum,2);
% fun = @(x) A - A*exp(x*B);
% y_pred = fun(trials);
% plot(trials,y_pred);
% plot(trials,y_data,'.r')

end


function sq_err = squared_err(params, trials, y_data)

A = params(1);
B = params(2);
fun = @(x) A - A*exp(x*B);

y_pred = fun(trials);

% Calculate Squared Error - between data and simulation
sq_err = nansum( (y_data - y_pred).^2);

end





