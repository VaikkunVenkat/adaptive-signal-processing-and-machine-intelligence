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
% frequencies of sine waves
freqSine = [80 150];
% signal
xSample = sin(2 * pi * freqSine(1) * t) + sin(2 * pi * freqSine(2) * t);
% xSample = randn(size(t));
% xSample = 1 ./ t;
%% PSD: direct
% first DFT, then shift to center of frequency, next calculate power
psd = abs(fftshift(fft(xSample))) .^ 2 / nSamples;
fShift = (-nSamples / 2: nSamples/ 2 - 1) * (fSample / nSamples);
%% ACF: indirect
% calculate autocorrelation function of samples in time domain
acf = xcorr(xSample, 'unbiased');
% % first DFT, then shift to center of frequency
psdAcf = abs(fftshift(fft(acf)));
% symmetrical frequency
fAcfShift = -nSamples / 2: nSamples / length(acf): nSamples / 2 - (nSamples / length(acf));
%% Result plots
figure;
plot(fShift, psd);
hold on;
plot(fAcfShift, psdAcf);
grid on;
legend('PSD', 'FT of ACF');
title('Periodogram: direct and indirect methods');
xlabel('Frequency (Hz)');
ylabel('Power density (rad^2/Hz)');
