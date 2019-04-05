clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1e4;
% transient state duration
nTransients = 5e2;
% coefficients of AR process
coefAr = [2.76 -3.81 2.65 -0.92];
% variance of AR
variance = 1;
% AR order used in estimation
orderAr = 2: 14;
% number of orders
nOrders = length(orderAr);
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% simulated response data by Monte Carlo simulation of AR process
arSignal = simulate(arModel, nSamples);
% discard the first few samples to remove transient of the filter
arSignal = arSignal(nTransients + 1: end);
% update signal length
nSamples = length(arSignal);
% filter response
[h, f] = freqz(1, [1 -coefAr], nSamples, fSample);
% ground truth PSD
psd = abs(h) .^ 2;
%% AR modelling
varEst = zeros(nOrders, 1);
psdAr = cell(nOrders, 1);
for iOrder = 1: nOrders
    % AR parameter and variance estimation via Yule-Walker method
    [coefArEst, varEst(iOrder)] = aryule(arSignal, orderAr(iOrder));
    % filter: b = standard deviation, a = AR coefficients
    hAr = freqz(sqrt(varEst(iOrder)), coefArEst, nSamples);
    % PSD by AR estimation
    psdAr{iOrder} = abs(hAr) .^ 2;
end
%% Result plot
figure;
% PSD: ground truth vs AR estimation
subplot(2, 1, 1);
plot(f, pow2db(psd), 'k', 'LineWidth', 2);
hold on;
plot(f, pow2db(psdAr{1}), 'LineWidth', 2);
hold on;
plot(f, pow2db(psdAr{3}), 'LineWidth', 2);
hold on;
plot(f, pow2db(psdAr{9}), 'LineWidth', 2);
grid on; grid minor;
legend('Truth', 'AR (2)', 'AR (4)', 'AR (10)');
title(sprintf('PSD estimate by AR model: signal length = %d', nSamples));
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('PSD (dB)');
% variance (noise power)
subplot(2, 1, 2);
plot(orderAr, pow2db(varEst), 'LineWidth', 2);
grid on; grid minor;
legend('Error');
title('Prediction error against AR order');
xlabel('AR order');
ylabel('Noise power (dB)');


