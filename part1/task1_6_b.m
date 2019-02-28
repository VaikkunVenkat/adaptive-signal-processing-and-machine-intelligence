clear; close all; init;
%% Initialisation
pcr = load('data/PCR_Data/PCAPCR.mat');
xClean = pcr.X;
xTrain = pcr.Xnoise;
%% SVD decomposition
% singular value of clean signal
[uClean, sClean, vClean] = svd(xClean);
% rank of clean signal
rankClean = rank(xClean);
% singular value of noisy signal
[uTrain, sTrain, vTrain] = svd(xTrain);
% rank of noisy signal
rankTrain = rank(xTrain);
%% Reconstruct approximation
% reconstruct with first few singular values and singular vectors within
% signal subspace
xTrainDenoised = uTrain(:, 1: rankClean) * sTrain(1: rankClean, 1: rankClean) * vTrain(:, 1: rankClean)';
% error norm by columns
errorNoise = abs(vecnorm(xClean - xTrain)) .^ 2;
errorDenoise = abs(vecnorm(xClean - xTrainDenoised)) .^ 2;
%% Result plot
figure;
stem(errorNoise, 'k-x');
hold on;
stem(errorDenoise, 'r--o');
legend('Noisy signal', 'Denoised signal');
title('Difference between noisy and denoised signal compared with clean signal');
xlabel('Variable index');
ylabel('Error magnitude square');
