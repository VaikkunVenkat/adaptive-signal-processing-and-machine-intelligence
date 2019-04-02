clear; close all; init;
%% Initialisation
ts = load('time-series.mat');
signal = (ts.y - mean(ts.y))';
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
% number of epochs
nEpochs = 100;
% number of samples to overfit (size of minibatch)
nSampleInit = 20;
%% biased tanh-LMS with pretrained weights
hInit = cell(nScales, 1);
predictionLmsPretrained = cell(nScales, 1);
errorSquareLmsAvgPretrained = zeros(nScales, 1);
predGainPretrained = zeros(nScales, 1);
% overfit the initial minibatch
% extend (repeat) the first minibatch
extBatch = repmat(signal(1: nSampleInit), 1, nEpochs);
% desired signal
desiredSignal = repmat([signal(2: nSampleInit), 0], 1, nEpochs);
% group the extended batch
[extGroup] = preprocessing(extBatch, orderAr, delay);
% augmented group for adaptive bias
augExtGroup = [ones(1, size(extGroup, 2)); extGroup];
for iScale = 1: nScales
    % overfit by tanh-LMS
    [hInit{iScale}, ~, ~] = lms_tanh(augExtGroup, desiredSignal, step, leak, scale(iScale));
end
% use initial weight to predict the entire series
% desired one-step ahead signal
desiredSignal = [signal(2: end), 0];
% delay and group the samples for estimation
[group] = preprocessing(signal, orderAr, delay);
% augmented group for adaptive bias
augGroup = [ones(1, size(group, 2)); group];
for iScale = 1: nScales
    % prediction by LMS
    [~, predictionLmsPretrained{iScale}, errorLms] = lms_tanh(augGroup, desiredSignal, step, leak, scale(iScale), hInit{iScale}(:, end));
    % mean square error
    errorSquareLmsAvgPretrained(iScale) = mean(abs(errorLms) .^ 2);
    % prediction gain
    predGainPretrained(iScale) = var(predictionLmsPretrained{iScale}) / var(errorLms);
end
%% Result plot
% prediction by pretrained tanh-LMS
figure;
for iScale = 1: nScales
    subplot(nScales, 1, iScale);
    plot(signal, 'k');
    hold on;
    plot(predictionLmsPretrained{iScale}, 'r');
    hold off;
    grid on; grid minor;
    legend('Zero-mean', 'Tanh-LMS');
    title(sprintf('One-step ahead prediction by biased tanh-LMS with pretrained weights scale %d', scale(iScale)));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% MSPE and prediction gain
figure;
yyaxis left;
plot(scale, errorSquareLmsAvgPretrained);
ylabel('MSPE(dB)');
yyaxis right;
plot(scale, predGainPretrained);
ylabel('Prediction gain');
grid on; grid minor;
legend('MSPE', 'Prediction gain', 'location', 'northwest');
title('Mean square prediction error of biased Tanh-LMS');
xlabel('Activation scale');
