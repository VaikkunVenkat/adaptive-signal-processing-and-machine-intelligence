clear; close all; init;
%% Initialisation
ts = load('time-series.mat');
% signal = (ts.y - mean(ts.y))';
signal = ts.y';
% number of samples
nSamples = length(signal);
% learning rate
step = 1e-5;
% order of AR model
orderAr = 4;
% minimum delay of AR model
delay = 1;
% LMS leakage
leak = 0;
% scale on the activation function
scale = 10: 10: 100;
% number of scales
nScales = length(scale);
%% biased tanh-LMS
predictionLms = cell(nScales, 1);
errorSquareLmsAvg = zeros(nScales, 1);
predGain = zeros(nScales, 1);
% desired one-step ahead signal
% desiredSignal = [signal(2: end), 0];
desiredSignal = signal;
% delay and group the samples for estimation
[group] = preprocessing(signal, orderAr, delay);
% augmented group for adaptive bias
augGroup = [ones(1, size(group, 2)); group];
for iScale = 1: nScales
    % prediction by LMS
    [hLms, predictionLms{iScale}, errorLms] = lms_tanh(augGroup, desiredSignal, step, leak, scale(iScale));
    % mean square error
    errorSquareLmsAvg(iScale) = mean(abs(errorLms) .^ 2);
    % prediction gain
    predGain(iScale) = var(predictionLms{iScale}) / var(errorLms);
end
%% Result plot
figure;
for iScale = 1: nScales
    subplot(nScales, 1, iScale);
    plot(signal, 'k');
    hold on;
    plot(predictionLms{iScale}, 'r');
    hold off;
    grid on; grid minor;
    legend('Non-zero-mean', 'Tanh-LMS');
    title(sprintf('One-step ahead prediction by biased tanh-LMS a = %d', scale(iScale)));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% MSPE and prediction gain
figure;
yyaxis left;
plot(scale, errorSquareLmsAvg, 'LineWidth', 2);
ylabel('MSPE (dB)');
yyaxis right;
plot(scale, predGain, 'LineWidth', 2);
ylabel('Prediction gain');
grid on; grid minor;
legend('MSPE', 'Prediction gain', 'location', 'northwest');
title('MSPE and prediction gain of biased tanh-LMS');
xlabel('Activation scale');
