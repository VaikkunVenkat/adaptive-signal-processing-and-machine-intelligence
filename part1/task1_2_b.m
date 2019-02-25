clear; close all; init;
%% Initialisation
eeg = load('data/EEG_Data/EEG_Data_Assignment1.mat');
% analog sampling frequency
fSample = eeg.fs;
% length of signal
nSamples = length(eeg.POz);
% Hertz per sample
fResolution = 1 / 5;
% FFT points
nFft = fSample / fResolution;
% duration of window
tWindow = [10 5 1];
% remove mean
poz = eeg.POz - mean(eeg.POz);
% overlap length
nOverlap = 0;
% declare vars
psdAvg = cell(length(tWindow), 1);
%% Standard periodogram
[psdStd, fAnalog] = periodogram(poz, rectwin(nSamples), nFft, fSample);
%% Bartlett periodogram: averaging with rectangular windows
for iWindow = 1: length(tWindow)
    % number of samples of windows
    nWindows = tWindow(iWindow) * fSample;
    psdAvg{iWindow} = pwelch(poz, rectwin(nWindows), nOverlap, nFft, fSample);
end
%% Result Plots
% standard
figure;
subplot(2, 1, 1);
plot(fAnalog, pow2db(psdStd), 'k');
grid on; grid minor;
legend('Standard');
title('Periodogram of EEG: standard method');
xlabel('Frequency (Hz)');
ylabel('Power spectral density (dB)');
ylim([-150 -90]);
% Bartlett
subplot(2, 1, 2);
legendStr = cell(length(tWindow), 1);
for iWindow = 1: length(tWindow)
    plot(fAnalog, pow2db(psdAvg{iWindow}));
    legendStr{iWindow} = sprintf('Window length = %d sec', tWindow(iWindow));
    hold on;
end
grid on; grid minor;
legend(legendStr);
title('Periodogram of EEG: Bartlett method');
xlabel('Frequency (Hz)');
ylabel('Power spectral density (dB)');
