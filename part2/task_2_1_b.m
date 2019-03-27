clear; close all; init;
%% Initialisation
% length of signal
nSamples = 1e3;
% number of realisations
nRealisations = 1e2;
% coefficients of AR process
coefAr = [0.1 0.8];
nOrders = length(coefAr);
variance = 0.25;
delay = 1;
% learning step size
step = [0.05; 0.01];
nSteps = length(step);
% LMS leakage
leak = 0;
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% simulate signal by AR model
arSignal = simulate(arModel, nSamples, 'NumPaths', nRealisations);
% rows correspond to realisations
arSignal = arSignal';
%% LMS adaptive predictor
error = cell(nSteps, nRealisations);
errorSquareAvg = cell(nSteps, 1);
for iStep = 1: nSteps
    for iRealisation = 1: nRealisations
        % certain realisation
        signal = arSignal(iRealisation, :);
        % grouped samples to approximate the value at certain instant
        [group] = preprocessing(signal, nOrders, delay);
        % error by LMS estimation
        [~, ~, error{iStep, iRealisation}] = leaky_lms(group, signal, step(iStep), leak);
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
    plot(pow2db(error{iStep, end}.^2));
    legendStr{iStep} = sprintf('Step Size %.2f', step(iStep));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'southeast');
title('Squared error by adaptive LMS with second-order AR model: example');
xlabel('Time (sample)');
ylabel('Squared Error (dB)');
% average value
subplot(2, 1, 2);
for iStep = 1: nSteps
    plot(pow2db(errorSquareAvg{iStep}));
    legendStr{iStep} = sprintf('Step Size %.2f', step(iStep));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'northeast');
title('Squared error by adaptive LMS with second-order AR model: mean');
xlabel('Time (sample)');
ylabel('Squared Error (dB)');
