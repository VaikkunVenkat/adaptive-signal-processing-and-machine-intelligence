clear; close all; init;
%% Initialisation
load sunspot.dat
% sampling time
t = sunspot(:, 1);
% original signal
xRaw = sunspot(:, 2);
% length of signal
nSamples = length(t);
% different windows
window = {rectwin(nSamples), hamming(nSamples), blackman(nSamples)};
label = ["rectangular", "Hamming", "Blackman"];
nWindows = length(window);
% declare vars
psdRaw = cell(nWindows, 1);
psdMeanDetrend = cell(nWindows, 1);
psdLogMean = cell(nWindows, 1);
%% Spectral estimation with preprocesses
% remove mean and detrend
xMeanDetrend = detrend(xRaw - mean(xRaw));
% apply logarithm then subtract mean
xLogMean = log(xRaw + eps) - mean(log(xRaw + eps));
%% Periodograms with different windows
for iWindow = 1: nWindows
    [psdRaw{iWindow}, fDigital] = pwelch(xRaw, window{iWindow});
    psdMeanDetrend{iWindow} = pwelch(xMeanDetrend, window{iWindow});
    psdLogMean{iWindow} = pwelch(xLogMean, window{iWindow});
end
%% Data plots
figure;
plot(t, xRaw);
hold on;
plot(t, xMeanDetrend);
hold on;
plot(t, xLogMean);
grid on; grid minor;
legend('Raw', 'Mean-detrend', 'Log-mean');
title('Sunspot time series');
xlabel('Year');
ylabel('Number of sunspots');
%% Result Plots
for iWindow = 1: nWindows
    figure;
    plot(fDigital, pow2db(psdRaw{iWindow}));
    hold on;
    plot(fDigital, pow2db(psdMeanDetrend{iWindow}));
    hold on;
    plot(fDigital, pow2db(psdLogMean{iWindow}));
    grid on; grid minor;
    legend('Raw', 'Mean-detrend', 'Log-mean');
    title(sprintf('Periodogram of sunspots with %s window', label(iWindow)));
    xlabel('Digital frequency (rad/sample)');
    ylabel('Power spectral density (dB)');
    ylim([-20 60]);
end
