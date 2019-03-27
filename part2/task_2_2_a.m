clear; close all; init;
%% Initialisation
% length of signal
nSamples = 1e3;
% number of realisations
nRealisations = 1e2;
% coefficients of MA process
coefMa = 0.9;
nOrders = length(coefMa);
variance = 0.5;
delay = 1;
% learning step size
step = [0.01; 0.05; 0.1];
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
[maSignal, innovation] = simulate(maModel, nSamples, 'NumPaths', nRealisations);
% rows correspond to realisations
maSignal = maSignal';
innovation = innovation';
%% LMS with fixed step size
weightLms = cell(nSteps, nRealisations);
errorLms = cell(nSteps, nRealisations);
weightLmsAvg = cell(nSteps, 1);
errorSquareLmsAvg = cell(nSteps, 1);
for iStep = 1: nSteps
    for iRealisation = 1: nRealisations
        % delayed signal
        lagSignal = [zeros(1, delay), maSignal(iRealisation, 1: end - delay)];
        % grouped samples to approximate the value at certain instant
        [group] = preprocessing(innovation(iRealisation, :), nOrders + 1, delay);
        % weight by LMS
        [weightLms{iStep, iRealisation}, ~, errorLms{iStep, iRealisation}] = leaky_lms(group, lagSignal, step(iStep), leak);
    end
    % average weight
    weightLmsAvg{iStep} = mean(cat(3, weightLms{iStep, :}), 3);
    % average error square
    errorSquareLmsAvg{iStep} = mean(cat(3, errorLms{iStep, :}) .^ 2, 3);
end
%% GASS LMS
weightBenveniste = cell(1, nRealisations);
weightAng = cell(1, nRealisations);
weightMatthews = cell(1, nRealisations);
errorBenveniste = cell(1, nRealisations);
errorAng = cell(1, nRealisations);
errorMatthews = cell(1, nRealisations);
for iRealisation = 1: nRealisations
    % delayed signal
    lagSignal = [zeros(1, delay), maSignal(iRealisation, 1: end - delay)];
    % grouped samples to approximate the value at certain instant
    [group] = preprocessing(innovation(iRealisation, :), nOrders + 1, delay);
    % Benveniste
    [weightBenveniste{iRealisation}, ~, errorBenveniste{iRealisation}] = gass(group, lagSignal, stepInit, rate, leak, benveniste);
    % Ang-Farhang
    [weightAng{iRealisation}, ~, errorAng{iRealisation}] = gass(group, lagSignal, stepInit, rate, leak, ang);
    % Matthews-Xie
    [weightMatthews{iRealisation}, ~, errorMatthews{iRealisation}] = gass(group, lagSignal, stepInit, rate, leak, matthews);
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
title('Squared error curves for fixed and adaptive step sizes');
xlabel('Number of iterations (sample)');
ylabel('Squared error (dB)');
