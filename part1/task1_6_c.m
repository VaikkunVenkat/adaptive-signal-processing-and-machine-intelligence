clear; close all; init;
%% Initialisation
pcr = load('data/PCR_Data/PCAPCR.mat');
xClean = pcr.X;
xTrain = pcr.Xnoise;
xTest = pcr.Xtest;
yTrain = pcr.Y;
yTest = pcr.Ytest;
%% Ordinary least squares (OLS)
% regression matrix by training data
coefOls = (xTrain' * xTrain) \ xTrain' * yTrain;
% training and testing output by OLS regression model
yTrainOls = xTrain * coefOls;
yTestOls = xTest * coefOls;
% errors
errorTrainOls = abs(vecnorm(yTrain - yTrainOls)) .^ 2;
errorTestOls = abs(vecnorm(yTest - yTestOls)) .^ 2;
%% Principle component regression (PCR)
% rank of clean signal
rankClean = rank(xClean);
% singular value of noisy signals
[uTrain, sTrain, vTrain] = svd(xTrain);
[uTest, sTest, vTest] = svd(xTest);
% reconstruct denoised signals
xTrainDenoised = uTrain(:, 1: rankClean) * sTrain(1: rankClean, 1: rankClean) * vTrain(:, 1: rankClean)';
xTestDenoised = uTest(:, 1: rankClean) * sTest(1: rankClean, 1: rankClean) * vTest(:, 1: rankClean)';
% regression matrix by training data
coefPcr = vTrain(:, 1: rankClean) / sTrain(1: rankClean, 1: rankClean) * uTrain(:, 1: rankClean)' * yTrain;
% training and testing output by PCR regression model
yTrainPcrDenoised = xTrainDenoised * coefPcr;
yTestPcrDenoised = xTestDenoised * coefPcr;
% errors
errorTrainPcr = abs(vecnorm(yTrain - yTrainPcrDenoised)) .^ 2;
errorTestPcr = abs(vecnorm(yTest - yTestPcrDenoised)) .^ 2;
%% Result plot
% training set
figure;
subplot(2, 1, 1);
stem(errorTrainOls, 'r-o');
hold on;
stem(errorTrainPcr, 'b--x');
legend('OLS', 'PCR');
title('Difference between reproduced and original training data by OLS and PCR');
xlabel('Variable index');
ylabel('Error magnitude square');
% testing set
subplot(2, 1, 2);
stem(errorTestOls, 'r-o');
hold on;
stem(errorTestPcr, 'b--x');
legend('OLS', 'PCR');
title('Difference between reproduced and original testing data by OLS and PCR');
xlabel('Variable index');
ylabel('Error magnitude square');
