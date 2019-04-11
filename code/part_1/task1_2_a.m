clear; close all; init;
%% Initialisation
load sunspot.dat
% normalised sampling frequency
fSample = 1;
% sampling time
t = sunspot(:, 1);
% original signal
xOriginal = sunspot(:, 2);
% length of signal
nSamples = length(t);
% overlap points
nOverlap = 0;
%% Spectral estimation with preprocesses
% remove mean and detrend
xMeanDetrend = detrend(xOriginal - mean(xOriginal));
% apply logarithm then subtract mean
xLogMean = log(xOriginal + eps) - mean(log(xOriginal + eps));
%% Periodograms with Hamming window
[psdRaw, ~] = pwelch(xOriginal, hamming(nSamples), nOverlap, nSamples, fSample);
[psdMeanDetrend, ~] = pwelch(xMeanDetrend, hamming(nSamples), nOverlap, nSamples, fSample);
[psdLogMean, f] = pwelch(xLogMean, hamming(nSamples), nOverlap, nSamples, fSample);
%% Result plot
figure;
% data
subplot(2, 1, 1);
plot(t, xOriginal, 'LineWidth', 2);
hold on;
plot(t, xMeanDetrend, 'LineWidth', 2);
hold on;
plot(t, xLogMean, 'LineWidth', 2);
grid on; grid minor;
legend('Original', 'Mean-detrend', 'Log-mean');
title('Sunspot time series');
xlabel('Year');
ylabel('Number of sunspots');
% PSD
subplot(2, 1, 2);
plot(f, pow2db(psdRaw), 'LineWidth', 2);
hold on;
plot(f, pow2db(psdMeanDetrend), '--', 'LineWidth', 2);
hold on;
plot(f, pow2db(psdLogMean), 'LineWidth', 2);
grid on; grid minor;
legend('Original', 'Mean-detrend', 'Log-mean');
title('Periodogram of sunspots with Hamming window');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('PSD (dB)');
ylim([-20 60]);
