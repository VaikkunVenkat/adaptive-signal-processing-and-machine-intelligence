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
% transient duration
nTransients = 5e2;
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% simulate signal by AR model
arSignal = simulate(arModel, nSamples, 'NumPaths', nRps);
% rows correspond to realisations
arSignal = arSignal';
%% LMS adaptive predictor
mse = zeros(nSteps, nRps);
for iStep = 1: nSteps
    for iRp = 1: nRps
        % certain realisation
        signal = arSignal(iRp, :);
        % grouped samples to approximate the value at certain instant
        [group] = preprocessing(signal, orderAr, delay);
        % error by LMS estimation
        [~, ~, error] = leaky_lms(group, signal, step(iStep), leak);
        % mean square error in stable state
        mse(iStep, iRp) = mean(error(nTransients + 1: end) .^ 2);
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
% print results
fprintf('Misadjustment: %.4f    %.4f\n', misadj);
fprintf('Approximated misadjustment: %.4f   %.4f\n', misadjApprox);
