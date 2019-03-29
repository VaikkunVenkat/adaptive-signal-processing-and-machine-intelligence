clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1e3;
% sampling time
t = (0: nSamples - 1) / fSample;
% amplitudes of sine waves
ampSine = 1;
% normalised frequencies of sine waves
freqSine = 5e-3;
% clean sinusoidal signal
signal = ampSine * sin(2 * pi * freqSine * t);
% number of realisations
nRps = 1e2;
% coefficients of noise as MA process (correspond to lags)
coefMa = [0 0.5];
% variance of innovations
variance = 1;
% learning step size
step = 0.01;
% max delay of the linear predictor
nDelays = 5;
% filter order (length)
orderFilter = 5;
% LMS leakage
leak = 0;
% transient duration
nDiscards = 50;
%% Generate noise
% generate MA model
maModel = arima('MA', coefMa, 'Variance', variance, 'Constant', 0);
% simulate noise by MA model
[maSignal, innovation] = simulate(maModel, nSamples, 'NumPaths', nRps);
% coloured noise by MA filter
colouredNoise = maSignal';
% white noise as innovation
whiteNoise = innovation';
%% Adaptive line enhancer
noisySignal = cell(nDelays, nRps);
signalAle = cell(nDelays, nRps);
errorSquare = cell(nDelays, nRps);
mspe = zeros(nDelays, 1);
for iDelay = 1: nDelays
    for iRp = 1: nRps
        % add coloured noise
        noisySignal{iDelay, iRp} = signal + colouredNoise(iRp, :);
        % preprocess the signal corrupted by coloured noise 
        [group] = preprocessing(noisySignal{iDelay, iRp}, orderFilter, iDelay);
        % signal predicted by ALE
        [~, signalAle{iDelay, iRp}, ~] = leaky_lms(group, noisySignal{iDelay, iRp}, step, leak);
        % prediction error square
        errorSquare{iDelay, iRp} = (signal(nDiscards + 1: end) - signalAle{iDelay, iRp}(nDiscards + 1: end)) .^ 2;
    end
    % mean square prediction error
    mspe(iDelay) = mean(cell2mat(errorSquare(iDelay, :)));
end
%% Result plot
% signal vs prediction
figure;
for iDelay = 1: nDelays
    subplot(nDelays, 1, iDelay);
    % individual realisations
    for iRp = 1: nRps
        % noisy signals
        noisyPlot = plot(t, noisySignal{iDelay, iRp}, 'k');
        hold on;
        % predictions by ALE
        alePlot = plot(t, signalAle{iDelay, iRp}, 'b');
        hold on;
    end
    % original signal
    cleanPlot = plot(t, signal, 'r');
    hold off;
    grid on; grid minor;
    legend([noisyPlot, alePlot, cleanPlot], {'Noisy', 'ALE', 'Clean'}, 'location', 'bestoutside');
    title(sprintf('Noisy, clean and ALE signals by linear predictor of order %d with delay %d', orderFilter, iDelay));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% MSPE
figure;
plot(pow2db(mspe), 'm');
grid on; grid minor;
legend('MSPE');
title(sprintf('MSPE by linear predictor of order %d', orderFilter));
xlabel('Delay (sample)');
ylabel('MSPE (dB)');
