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
leak = 0;
% transient duration
transient = 5e2;
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% rows correspond to realisations
arSignal = simulate(arModel, nSamples, 'NumPaths', nRealisations);
arSignal = arSignal';
%% LMS adaptive predictor
error = cell(nSteps, nRealisations);
mse = zeros(nSteps, nRealisations);
avgErrorSquare = cell(nSteps, 1);
for iStep = 1: nSteps
    for iRealisation = 1: nRealisations
        % a certain realisation
        rawData = arSignal(iRealisation, :);
        [prevGroup] = preprocessing(rawData, orderAr, delay);
        [~, ~, error{iStep, iRealisation}] = leaky_lms(prevGroup, rawData, step(iStep), leak);
        mse(iStep, iRealisation) = mean(error{iStep, iRealisation}(transient + 1: end) .^ 2);
    end
    avgErrorSquare{iStep} = mean(cat(3, error{iStep, :}) .^ 2, 3);
end
emse = mean(mse - variance, 2);
misadjustment = emse / variance;
%% Approximation by auto-covariance matrix
cov = [25/27, 25/54; 25/54, 25/27];
misadjustmentApprox = step / 2 * trace(cov);
