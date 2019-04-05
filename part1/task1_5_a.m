clear; close all; init;
%% Initialisation
ecg = load('data/ECG_Data/ECG_Data.mat');
% sampling frequency
fSample = ecg.fsRRI;
% RRI data after preprocessing (remove mean and detrend)
rri = {detrend(ecg.xRRI1 - mean(ecg.xRRI1)) detrend(ecg.xRRI2 - mean(ecg.xRRI2)) detrend(ecg.xRRI3 - mean(ecg.xRRI3))};
nRris = length(rri);
label = ["normal", "fast", "slow"];
% duration of window
tWindow = [50 150];
% FFT points
nFft = 2048;
% window overlap length
nOverlap = 0;
%% Standard periodogram
psdStd = cell(nRris, 1);
for iRri = 1: nRris
    nSamples = length(rri{iRri});
    [psdStd{iRri}, f] = periodogram(rri{iRri}, hamming(nSamples), nFft, fSample);
end
%% Bartlett periodogram: averaging with rectangular windows
psdAvg = cell(nRris, length(tWindow));
for iRri = 1: nRris
    for iWindow = 1: length(tWindow)
        % number of samples of windows
        nWindows = tWindow(iWindow) * fSample;
        psdAvg{iRri, iWindow} = pwelch(rri{iRri}, hamming(nWindows), nOverlap, nFft, fSample);
    end
end
%% Result plot
legendStr = cell(1, length(tWindow) + 1);
figure;
for iRri = 1: nRris
    subplot(nRris, 1, iRri);
    % standard
    plot(f, pow2db(psdStd{iRri}), 'LineWidth', 2);
    hold on;
    legendStr{1} = 'Standard';
    % Bartlett with different window length
    for iWindow = 1: length(tWindow)
        plot(f, pow2db(psdAvg{iRri, iWindow}), 'LineWidth', 2);
        hold on;
        legendStr{iWindow + 1} = sprintf('\\Deltat = %d sec', tWindow(iWindow));
    end
    grid on; grid minor;
    legend(legendStr);
    title(sprintf('Periodogram by standard and Bartlett methods for %s RRI', label(iRri)));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB)');
    ylim([-80 0]);
end
