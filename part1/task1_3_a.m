clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% normalised frequencies of sine waves
freqSine = [0.12 0.27];
% white Gaussian noise with unit power
wgn = randn(1, nSamples);
% noisy sinusoidal signal
noisySine = sin(2 * pi * freqSine(1) * t) + sin(2 * pi * freqSine(2) * t) + randn(1, nSamples);
% filtered (low-pass) WGN
a = 1; b = [1 1];
wgnFilter = filter(b, a, wgn);
% signal set
signal = {wgn, noisySine, wgnFilter};
label = ["white Gaussian noise", "noisy sinusoidal", "filtered white Gaussian noise"];
nSignals = length(signal);
% declare vars
acfUnbiased = cell(nSignals, 1);
acfBiased = cell(nSignals, 1);
psdAcfUnbiased = cell(nSignals, 1);
psdAcfBiased = cell(nSignals, 1);
%% Biased and unbiased ACF
for iSignal = 1: nSignals
    % biased and unbiased autocorrelation
    [acfUnbiased{iSignal}, lags] = xcorr(signal{iSignal}, 'unbiased');
    acfBiased{iSignal} = xcorr(signal{iSignal}, 'biased');
    % shift back to original frequency -> FFT -> zero-frequency shift
    psdAcfUnbiased{iSignal} = real(fftshift(fft(ifftshift(acfUnbiased{iSignal}))));
    psdAcfBiased{iSignal} = real(fftshift(fft(ifftshift(acfBiased{iSignal}))));
end
% normalised frequency corresponds to ACF
fAcf = lags ./ (2 * nSamples) * fSample;
%% ACF plots
for iSignal = 1: nSignals
    figure;
    plot(lags, acfUnbiased{iSignal});
    hold on;
    plot(lags, acfBiased{iSignal});
    grid on; grid minor;
    legend('Unbiased', 'Biased');
    title(sprintf("Correlogram of %s", label(iSignal)));
    xlabel('Lag (sample)');
    ylabel('Autocorrelation function');
end
%% PSD plots
for iSignal = 1: nSignals
    figure;
    plot(fAcf, psdAcfUnbiased{iSignal});
    hold on;
    plot(fAcf, psdAcfBiased{iSignal});
    grid on; grid minor;
    legend('Unbiased', 'Biased');
    title(sprintf("ACF spectral estimation of %s", label(iSignal)));
    xlabel('Normalised frequency (\pi rad/sample)');
    ylabel('Power spectral density');
end
