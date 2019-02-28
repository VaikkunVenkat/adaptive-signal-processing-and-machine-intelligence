clear; close all; init;
%% Initialisation
pcr = load('data/PCR_Data/PCAPCR.mat');
xClean = pcr.X;
xTrain = pcr.Xnoise;
yTrain = pcr.Y;
% number of realisations
nRealisations = 1e2;
% declare vars
errorOls = cell(nRealisations, 1);
errorPcr = cell(nRealisations, 1);
%% Training data modelling
% regression matrix by OLS
coefOls = (xTrain' * xTrain) \ xTrain' * yTrain;
% rank of clean signal
rankClean = rank(xClean);
% singular value of noisy signals
[uTrain, sTrain, vTrain] = svd(xTrain);
% regression matrix by PCR
coefPcr = vTrain(:, 1: rankClean) / sTrain(1: rankClean, 1: rankClean) * uTrain(:, 1: rankClean)' * yTrain;
%% Testing data generating
% generate test data and estimate based on regression matrix
for iRealisation = 1: nRealisations
    % OLS
    [yTest, yTestOls] = regval(coefOls);
    errorOls{iRealisation} = abs(vecnorm(yTest - yTestOls)) .^ 2;
    % PCR
    [yTest, yTestPcr] = regval(coefPcr);
    errorPcr{iRealisation} = abs(vecnorm(yTest - yTestPcr)) .^ 2;
end
errorOlsAvg = mean(cell2mat(errorOls));
errorPcrAvg = mean(cell2mat(errorPcr));
%% Result plot
figure;
stem(errorOlsAvg, 'r-o');
hold on;
stem(errorPcrAvg, 'b--x');
legend('OLS', 'PCR');
title('Mean square error between reproduced and original data by OLS and PCR');
xlabel('Variable index');
ylabel('Error magnitude square');
