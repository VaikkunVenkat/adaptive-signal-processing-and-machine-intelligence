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
errorNoise = norm(xClean - xTrain, 'fro');
errorDenoise = norm(xClean - xTrainDenoised, 'fro');
