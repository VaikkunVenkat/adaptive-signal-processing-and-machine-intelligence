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
% transient duration
nDiscards = 5e2;
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% simulate signal by AR model
arSignal = simulate(arModel, nSamples, 'NumPaths', nRealisations);
% rows correspond to realisations
arSignal = arSignal';
%% LMS adaptive predictor
error = cell(nSteps, nRealisations);
mse = zeros(nSteps, nRealisations);
for iStep = 1: nSteps
    for iRealisation = 1: nRealisations
        % certain realisation
        signal = arSignal(iRealisation, :);
        % grouped samples to approximate the value at certain instant
        [group] = preprocessing(signal, nOrders, delay);
        % error by LMS estimation
        [~, ~, error{iStep, iRealisation}] = leaky_lms(group, signal, step(iStep), leak);
        % mean square error in stable state
        mse(iStep, iRealisation) = mean(error{iStep, iRealisation}(nDiscards + 1: end) .^ 2);
    end
end
% excess mean square error
emse = mean(mse - variance, 2);
% misadjustment
misadj = emse / variance;
%% Approximation by auto-covariance matrix
% correlation matrix of the input vector
cov = [25/27, 25/54; 25/54, 25/27];
% approximated misadjustment
misadjApprox = step / 2 * trace(cov);
