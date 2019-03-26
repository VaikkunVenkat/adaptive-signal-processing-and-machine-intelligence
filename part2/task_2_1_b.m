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
step = [0.05 0.01];
nSteps = length(step);
% LMS leakage
leak = 0;
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% rows correspond to realisations
arSignal = simulate(arModel, nSamples, 'NumPaths', nRealisations);
arSignal = arSignal';
%% LMS adaptive predictor
error = cell(nSteps, nRealisations);
avgErrorSquare = cell(nSteps, 1);
for iStep = 1: nSteps
    for iRealisation = 1: nRealisations
        % a certain realisation
        rawData = arSignal(iRealisation, :);
        [prevGroup] = preprocessing(rawData, orderAr, delay);
        [~, ~, error{iStep, iRealisation}] = leaky_lms(prevGroup, rawData, step(iStep), leak);
    end
    avgErrorSquare{iStep} = mean(cat(3, error{iStep, :}) .^ 2, 3);
end
%% Result plot
figure;
% particular realisation
subplot(2, 1, 1);
plot(pow2db(error{1, end}.^2), 'r');
hold on;
plot(pow2db(error{2, end}.^2), 'k');
hold off;
grid on; grid minor;
legend(sprintf('Step Size %.2f', step(1)), sprintf('Step Size %.2f', step(2)), 'location', 'southeast');
title('Squared error of one realisation by adaptive LMS with second-order AR model');
xlabel('Time (sample)');
ylabel('Squared Error (dB)');
% average value
subplot(2, 1, 2);
plot(pow2db(avgErrorSquare{1}), 'r');
hold on;
plot(pow2db(avgErrorSquare{2}), 'k');
hold off;
grid on; grid minor;
legend(sprintf('Step Size %.2f', step(1)), sprintf('Step Size %.2f', step(2)), 'location', 'northeast');
title('Mean squared error by adaptive LMS with second-order AR model');
xlabel('Time (sample)');
ylabel('Squared Error (dB)');
