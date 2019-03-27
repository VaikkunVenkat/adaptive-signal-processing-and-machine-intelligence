clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1e3;
% number of realisations
nRealisations = 1e2;
% coefficients of AR process
orderAr = 2;
coefAr = [0.1 0.8];
variance = 0.25;
delay = 1;
% learning step size
step = [0.05; 0.01];
nSteps = length(step);
% LMS leakage
leak = 0.2: 0.2: 0.8;
nLeaks = length(leak);
% transient duration
transient = 5e2;
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% rows correspond to realisations
arSignal = simulate(arModel, nSamples, 'NumPaths', nRealisations);
arSignal = arSignal';
%% LMS adaptive predictor
wLms = cell(nLeaks, nSteps, nRealisations);
wLmsAvg = cell(nLeaks, nSteps);
for iLeak = 1: nLeaks
    for iStep = 1: nSteps
        for iRealisation = 1: nRealisations
            % a certain realisation
            rawData = arSignal(iRealisation, :);
            [prevGroup] = preprocessing(rawData, orderAr, delay);
            [wLms{iLeak, iStep, iRealisation}, ~, ~] = leaky_lms(prevGroup, rawData, step(iStep), leak(iLeak));
        end
        wLmsAvg{iLeak, iStep} = mean(cat(3, wLms{iLeak, iStep, :}), 3);
    end
end
%% Result plot
for iLeak = 1: nLeaks
    legendStr = cell(2 * orderAr, 1);
    figure;
    for iStep = 1: nSteps
        subplot(nSteps, 1, iStep);
        for iOrder = 1: orderAr
            plot(wLmsAvg{iLeak, iStep}(iOrder, :));
            hold on;
            legendStr{2 * iOrder - 1} = sprintf('Estimated a_%d', iOrder);
            plot([0 nSamples], [coefAr(iOrder) coefAr(iOrder)], '--');
            hold on;
            legendStr{2 * iOrder} = sprintf('True a_%d', iOrder);
        end
        hold off;
        grid on; grid minor;
        legend(legendStr, 'location', 'bestoutside');
        title(sprintf('Learning curves for step size = %.2f and leakage = %.2f', step(iStep), leak(iLeak)));
        xlabel('Number of iterations (sample)');
        ylabel('Average weights');
        ylim([0 1]);
    end
end
