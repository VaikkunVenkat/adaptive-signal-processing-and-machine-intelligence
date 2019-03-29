clear; close all; init;
%% Initialisation
% length of signal
nSamples = 1e3;
% number of realisations
nRps = 1e2;
% coefficients of MA process (correspond to lags)
coefMa = 0.9;
% order of MA
orderMa = length(coefMa);
% variance of innovations
variance = 0.5;
% delay for decorrelation
delay = 1;
% learning step size
step = [0.01; 0.05; 0.1];
% number of steps
nSteps = length(step);
% initial step size for GASS
stepInit = 0.1;
% LMS leakage
leak = 0;
% learning rate
rate = 5e-3;
% algorithms
benveniste.name = 'Benveniste';
benveniste.param = NaN;
ang.name = 'Ang';
ang.param = 0.8;
matthews.name = 'Matthews';
matthews.param = NaN;
%% Generate signal
% generate MA model
maModel = arima('MA', coefMa, 'Variance', variance, 'Constant', 0);
% simulate signal by MA model
[maSignal, innovation] = simulate(maModel, nSamples, 'NumPaths', nRps);
% MA signal
maSignal = maSignal';
% white noise
innovation = innovation';
%% LMS with fixed step size
weightLms = cell(nSteps, nRps);
errorLms = cell(nSteps, nRps);
weightLmsAvg = cell(nSteps, 1);
errorSquareLmsAvg = cell(nSteps, 1);
for iStep = 1: nSteps
    for iRp = 1: nRps
        % desired signal with unit delay
        signal = [0, maSignal(iRp, 1: end - 1)];
        % order plus one to capture current innovation
        [group] = preprocessing(innovation(iRp, :), orderMa + 1, delay);
        % weight by LMS
        [weightLms{iStep, iRp}, ~, errorLms{iStep, iRp}] = leaky_lms(group, signal, step(iStep), leak);
    end
    % average weight
    weightLmsAvg{iStep} = mean(cat(3, weightLms{iStep, :}), 3);
    % average error square
    errorSquareLmsAvg{iStep} = mean(cat(3, errorLms{iStep, :}) .^ 2, 3);
end
%% GASS LMS
weightBenveniste = cell(1, nRps);
weightAng = cell(1, nRps);
weightMatthews = cell(1, nRps);
errorBenveniste = cell(1, nRps);
errorAng = cell(1, nRps);
errorMatthews = cell(1, nRps);
for iRp = 1: nRps
    % delayed signal
    signal = [zeros(1, delay), maSignal(iRp, 1: end - delay)];
    % grouped samples to approximate the value at certain instant
    [group] = preprocessing(innovation(iRp, :), orderMa + 1, delay);
    % Benveniste
    [weightBenveniste{iRp}, ~, errorBenveniste{iRp}] = gass(group, signal, stepInit, rate, leak, benveniste);
    % Ang-Farhang
    [weightAng{iRp}, ~, errorAng{iRp}] = gass(group, signal, stepInit, rate, leak, ang);
    % Matthews-Xie
    [weightMatthews{iRp}, ~, errorMatthews{iRp}] = gass(group, signal, stepInit, rate, leak, matthews);
end
% average weights
weightBenvenisteAvg = mean(cat(3, weightBenveniste{:}), 3);
weightAngAvg = mean(cat(3, weightAng{:}), 3);
weightMatthewsAvg = mean(cat(3, weightMatthews{:}), 3);
% average errors square
errorSquareBenvenisteAvg = mean(cat(3, errorBenveniste{:}) .^ 2, 3);
errorSquareAngAvg = mean(cat(3, errorAng{:}) .^ 2, 3);
errorSquareMatthewsAvg = mean(cat(3, errorMatthews{:}) .^ 2, 3);
%% Result plot
% weight error
legendStr = cell(nSteps + 3, 1);
figure;
for iStep = 1: nSteps
    plot(coefMa - weightLmsAvg{iStep}(2, :));
    legendStr{iStep} = sprintf('Fixed Step %.2f', step(iStep));
    hold on;
end
plot(coefMa - weightBenvenisteAvg(2, :), '-.');
legendStr{nSteps + 1} = 'Benveniste';
hold on;
plot(coefMa - weightAngAvg(2, :), '-.');
legendStr{nSteps + 2} = 'Ang-Farhang';
hold on;
plot(coefMa - weightMatthewsAvg(2, :), '-.');
legendStr{nSteps + 3} = 'Matthews-Xie';
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'northeast');
title('Weight error curves for fixed and adaptive step sizes');
xlabel('Number of iterations (sample)');
ylabel('Weight error');
xlim([0 200]);
ylim([0 1]);
% average error square
figure;
for iStep = 1: nSteps
    plot(pow2db(errorSquareLmsAvg{iStep}));
    legendStr{iStep} = sprintf('Fixed Step %.2f', step(iStep));
    hold on;
end
plot(pow2db(errorSquareBenvenisteAvg), '-.');
legendStr{nSteps + 1} = 'Benveniste';
hold on;
plot(pow2db(errorSquareAngAvg), '-.');
legendStr{nSteps + 2} = 'Ang-Farhang';
hold on;
plot(pow2db(errorSquareMatthewsAvg), '-.');
legendStr{nSteps + 3} = 'Matthews-Xie';
hold off;
grid on; grid minor;
legend(legendStr, 'location', 'northeast');
title('Error square curves for fixed and adaptive step sizes');
xlabel('Number of iterations (sample)');
ylabel('Squared error (dB)');
