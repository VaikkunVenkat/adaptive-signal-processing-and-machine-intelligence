clear; close all; init;
%% Initialisation
% length of signal
nSamples = 1e3;
% number of realisations
nRps = 1e2;
% coefficients of AR process (correspond to lags)
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
error = cell(nSteps, nRps);
errorSquareAvg = cell(nSteps, 1);
for iStep = 1: nSteps
    for iRp = 1: nRps
        % certain realisation
        signal = arSignal(iRp, :);
        % grouped samples to approximate the value at certain instant
        [group] = preprocessing(signal, orderAr, delay);
        % error by LMS estimation
        [~, ~, error{iStep, iRp}] = lms(group, signal, step(iStep), leak);
    end
    % average error square
    errorSquareAvg{iStep} = mean(cat(3, error{iStep, :}) .^ 2, 3);
end
%% Result plot
legendStr = cell(nSteps, 1);
figure;
% particular realisation
subplot(2, 1, 1);
for iStep = 1: nSteps
    plot(pow2db(error{iStep, end}.^2), 'LineWidth', 2);
    legendStr{iStep} = sprintf('\\mu = %.2f', step(iStep));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'southeast');
title('Error instance by adaptive LMS with second-order AR model');
xlabel('Time (sample)');
ylabel('Squared Error (dB)');
% average value
subplot(2, 1, 2);
for iStep = 1: nSteps
    plot(pow2db(errorSquareAvg{iStep}), 'LineWidth', 2);
    legendStr{iStep} = sprintf('\\mu = %.2f', step(iStep));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'northeast');
title('Mean error by adaptive LMS with second-order AR model');
xlabel('Time (sample)');
ylabel('Squared Error (dB)');
