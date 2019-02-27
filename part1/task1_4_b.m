clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1e3;
% discard samples
nDiscards = 5e2;
% coefficients of AR process
coefAr = [2.76 -3.81 2.65 -0.92];
variance = 1;
% AR order used in estimation
orderAr = 2: 2: 14;
nOrders = length(orderAr);
%% Generate signal
% generate AR model
arModel = arima('AR', coefAr, 'Variance', variance, 'Constant', 0);
% simulated response data by Monte Carlo simulation of AR process
arSignal = simulate(arModel, nSamples);
% discard the first few samples to remove transient of the filter
arSignal = arSignal(nDiscards + 1: end);
% update signal length
nSamples = length(arSignal);
% filter response
[h, f] = freqz(1, [1 -coefAr], nSamples, fSample);
% ground truth PSD
psd = abs(h) .^ 2;
% declare vars
varEst = zeros(nOrders, 1);
psdAr = cell(nOrders, 1);
%% AR modelling
for iOrder = 1: nOrders
    % AR parameter and variance estimation via Yule-Walker method
    [coefArEst, varEst(iOrder)] = aryule(arSignal, orderAr(iOrder));
%     % model the signal with fixed order
%     estimate(arima(orderAr(iOrder)), arSignal)
    % filter: b = standard deviation, a = AR coefficients
    hAr = freqz(sqrt(varEst(iOrder)), coefArEst, nSamples);
    % PSD by AR estimation
    psdAr{iOrder} = abs(hAr) .^ 2;
end
%% Result plot
% PSD: ground truth vs AR estimation
for iOrder = 1: nOrders
    subplot(nOrders, 1, iOrder);
    plot(f, pow2db(psd), 'k');
    hold on;
    plot(f, pow2db(psdAr{iOrder}), 'r');
    grid on; grid minor;
    legend('Ground truth', sprintf('AR of order %d', orderAr(iOrder)));
    title(sprintf('PSD estimate of signal of length %d by AR model with order %d', nSamples, orderAr(iOrder)));
    xlabel('Normalised frequency (\pi rad/sample)');
    ylabel('PSD (dB)');
end
% variance (noise power)
figure;
plot(orderAr, pow2db(varEst), 'm-x');
grid on; grid minor;
legend('Variance');
title('Relationship between AR order and noise power');
xlabel('Order of AR model');
ylabel('Noise power (dB)');
