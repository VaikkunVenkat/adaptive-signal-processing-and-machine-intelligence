clear; close all; init;
%% Initialisation
eeg = load('data/EEG_Data/EEG_Data_Assignment1.mat');
% analog sampling frequency
fSample = eeg.fs;
% length of signal
nSamples = length(eeg.POz);
% Hertz per sample
fRes = 1 / 5;
% FFT points
nFft = fSample / fRes;
% duration of window
tWindow = [10, 5, 1];
% remove mean
poz = eeg.POz - mean(eeg.POz);
% window overlap length
nOverlap = 0;
% declare vars
psdAvg = cell(length(tWindow), 1);
%% Standard periodogram
[psdStd, f] = periodogram(poz, hamming(nSamples), nFft, fSample);
%% Bartlett periodogram: averaging with rectangular windows
for iWindow = 1: length(tWindow)
    % number of samples of windows
    nWindows = tWindow(iWindow) * fSample;
    psdAvg{iWindow} = pwelch(poz, hamming(nWindows), nOverlap, nFft, fSample);
end
%% Result Plot
% standard
figure;
subplot(2, 1, 1);
plot(f, pow2db(psdStd), 'k', 'LineWidth', 2);
grid on; grid minor;
legend('Standard');
title('Periodogram of EEG: standard method');
xlabel('Frequency (Hz)');
ylabel('PSD (dB)');
xlim([0 60]);
ylim([-150 -90]);
% Bartlett
subplot(2, 1, 2);
legendStr = cell(length(tWindow), 1);
for iWindow = 1: length(tWindow)
    plot(f, pow2db(psdAvg{iWindow}), 'LineWidth', 2);
    legendStr{iWindow} = sprintf('\\Deltat = %d sec', tWindow(iWindow));
    hold on;
end
grid on; grid minor;
legend(legendStr);
title('Periodogram of EEG: Bartlett method');
xlabel('Frequency (Hz)');
ylabel('PSD (dB)');
xlim([0 60]);
ylim([-150 -90]);
