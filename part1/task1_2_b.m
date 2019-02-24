clear; close all; init;
%% Initialisation
eeg = load('data/EEG_Data/EEG_Data_Assignment1.mat');
% sampling frequency
fSample = eeg.fs;
% number of samples
nSamples = length(eeg.POz);
% length of recording
tDuration = nSamples / fSample;
% samples per Hertz
samplesPerHz = 5;
% FFT points
nFft = samplesPerHz * fSample;
% window length
tWindow = [10 5 1];
nWindows = length(tWindow);
% preprocess: centering
poz = eeg.POz - mean(eeg.POz);
% overlap length
nOverlap = 0;
%% Standard periodogram
[psdStd, fStd] = periodogram(poz, rectwin(nSamples), nFft, fSample);
%% Bartlett periodogram: averaging with rectangular windows
psdAvg = cell(nWindows, 1);
for iWindow = 1: nWindows
    % number of samples of each segment
    nSegSamples = tWindow(iWindow) * fSample;
    [psdAvg{iWindow}, fAvg]= pwelch(poz, rectwin(nSegSamples), nOverlap, nFft, fSample);
end
%% Result Plots
% standard
figure;
subplot(2, 1, 1);
plot(fStd, pow2db(psdStd), 'k');
grid on; grid minor;
legend('Standard');
title('Periodogram of EEG: standard method');
xlabel('Frequency (Hz)');
ylabel('Power density (dB)');
ylim([-150 -90]);
% Bartlett
subplot(2, 1, 2);
legendStr = cell(nWindows, 1);
for iWindow = 1: nWindows
    plot(fAvg, pow2db(psdAvg{iWindow}));
    legendStr{iWindow} = sprintf('Window length = %d sec', tWindow(iWindow));
    hold on;
end
grid on; grid minor;
legend(legendStr);
title('Periodogram of EEG: Bartlett method');
xlabel('Frequency (Hz)');
ylabel('Power density (dB)');
