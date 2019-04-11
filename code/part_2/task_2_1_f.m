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
leak = 0.2: 0.3: 0.8;
% number of leakages
nLeaks = length(leak);
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% simulate signal by AR model
arSignal = simulate(arModel, nSamples, 'NumPaths', nRps);
% rows correspond to realisations
arSignal = arSignal';
%% Leaky LMS adaptive predictor
weightLeakyLms = cell(nLeaks, nSteps, nRps);
weightLeakyLmsAvg = cell(nLeaks, nSteps);
for iLeak = 1: nLeaks
    for iStep = 1: nSteps
        for iRp = 1: nRps
            % certain realisation
            signal = arSignal(iRp, :);
            % grouped samples to approximate the value at certain instant
            [group] = preprocessing(signal, orderAr, delay);
            % weight by leaky LMS
            [weightLeakyLms{iLeak, iStep, iRp}, ~, ~] = lms(group, signal, step(iStep), leak(iLeak));
        end
        % average weight
        weightLeakyLmsAvg{iLeak, iStep} = mean(cat(3, weightLeakyLms{iLeak, iStep, :}), 3);
    end
end
%% Result plot
figure;
for iLeak = 1: nLeaks
    legendStr = cell(2 * orderAr, 1);
    for iStep = 1: nSteps
        subplot(nLeaks, nSteps, (iLeak - 1) * nSteps + iStep);
        for iOrder = 1: orderAr
            plot(weightLeakyLmsAvg{iLeak, iStep}(iOrder, :), 'LineWidth', 2);
            hold on;
            legendStr{2 * iOrder - 1} = sprintf('Est. a_%d', iOrder);
            plot([0 nSamples], [coefAr(iOrder) coefAr(iOrder)], '--', 'LineWidth', 2);
            hold on;
            legendStr{2 * iOrder} = sprintf('a_%d', iOrder);
        end
        hold off;
        grid on; grid minor;
        legend(legendStr, 'location', 'bestoutside');
        title(sprintf('Steady state values of coefficients for \\mu = %.2f and \\gamma = %.1f', step(iStep), leak(iLeak)));
        xlabel('Number of iterations (sample)');
        ylabel('Average weights');
        ylim([0 1]);
    end
end
