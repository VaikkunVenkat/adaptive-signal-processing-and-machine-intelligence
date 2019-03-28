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
sineWave = ampSine * sin(2 * pi * freqSine * t);
% number of realisations
nRealisations = 1e2;
% coefficients of noise as MA process
coefMa = [0 0.5];
nOrders = length(coefMa);
variance = 1;
% learning step size
step = 0.01;
% max delay of the linear predictor
nDelays = 5;
% filter length (order)
length = 5;
% LMS leakage
leak = 0;
% transient duration
nDiscards = 50;
%% Generate noise
% generate MA model
maModel = arima('MA', coefMa, 'Variance', variance, 'Constant', 0);
% simulate noise by MA model
[colourNoise, whiteNoise] = simulate(maModel, nSamples, 'NumPaths', nRealisations);
% rows correspond to realisations
colourNoise = colourNoise';
whiteNoise = whiteNoise';
%% Adaptive linear enhancer
signal = cell(nDelays, nRealisations);
prediction = cell(nDelays, nRealisations);
errorSquare = cell(nDelays, nRealisations);
mspe = zeros(nDelays, 1);
for iDelay = 1: nDelays
    for iRealisation = 1: nRealisations
        % noise-corrupted signal
        signal{iDelay, iRealisation} = sineWave + colourNoise(iRealisation, :);
        % grouped samples to approximate the value at certain instant
        [group] = preprocessing(signal{iDelay, iRealisation}, length, iDelay);
        % prediction by LMS
        [~, prediction{iDelay, iRealisation}, ~] = leaky_lms(group, signal{iDelay, iRealisation}, step, leak);
        % prediction error square
        errorSquare{iDelay, iRealisation} = (sineWave(nDiscards + 1: end) - prediction{iDelay, iRealisation}(nDiscards + 1: end)) .^ 2;
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
    for iRealisation = 1: nRealisations
        % noisy signals
        noisyPlot = plot(t, signal{iDelay, iRealisation}, 'k');
        hold on;
        % predictions
        predPlot = plot(t, prediction{iDelay, iRealisation}, 'b');
        hold on;
    end
    % original signal
    cleanPlot = plot(t, sineWave, 'r');
    hold off;
    grid on; grid minor;
    legend([noisyPlot, predPlot, cleanPlot], {'Noisy', 'Prediction', 'Clean'});
    title(sprintf('Prediction vs clean and noisy signals for ALE of filter length %d delay %d', length, iDelay));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% MSPE
figure;
plot(pow2db(mspe), 'm-x');
grid on; grid minor;
legend('MSPE');
title(sprintf('MSPE vs delay for ALE of filter length %d', length));
xlabel('Delay (sample)');
ylabel('MSPE (dB)');
