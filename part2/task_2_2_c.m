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
% initial step size for GASS and GNGD
stepGass = 0.1;
stepGngd = 0.1;
% LMS leakage
leak = 0;
% learning rate
rate = 5e-3;
% algorithms
benveniste.name = 'Benveniste';
benveniste.param = NaN;
%% Generate signal
% generate MA model
maModel = arima('MA', coefMa, 'Variance', variance, 'Constant', 0);
% simulate signal by MA model
[maSignal, innovation] = simulate(maModel, nSamples, 'NumPaths', nRealisations);
% rows correspond to realisations
maSignal = maSignal';
innovation = innovation';
%% Benveniste GASS
weightBenveniste = cell(1, nRealisations);
errorBenveniste = cell(1, nRealisations);
for iRealisation = 1: nRealisations
    % delayed signal
    lagSignal = [zeros(1, delay), maSignal(iRealisation, 1: end - delay)];
    % grouped samples to approximate the value at certain instant
    [group] = preprocessing(innovation(iRealisation, :), nOrders + 1, delay);
    % Benveniste
    [weightBenveniste{iRealisation}, ~, errorBenveniste{iRealisation}] = gass(group, lagSignal, stepGass, rate, leak, benveniste);
end
% average weights
weightBenvenisteAvg = mean(cat(3, weightBenveniste{:}), 3);
% average errors square
errorSquareBenvenisteAvg = mean(cat(3, errorBenveniste{:}) .^ 2, 3);
%% GNGD
weightGngd = cell(1, nRealisations);
errorGngd = cell(1, nRealisations);
for iRealisation = 1: nRealisations
    % delayed signal
    lagSignal = [zeros(1, delay), maSignal(iRealisation, 1: end - delay)];
    % grouped samples to approximate the value at certain instant
    [group] = preprocessing(innovation(iRealisation, :), nOrders + 1, delay);
    % weight by NLMS
    [weightGngd{iRealisation}, ~, errorGngd{iRealisation}] = gngd(group, lagSignal, stepGngd, leak, rate);
end
% average weight
weightGngdAvg = mean(cat(3, weightGngd{:}), 3);
% average error square
errorSquareNlmsAvg = mean(cat(3, errorGngd{:}) .^ 2, 3);
%% Result plot
% weight error
figure;
plot(coefMa - weightBenvenisteAvg(2, :), 'k-');
hold on;
plot(coefMa - weightGngdAvg(2, :), 'r-.');
hold off;
grid on; grid minor;
legend('Benveniste GASS', 'GNGD', 'location', 'northeast');
title('Weight error curves for adaptive and normalised step sizes by GASS and GNGD');
xlabel('Number of iterations (sample)');
ylabel('Weight error');
xlim([0 200]);
ylim([0 1]);

% average error square
figure;
plot(pow2db(errorSquareBenvenisteAvg), 'k-');
hold on;
plot(pow2db(errorSquareNlmsAvg), 'r-.');
hold off;
grid on; grid minor;
legend('Benveniste GASS', 'GNGD', 'location', 'northeast');
title('Squared error curves for adaptive and normalised step sizes by GASS and GNGD');
xlabel('Number of iterations (sample)');
ylabel('Squared error (dB)');
