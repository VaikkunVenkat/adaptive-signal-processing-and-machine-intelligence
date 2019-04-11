clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% normalised frequencies of sine waves
fSine = [0.1, 0.27];
% sine: equality does not hold
waveA = sin(2 * pi * fSine(1) * t) + sin(2 * pi * fSine(2) * t);
% impulse: equality hold
waveB = [1, zeros(1, nSamples - 1)];
%% Definition 1: DTFT of ACF
% calculate autocorrelation function of samples in time domain
[acfA, ~] = xcorr(waveA, 'biased');
[acfB, lag] = xcorr(waveB, 'biased');
% normalised frequency corresponding to ACF
f1 = lag ./ (2 * nSamples) * fSample;
% first DFT, then shift to center of frequency
psdA1 = abs(fftshift(fft(acfA)));
psdB1 = abs(fftshift(fft(acfB)));
%% Definition 2: average power over frequencies
% calculate power directly
psdA2 = abs(fftshift(fft(waveA))) .^ 2 / nSamples;
psdB2 = abs(fftshift(fft(waveB))) .^ 2 / nSamples;
% symmetrical frequency points
f2 = (-nSamples / 2: nSamples/ 2 - 1) * (fSample / nSamples);
%% Result plot
figure;
subplot(3, 1, 1);
plot(lag, acfA, 'LineWidth', 2);
hold on;
plot(lag, acfB, 'LineWidth', 2);
grid on; grid minor;
legend('Sinusoids', 'Impulse');
title('Trend of ACF');
xlabel('Lags (sample)');
ylabel('ACF');
subplot(3, 1, 2);
plot(f1, psdA1, 'LineWidth', 2);
hold on;
plot(f2, psdA2, 'LineWidth', 2);
grid on; grid minor;
legend('Definition 1', 'Definition 2');
title('Periodogram of sinusoids: direct and indirect');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('PSD');
subplot(3, 1, 3);
plot(f1, psdB1, 'LineWidth', 2);
hold on;
plot(f2, psdB2, '--', 'LineWidth', 2);
grid on; grid minor;
legend('Definition 1', 'Definition 2');
title('Periodogram of impulse: direct and indirect');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('PSD');
