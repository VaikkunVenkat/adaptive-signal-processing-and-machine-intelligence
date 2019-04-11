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
nFft = 2048;
% AR order used in estimation
orderAr = 2: 4: 10;
nOrders = length(orderAr);
%% Standard periodogram
psdStd = cell(nRris, 1);
for iRri = 1: nRris
    nSamples = length(rri{iRri});
    [psdStd{iRri}, f] = periodogram(rri{iRri}, rectwin(nSamples), nFft, fSample);
end
%% AR modelling
psdAr = cell(nRris, nOrders);
varEst = zeros(nRris, nOrders);
fAr = cell(nRris, 1);
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
legendStr = cell(1, nOrders + 1);
figure;
for iRri = 1: nRris
    subplot(nRris, 1, iRri);
    % standard
    plot(f, pow2db(psdStd{iRri}), 'k', 'LineWidth', 2);
    hold on;
    legendStr{1} = 'Standard';
    % AR
    for iOrder = 1: nOrders
        plot(fAr{iRri}, pow2db(psdAr{iRri, iOrder}), 'LineWidth', 2);
        hold on;
        legendStr{iOrder + 1} = sprintf('AR (%d)', orderAr(iOrder));
    end
    grid on; grid minor;
    legend(legendStr);
    title(sprintf('PSD estimate by normal periodogram and AR model for %s RRI', label(iRri)));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB)');
    ylim([-80 0]);
end
