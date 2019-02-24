clear; close all; init;
%% Initialisation
% sampling frequency
fSample = 1e3;
% sampling time
t = 0: 1 / fSample: (1 - 1 / fSample);
% number of samples
nSamples = length(t);
% frequency range
f = (0: nSamples - 1) * (fSample / nSamples);
% symmetrical frequency
fShift = -nSamples / 2: nSamples / (2 * nSamples - 1): nSamples / 2 - nSamples / (2 * nSamples - 1);
% amplitudes of sine waves
ampSine = [0.7 0.5];
% frequencies of sine waves
freqSine = [80 150];
% clean sinusoidal signal
sineWave = ampSine(1) * sin(2 * pi * freqSine(1) * t) + ampSine(2) * sin(2 * pi * freqSine(2) * t);
% number of random process to generate
nRps = 1e2;
%% Generate different noisy signals
acfBiased = cell(nRps, 1);
psdAcfBiased = cell(nRps, 1);
for iRp = 1: nRps
    noisySine = sineWave + randn(size(sineWave));
    % biased autocorrelation
    acfBiased{iRp} = xcorr(noisySine, 'biased');
    % correlogram spectral estimation
    psdAcfBiased{iRp} = real(fftshift(fft(ifftshift(acfBiased{iRp}))));
end
psdMean = mean(cell2mat(psdAcfBiased));
psdStd = std(cell2mat(psdAcfBiased));
%% Mean plot
figure;
% individual realisations
for iRp = 1: nRps
    irPlot = plot(fShift, psdAcfBiased{iRp}, 'k');
    hold on;
end
% mean
meanPlot = plot(fShift, psdMean, 'r');
hold off;
grid on; grid minor;
legend([irPlot, meanPlot], {'Realisations', 'Mean'});
title('PSD estimates (different realisations and mean)');
xlabel('Frequency (Hz)');
ylabel('Power spectral density');
%% Standard deviation plot
figure;
% standard deviation
stdPlot = plot(fShift, psdStd, 'm');
grid on; grid minor;
legend('Standard deviation');
title('Standard deviation of the PSD estimate');
xlabel('Frequency (Hz)');
ylabel('Power spectral density');
