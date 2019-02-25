clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% amplitudes of sine waves
ampSine = [0.7 0.5];
% normalised frequencies of sine waves
freqSine = [0.12 0.27];
% clean sinusoidal signal
sineWave = ampSine(1) * sin(2 * pi * freqSine(1) * t) + ampSine(2) * sin(2 * pi * freqSine(2) * t);
% number of random processes to generate
nRps = 1e2;
%% Generate different noisy signals
acfBiased = cell(nRps, 1);
psdAcfBiased = cell(nRps, 1);
for iRp = 1: nRps
    noisySine = sineWave + randn(size(sineWave));
    % biased autocorrelation
    [acfBiased{iRp}, lags] = xcorr(noisySine, 'biased');
    % correlogram spectral estimation
    psdAcfBiased{iRp} = real(fftshift(fft(ifftshift(acfBiased{iRp}))));
end
% normalised frequency corresponds to ACF
fAcf = lags ./ (2 * nSamples) * fSample;
% mean and standard deviation of PSD
psdMean = mean(cell2mat(psdAcfBiased));
psdStd = std(cell2mat(psdAcfBiased));
%% Mean plot
figure;
% individual realisations
for iRp = 1: nRps
    irPlot = plot(fAcf, psdAcfBiased{iRp}, 'k');
    hold on;
end
% mean
meanPlot = plot(fAcf, pow2db(psdMean), 'r');
hold off;
grid on; grid minor;
legend([irPlot, meanPlot], {'Realisations', 'Mean'});
title('PSD estimates (different realisations and mean) in decibel');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('Power spectral density (dB)');
%% Standard deviation plot
figure;
% standard deviation
stdPlot = plot(fAcf, pow2db(psdStd), 'm');
grid on; grid minor;
legend('Standard deviation');
title('Standard deviation of the PSD estimate in decibel');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('Power spectral density (dB)');
