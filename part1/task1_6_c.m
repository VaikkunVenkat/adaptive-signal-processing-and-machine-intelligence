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
errorTrainOls = norm(yTrain - yTrainOls, 'fro');
errorTestOls = norm(yTest - yTestOls, 'fro');
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
errorTrainPcr = norm(yTrain - yTrainPcrDenoised, 'fro');
errorTestPcr = norm(yTest - yTestPcrDenoised, 'fro');
%% Result plot
% % training set
% figure;
% plot(yTrain);
% hold on;
% plot(yTrainOls);
% hold on;
% plot(yTrainPcrDenoised);
% grid on; grid minor;
% legend('Original', 'OLS', 'PCR');
% title('Comparison of original and reproduced data');
% xlabel('Singular value index');
% ylabel('Magnitude');
