clear; close all; init;
%% Initialisation
ts = load('time-series.mat');
% non-zero-mean signal
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
% number of epochs
nEpochs = 100;
% number of samples to overfit (size of minibatch)
nInits = 20;
%% Overfit the initial minibatch
hInit = cell(nScales, 1);
predictionLms = cell(nScales, 1);
errorSquareLmsAvg = zeros(nScales, 1);
predGain = zeros(nScales, 1);
% extend (repeat) the first minibatch
batch = repmat(signal(1: nInits), 1, nEpochs);
% group the extended batch
[batchGroup] = preprocessing(batch, orderAr, delay);
% augmented group for adaptive bias
augBatchGroup = [ones(1, size(batchGroup, 2)); batchGroup];
for iScale = 1: nScales
    % overfit by tanh-LMS
    [hInit{iScale}, ~, ~] = lms_tanh(augBatchGroup, batch, step, leak, scale(iScale));
    % store the last updated weight
    hInit{iScale} = hInit{iScale}(:, end);
end
%% Use initial weight to predict the entire series
% delay and group the samples for estimation
[group] = preprocessing(signal, orderAr, delay);
% augmented group for adaptive bias
augGroup = [ones(1, size(group, 2)); group];
for iScale = 1: nScales
    % prediction by LMS
    [~, predictionLms{iScale}, errorLms] = lms_tanh(augGroup, signal, step, leak, scale(iScale), hInit{iScale});
    % mean square error
    errorSquareLmsAvg(iScale) = mean(abs(errorLms) .^ 2);
    % prediction gain
    predGain(iScale) = var(predictionLms{iScale}) / var(errorLms);
end
predGainDb = pow2db(predGain);
%% Result plot
% prediction by pretrained tanh-LMS
figure;
for iScale = 1: nScales
    subplot(nScales, 1, iScale);
    plot(signal, 'k');
    hold on;
    plot(predictionLms{iScale}, 'r');
    hold off;
    grid on; grid minor;
    legend('Non-zero-mean', 'Tanh-LMS');
    title(sprintf('One-step ahead prediction by biased tanh-LMS with pretrained weights a = %d', scale(iScale)));
    xlabel('Time (sample)');
    ylabel('Amplitude');
end
% MSPE and prediction gain
figure;
yyaxis left;
plot(scale, errorSquareLmsAvg, 'LineWidth', 2);
ylabel('MSPE (dB)');
yyaxis right;
plot(scale, predGainDb, 'LineWidth', 2);
ylabel('Prediction gain (dB)');
grid on; grid minor;
legend('MSPE', 'Prediction gain', 'location', 'northwest');
title('MSPE and prediction gain of pretrained biased tanh-LMS');
xlabel('Activation scale');
