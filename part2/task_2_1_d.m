clear; close all; init;
%% Initialisation
% length of signal
nSamples = 1e3;
% number of realisations
nRps = 1e2;
% coefficients of AR process
coefAr = [0.1 0.8];
% order of AR
orderAr = length(coefAr);
% variance of innovations
variance = 0.25;
% delay for decorrelation
delay = 1;
% learning step size
step = [0.05; 0.01];
% number of steps
nSteps = length(step);
% LMS leakage
leak = 0;
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% simulate signal by AR model
arSignal = simulate(arModel, nSamples, 'NumPaths', nRps);
% rows correspond to realisations
arSignal = arSignal';
%% LMS adaptive predictor
weightLms = cell(nSteps, nRps);
weightLmsAvg = cell(nSteps, 1);
for iStep = 1: nSteps
    for iRp = 1: nRps
        % certain realisation
        signal = arSignal(iRp, :);
        % grouped samples to approximate the value at certain instant
        [group] = preprocessing(signal, orderAr, delay);
        % weight by LMS
        [weightLms{iStep, iRp}, ~, ~] = leaky_lms(group, signal, step(iStep), leak);
    end
    % average weight
    weightLmsAvg{iStep} = mean(cat(3, weightLms{iStep, :}), 3);
end
%% Result plot
legendStr = cell(2 * orderAr, 1);
figure;
for iStep = 1: nSteps
    subplot(nSteps, 1, iStep);
    for iOrder = 1: orderAr
        plot(weightLmsAvg{iStep}(iOrder, :));
        hold on;
        legendStr{2 * iOrder - 1} = sprintf('Estimated a_%d', iOrder);
        plot([0 nSamples], [coefAr(iOrder) coefAr(iOrder)], '--');
        hold on;
        legendStr{2 * iOrder} = sprintf('True a_%d', iOrder);
    end
    hold off;
    grid on; grid minor;
    legend(legendStr, 'location', 'bestoutside');
    title(sprintf('Learning curves for step size %.2f', step(iStep)));
    xlabel('Number of iterations (sample)');
    ylabel('Average weights');
    ylim([0 1]);
end
