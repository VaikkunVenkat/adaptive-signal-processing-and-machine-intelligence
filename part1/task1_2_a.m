clear; close all; init;
%% Initialisation
load sunspot.dat
% FFT points
nFft = 256;
% sampling time
t = sunspot(:, 1);
% signal
xRaw = sunspot(:, 2);
% number of samples
nSamples = length(t);
% compare different windows
window = [rectwin(nSamples), hamming(nSamples), blackman(nSamples)];
label = ["rectangular", "Hamming", "Blackman"];
% number of windows
nWindows = size(window, 2);
psdRaw = zeros(nFft + 1, nWindows);
psdPreprocess = zeros(nFft + 1, nWindows);
psdLogPreprocess = zeros(nFft + 1, nWindows);
%% Spectral estimation with mean and trend removed
% remove mean and detrend
xPreprocess = detrend(xRaw - mean(xRaw));
% apply logarithm then subtract mean
xLogPreprocess = log(xRaw + eps) - mean(log(xRaw + eps));
%% Periodograms with different windows
for iWindow = 1: nWindows
    [psdRaw(:, iWindow), f] = pwelch(xRaw, window(:, iWindow));
    psdPreprocess(:, iWindow) = pwelch(xPreprocess, window(:, iWindow));
    psdLogPreprocess(:, iWindow) = pwelch(xLogPreprocess, window(:, iWindow));
end
psdRawDb = 10 * log10(psdRaw);
psdPreprocessDb = 10 * log10(psdPreprocess);
psdLogPreprocessDb = 10 * log10(psdLogPreprocess);
%% Data plots
figure;
plot(t, xRaw);
hold on;
plot(t, xPreprocess);
hold on;
plot(t, xLogPreprocess);
grid on; grid minor;
legend('Raw', 'Mean-detrend', 'Log-mean');
title('Sunspot time series');
xlabel('Year');
ylabel('Number of sunspots');
%% Result Plots
for iWindow = 1: nWindows
    figure;
    plot(f, psdRawDb(:, iWindow));
    hold on;
    plot(f, psdPreprocessDb(:, iWindow));
    hold on;
    plot(f, psdLogPreprocessDb(:, iWindow));
    grid on; grid minor;
    legend('Raw', 'Mean-detrend', 'Log-mean');
    title(sprintf('Periodogram of sunspots with %s window', label(iWindow)));
    xlabel('Digital frequency (rad/sample)');
    ylabel('Power spectral density (dB)');
    ylim([-20 60]);
end
