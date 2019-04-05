clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% amplitudes of sine waves
aSine = [0.7 0.5];
% normalised frequencies of sine waves
fSine = [0.1 0.27];
% clean sinusoidal signal
sineWave = aSine(1) * sin(2 * pi * fSine(1) * t) + aSine(2) * sin(2 * pi * fSine(2) * t);
% number of random processes to generate
nRps = 1e2;
%% PSD by indirect (Definition 1) method of different noisy signals
acf = cell(nRps, 1);
psd = cell(nRps, 1);
for iRp = 1: nRps
    noisySine = sineWave + randn(size(sineWave));
    % biased autocorrelation
    [acf{iRp}, lags] = xcorr(noisySine, 'biased');
    % correlogram spectral estimation
    psd{iRp} = real(fftshift(fft(ifftshift(acf{iRp}))));
end
% normalised frequency corresponds to ACF
f = lags ./ (2 * nSamples) * fSample;
% mean and standard deviation of PSD
psdMean = mean(cell2mat(psd));
psdStd = std(cell2mat(psd));
%% Result plot
figure;
subplot(2, 1, 1);
% individual realisations
for iRp = 1: nRps
    irPlot = plot(f, pow2db(psd{iRp}), 'k', 'LineWidth', 2);
    hold on;
end
% mean
meanPlot = plot(f, pow2db(psdMean), 'r', 'LineWidth', 2);
hold off;
grid on; grid minor;
legend([irPlot, meanPlot], {'Individual', 'Mean'}, 'location', 'southeast');
title('Individual and mean PSD by biased estimator');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('PSD (dB)');
% standard deviation
subplot(2, 1, 2);
varPlot = plot(f, pow2db(psdStd), 'm', 'LineWidth', 2);
grid on; grid minor;
legend('Standard deviation');
title('Standard deviation of PSD estimate of noise-corrupted signals');
xlabel('Normalised frequency (\pi rad/sample)');
ylabel('PSD (dB)');
