clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% symmetrical frequency points
f = (-nSamples / 2: nSamples/ 2 - 1) * (fSample / nSamples);
% normalised frequencies of sine waves
freqSine = [0.12 0.27];
% signal
sineWave = sin(2 * pi * freqSine(1) * t) + sin(2 * pi * freqSine(2) * t);
%% Direct PSD: by definition
% first DFT, then shift to center of frequency, next calculate power
psdDef = abs(fftshift(fft(sineWave))) .^ 2 / nSamples;
%% Indirect PSD: by DTFT of ACF
% calculate autocorrelation function of samples in time domain
[acf, lags] = xcorr(sineWave, 'unbiased');
% normalised frequency corresponds to ACF
fAcf = lags ./ (2 * nSamples) * fSample;
% first DFT, then shift to center of frequency
psdAcf = abs(fftshift(fft(acf)));
%% Result plots
figure;
plot(f, psdDef);
hold on;
plot(fAcf, psdAcf);
grid on; grid minor;
legend('By definition', 'By DTFT of ACF');
title('Periodogram: direct and indirect methods');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('Power spectral density');
