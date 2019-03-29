clear; close all; init;
%% Initialisation
% length of signal
nSamples = 1e3;
% number of realisations
nRps = 1e2;
% coefficients of MA process
coefMa = 0.9;
% variance of innovations
orderMa = length(coefMa);
% variance of innovations
variance = 0.5;
% delay for decorrelation
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
[maSignal, innovation] = simulate(maModel, nSamples, 'NumPaths', nRps);
% MA signal
maSignal = maSignal';
% white noise
innovation = innovation';
%% Benveniste GASS and GNGD
weightGass = cell(1, nRps);
errorGass = cell(1, nRps);
weightGngd = cell(1, nRps);
errorGngd = cell(1, nRps);
for iRp = 1: nRps
    % desired signal with unit delay
    signal = [zeros(1, delay), maSignal(iRp, 1: end - delay)];
    % order plus one to capture current innovation
    [group] = preprocessing(innovation(iRp, :), orderMa + 1, delay);
    % GASS algorithm
    [weightGass{iRp}, ~, errorGass{iRp}] = gass(group, signal, stepGass, rate, leak, benveniste);
    % GNGD algorithm
    [weightGngd{iRp}, ~, errorGngd{iRp}] = gngd(group, signal, stepGngd, rate, leak);
end
% average weights
weightGassAvg = mean(cat(3, weightGass{:}), 3);
weightGngdAvg = mean(cat(3, weightGngd{:}), 3);
% average errors square
errorSquareGassAvg = mean(cat(3, errorGass{:}) .^ 2, 3);
errorSquareGngdAvg = mean(cat(3, errorGngd{:}) .^ 2, 3);
%% Result plot
% weight error
figure;
plot(coefMa - weightGassAvg(2, :), 'k-');
hold on;
plot(coefMa - weightGngdAvg(2, :), 'r-.');
hold off;
grid on; grid minor;
legend('Benveniste GASS', 'GNGD', 'location', 'northeast');
title('Weight error curves by GASS and GNGD');
xlabel('Number of iterations (sample)');
ylabel('Weight error');
xlim([0 200]);
ylim([0 1]);
% average error square
figure;
plot(pow2db(errorSquareGassAvg), 'k-');
hold on;
plot(pow2db(errorSquareGngdAvg), 'r-.');
hold off;
grid on; grid minor;
legend('Benveniste GASS', 'GNGD', 'location', 'northeast');
title('Error square curves by GASS and GNGD');
xlabel('Number of iterations (sample)');
ylabel('Squared error (dB)');
