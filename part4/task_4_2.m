clear; close all; init;
%% Initialisation
ts = load('time-series.mat');
signal = (ts.y - mean(ts.y))';
% learning rate
step = 1e-5;
% order of AR model
orderAr = 4;
% minimum delay of AR model
delay = 1;
% LMS leakage
leak = 0;
% scale on the activation function
scale = 1;
%% tanh-LMS
% delay and group the samples for estimation
[group] = preprocessing(signal, orderAr, delay);
% prediction by LMS
[hLms, predictionLms, errorLms] = lms_tanh(group, signal, step, leak, scale);
% mean square error
errorSquareLmsAvg = mean(abs(errorLms) .^ 2);
% prediction gain
predGain = var(predictionLms) / var(errorLms);
predGainDb = pow2db(predGain);
%% Result plot
figure;
plot(signal, 'k');
hold on;
plot(predictionLms, 'r');
hold off;
grid on; grid minor;
legend('Zero-mean', 'Tanh-LMS');
title('Zero-mean signal and one-step ahead prediction by tanh-LMS with unit scale');
xlabel('Time (sample)');
ylabel('Amplitude');
% print results
fprintf('MSE: %.4f dB\n', pow2db(errorSquareLmsAvg));
fprintf('Prediction gain %.4f dB\n', predGainDb);
