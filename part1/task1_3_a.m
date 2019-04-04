clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% normalised frequencies of sine waves
fSine = [0.1 0.27];
% white Gaussian noise with unit power
noise = randn(1, nSamples);
% noisy sinusoidal signal
noisySine = sin(2 * pi * fSine(1) * t) + sin(2 * pi * fSine(2) * t) + randn(1, nSamples);
% filtered (low-pass) WGN
filteredNoise = filter([1 1], 1, noise);
% signal set
signal = {noise, noisySine, filteredNoise};
label = ["white Gaussian noise", "noisy sinusoid", "filtered white Gaussian noise"];
nSignals = length(signal);
% declare vars
acfUnbiased = cell(nSignals, 1);
acfBiased = cell(nSignals, 1);
psdUnbiased = cell(nSignals, 1);
psdBiased = cell(nSignals, 1);
%% Biased and unbiased ACF
for iSignal = 1: nSignals
    % biased and unbiased autocorrelation
    [acfUnbiased{iSignal}, lags] = xcorr(signal{iSignal}, 'unbiased');
    acfBiased{iSignal} = xcorr(signal{iSignal}, 'biased');
    % shift back to original frequency -> FFT -> zero-frequency shift
    psdUnbiased{iSignal} = real(fftshift(fft(ifftshift(acfUnbiased{iSignal}))));
    psdBiased{iSignal} = real(fftshift(fft(ifftshift(acfBiased{iSignal}))));
end
% normalised frequency corresponds to ACF
f = lags ./ (2 * nSamples) * fSample;
%% Result plot
% correlogram
figure;
for iSignal = 1: nSignals
    subplot(nSignals, 1, iSignal);
    plot(lags, acfUnbiased{iSignal}, 'LineWidth', 2);
    hold on;
    plot(lags, acfBiased{iSignal}, 'LineWidth', 2);
    grid on; grid minor;
    legend('Unbiased', 'Biased');
    title(sprintf("Correlogram of %s", label(iSignal)));
    xlabel('Lag (sample)');
    ylabel('ACF');
end
% PSD
figure;
for iSignal = 1: nSignals
    subplot(nSignals, 1, iSignal);
    plot(f, psdUnbiased{iSignal}, 'LineWidth', 2);
    hold on;
    plot(f, psdBiased{iSignal}, 'LineWidth', 2);
    grid on; grid minor;
    legend('Unbiased', 'Biased');
    title(sprintf("Spectral estimation by correlogram of %s", label(iSignal)));
    xlabel('Normalised frequency (\pi rad/sample)');
    ylabel('PSD');
end
