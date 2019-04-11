clear; close all; init;
%% Initialisation
eeg = load('data/EEG_Data/EEG_Data_Assignment2.mat');
% analog sampling frequency
fSample = eeg.fs;
% length of signal
nSamples = length(eeg.POz);
% FFT points
nFft = 2 ^ 13;
% remove mean
poz = (eeg.POz - mean(eeg.POz))';
% variance of white noise
variance = 0.01;
% sampling time
t = (0: nSamples - 1) / fSample;
% duration of window
tWindow = 5;
% number of samples of windows
nWindows = 2 ^ 12;
% window overlap length
nOverlaps = round(0.9 * nWindows);
% step size
step = [1e-2, 1e-3, 1e-4];
% number of steps
nSteps = length(step);
% filter order (length)
orderFilter = 5: 5: 15;
% number of orders
nOrders = length(orderFilter);
% LMS leakage
leak = 0;
% transient duration
nTransients = 50;
%% Generate noise
% amplitudes of sine waves
ampSine = 1;
% normalised frequencies of sine waves
freqSine = 50;
% clean sinusoidal signal
sine = ampSine * sin(2 * pi * freqSine * t);
noise = variance * randn(1, nSamples) + sine;
%% Adaptive noise cancellation
signalAnc = cell(nOrders, nSteps);
mspeAnc = zeros(nOrders, nSteps);
errorSquareAnc = cell(nOrders, nSteps);
% original signal with unit delay
delayedPoz = [0, poz(1: end - 1)];
for iOrder = 1: nOrders
    % ANC: preprocess the synthetic noise with unit delay
    [group] = preprocessing(noise, orderFilter(iOrder), 1);
    for iStep = 1: nSteps
        % noise predicted by ANC
        [~, noiseAnc, ~] = lms(group, delayedPoz, step(iStep), leak);
        % signal recovered by ANC
        signalAnc{iOrder, iStep} = delayedPoz - noiseAnc;
        % prediction error square of ANC
        errorSquareAnc{iOrder, iStep} = (poz(nTransients + 1: end) - signalAnc{iOrder, iStep}(nTransients + 1: end)) .^ 2;
        % MSPE
        mspeAnc(iOrder, iStep) = mean(errorSquareAnc{iOrder, iStep});
    end
end
% optimal parameters to suppress sinusoid without affecting others
orderOptimal = 10;
stepOptimal = 1e-3;
% optimal indexes
orderIndex = find(orderFilter == orderOptimal);
stepIndex = find(step == stepOptimal);
% PSD of original POz signal
[psdPoz, fAnalog] = periodogram(poz, rectwin(nSamples), nFft, fSample);
% PSD of optimal denoised POz signal
psdAnc = periodogram(signalAnc{orderIndex, stepIndex}, rectwin(nSamples), nFft, fSample);
%% Result plot
% reference spectrogram (by Hamming window)
figure;
spectrogram(poz, nWindows, nOverlaps, nFft, fSample, 'yaxis');
ylim([0 60]);
title('Spectrogram of preprocessed POz');
% specteograms by ALE with different order and step size
for iOrder = 1: nOrders
    figure;
    for iStep = 1: nSteps
        subplot(nSteps, 1, iStep);
        % spectrogram (by Hamming window)
        spectrogram(signalAnc{iOrder, iStep}, nWindows, nOverlaps, nFft, fSample, 'yaxis');
        ylim([0 60]);
        title(['Spectrogram of ANC signal by linear predictor M = ', num2str(orderFilter(iOrder)), sprintf(' and \\mu = '), num2str(step(iStep))]);
    end
end
% MSPE
figure;
legendStr = cell(nSteps, 1);
for iStep = 1: nSteps
    plot(orderFilter, pow2db(mspeAnc(:, iStep)), 'LineWidth', 2);
    legendStr{iStep} = [sprintf('\\mu = '), num2str(step(iStep))];
    hold on;
end
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'southeast');
title('MSPE against filter order and step size');
xlabel('Order');
ylabel('MSPE (dB)');
% periodograms of original and optimal denoised POz signals
figure;
subplot(2, 1, 1);
plot(fAnalog, pow2db(psdPoz), 'LineWidth', 2);
hold on;
plot(fAnalog, pow2db(psdAnc), 'LineWidth', 2);
hold off;
grid on; grid minor;
legend('Original', 'ANC');
title('Periodograms of original and optimal ANC POz');
xlabel('Frequency (Hz)');
ylabel('PSD (dB)');
xlim([0 60]);
ylim([-160 -100]);
% periodogram error
subplot(2, 1, 2);
plot(fAnalog, pow2db(abs(psdPoz - psdAnc)), 'm', 'LineWidth', 2);
grid on; grid minor;
legend('Absolute error');
title('Periodogram error by optimal ANC');
xlabel('Frequency (Hz)');
ylabel('PSD (dB)');
xlim([0 60]);
ylim([-160 -100]);
