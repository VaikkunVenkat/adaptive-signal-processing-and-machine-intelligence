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
step = 0.005;
% delays of the linear predictor
delay = 3: 6;
% number of delays
nDelays = length(delay);
% filter order (length)
orderFilter = 6;
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
% secondary noise (correlated to the primary noise in unknown way)
secondaryNoise = 0.9 * colouredNoise + 0.05;
%% Adaptive line enhancer and adaptive noise cancellation
noisySignal = cell(nDelays, nRps);
signalAle = cell(nDelays, nRps);
signalAnc = cell(nDelays, nRps);
errorSquareAle = cell(nDelays, nRps);
errorSquareAnc = cell(nDelays, nRps);
mspeAle = zeros(nDelays, 1);
mspeAnc = zeros(nDelays, 1);
signalAleAvg = cell(nDelays, 1);
signalAncAvg = cell(nDelays, 1);
for iDelay = 1: nDelays
    for iRp = 1: nRps
        % add coloured noise
        noisySignal{iDelay, iRp} = signal + colouredNoise(iRp, :);
        % ALE: preprocess the signal corrupted by coloured noise 
        [group] = preprocessing(noisySignal{iDelay, iRp}, orderFilter, delay(iDelay));
        % signal predicted by ALE
        [~, signalAle{iDelay, iRp}, ~] = leaky_lms(group, noisySignal{iDelay, iRp}, step, leak);
        % prediction error square of ALE
        errorSquareAle{iDelay, iRp} = (signal(nDiscards + 1: end) - signalAle{iDelay, iRp}(nDiscards + 1: end)) .^ 2;
        % noisy signal with unit delay
        delayedSignal = [0, noisySignal{iDelay, iRp}(1: end - 1)];
        % ANC: preprocess the secondary noise
        [group] = preprocessing(secondaryNoise(iRp, :), orderFilter, 1);
        % noise predicted by ANC
        [~, noiseAnc, ~] = leaky_lms(group, delayedSignal, step, leak);
        % signal recovered by ANC
        signalAnc{iDelay, iRp} = delayedSignal - noiseAnc;
        % prediction error square of ANC
        errorSquareAnc{iDelay, iRp} = (signal(nDiscards + 1: end) - signalAnc{iDelay, iRp}(nDiscards + 1: end)) .^ 2;
    end
    % mean square prediction error
    mspeAle(iDelay) = mean(cell2mat(errorSquareAle(iDelay, :)));
    mspeAnc(iDelay) = mean(cell2mat(errorSquareAnc(iDelay, :)));
    % mean signal value
    signalAleAvg{iDelay} = mean(cat(3, signalAle{iDelay, :}), 3);
    signalAncAvg{iDelay} = mean(cat(3, signalAnc{iDelay, :}), 3);
end
%% Result plot
% signal vs ALE prediction
figure;
for iDelay = 1: nDelays
    subplot(nDelays, 1, iDelay);
    % individual realisations
    for iRp = 1: nRps
        % noisy signals
        noisyPlot = plot(t, noisySignal{iDelay, iRp}, 'k');
        hold on;
        % predictions
        alePlot = plot(t, signalAle{iDelay, iRp}, 'b');
        hold on;
    end
    % original signal
    cleanPlot = plot(t, signal, 'r');
    hold off;
    grid on; grid minor;
    legend([noisyPlot, alePlot, cleanPlot], {'Noisy', 'ALE', 'Clean'});
    title(sprintf('Noisy, clean and ALE signals by linear predictor of order %d with delay %d', orderFilter, delay(iDelay)));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% signal vs ANC prediction
figure;
for iDelay = 1: nDelays
    subplot(nDelays, 1, iDelay);
    % individual realisations
    for iRp = 1: nRps
        % noisy signals
        noisyPlot = plot(t, noisySignal{iDelay, iRp}, 'k');
        hold on;
        % predictions
        ancPlot = plot(t, signalAnc{iDelay, iRp}, 'c');
        hold on;
    end
    % original signal
    cleanPlot = plot(t, signal, 'r');
    hold off;
    grid on; grid minor;
    legend([noisyPlot, ancPlot, cleanPlot], {'Noisy', 'ANC', 'Clean'});
    title(sprintf('Noisy, clean and ANC signals by linear predictor of order %d with delay %d', orderFilter, delay(iDelay)));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% ALE vs ANC: average signal
figure;
for iDelay = 1: nDelays
    subplot(nDelays, 1, iDelay);
    hold on;
    % ALE
    alePlot = plot(t, signalAleAvg{iDelay}, 'b');
    hold on;
    % ANC
    ancPlot = plot(t, signalAncAvg{iDelay}, 'c');
    hold on;
    % original signal
    cleanPlot = plot(t, signal, 'r');
    hold off;
    grid on; grid minor;
    legend([alePlot, ancPlot, cleanPlot], {'ALE', 'ANC', 'Clean'});
    title(sprintf('ALE, ANC and clean signals by linear predictor of order %d with delay %d', orderFilter, delay(iDelay)));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% ALE vs ANC: MSPE
figure;
% ALE
alePlot = plot(delay, pow2db(mspeAle), 'b');
hold on;
% ANC
ancPlot = plot(delay, pow2db(mspeAnc), 'c');
hold off;
grid on; grid minor;
legend([alePlot, ancPlot], {'ALE', 'ANC',});
title(sprintf('MSPE of ALE and ANC by linear predictor of order %d', orderFilter));
xlabel('Delay (sample)');
ylabel('MSPE (dB)');

