clear; close all; init;
%% Initialisation
ecg = load('data/ECG_Data/ECG_Data.mat');
% sampling frequency
fSample = ecg.fsRRI;
% RRI data after preprocessing (remove mean and detrend)
rri = {detrend(ecg.xRRI1 - mean(ecg.xRRI1)) detrend(ecg.xRRI2 - mean(ecg.xRRI2)) detrend(ecg.xRRI3 - mean(ecg.xRRI3))};
nRris = length(rri);
label = ["normal", "fast", "slow"];
% FFT points
% nFft = 1024;
nFft = 2048;
% AR order used in estimation
orderAr = 2: 5: 32;
nOrders = length(orderAr);
% declare vars
fAr = cell(nRris, 1);
varEst = zeros(nRris, nOrders);
psdAr = cell(nRris, nOrders);
psdStd = cell(nRris, 1);
legendStr = cell(1, nOrders + 1);
%% Standard periodogram
for iRri = 1: nRris
    nSamples = length(rri{iRri});
    [psdStd{iRri}, fAnalog] = periodogram(rri{iRri}, rectwin(nSamples), nFft, fSample);
end
%% AR modelling
for iRri = 1: nRris
    nSamples = length(rri{iRri});
    for iOrder = 1: nOrders
        % AR parameter and variance estimation via Yule-Walker method
        [coefArEst, varEst(iRri, iOrder)] = aryule(rri{iRri}, orderAr(iOrder));
        % filter: b = standard deviation, a = AR coefficients
        [hAr, fAr{iRri}] = freqz(sqrt(varEst(iRri, iOrder)), coefArEst, nSamples, fSample);
        % PSD by AR estimation
        psdAr{iRri, iOrder} = abs(hAr) .^ 2;
    end
end
%% Result plot
for iRri = 1: nRris
    figure;
    % standard
    plot(fAnalog, pow2db(psdStd{iRri}), 'k');
    hold on;
    legendStr{1} = 'Standard';
    for iOrder = 1: nOrders
        plot(fAr{iRri}, pow2db(psdAr{iRri, iOrder}));
        hold on;
        legendStr{iOrder + 1} = sprintf('AR order = %d', orderAr(iOrder));
    end
    grid on; grid minor;
    legend(legendStr);
    title(sprintf('Periodogram by standard and AR modelling method for %s RRI', label(iRri)));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB/Hz)');
    ylim([-80 0]);
    % variance (noise power)
    figure;
    plot(orderAr, pow2db(varEst(iRri, :)), 'm-x');
    grid on; grid minor;
    legend('Variance');
    title('Relationship between AR order and noise power');
    xlabel('Order of AR model');
    ylabel('Noise power (dB)');
end
