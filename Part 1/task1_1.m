clear; close all;
%% Initialisation
% sampling frequency
fSample = 1e3;
% sampling time
t = 0: 1 / fSample: 1;
% number of FFT
nFft = 1024;
% frequencies of sine waves
freqSine = [80 150];
% signal
xSample = sin(2 * pi * freqSine(1) * t) + sin(2 * pi * freqSine(2) * t);
%% PSD: direct
% first apply FT into f-domain then calculate power of frequency components
psd = abs(fft(xSample, nFft) .^ 2) / (nFft + 1);
%% ACF: indirect
% calculate autocorrelation function of samples in time domain
acf = xcorr(xSample, 'coeff');
% apply FT into f-domain
acfFt = abs(fft(acf, nFft));
%% Result plots
figure;
plot(psd);
hold on;
plot(acfFt);
grid on;
legend('PSD', 'FT of ACF');
title('Periodogram: direct and indirect methods (N=1024)');
xlabel('Frequency (Hz)');
ylabel('Power density (rad^2/Hz)');
