clear; close all; init;
%% Initialisation
pcr = load('data/PCR_Data/PCAPCR.mat');
cleanSignal = pcr.X;
noisySignal = pcr.Xnoise;
%% SVD decomposition
% singular value of clean signal
[uClean, svClean, vClean] = svd(cleanSignal);
% rank of clean signal
rankClean = rank(cleanSignal);
% singular value of noisy signal
[uNoisy, svNoisy, vNoisy] = svd(noisySignal);
% rank of clean signal
rankNoisy = rank(noisySignal);
%% Reconstruct approximation
% reconstruct with first rankClean singular values and singular vectors
denoisedSignal = uNoisy(:, 1: rankClean) * svNoisy(1: rankClean, 1: rankClean) * vNoisy(:, 1: rankClean)';
% error norm by columns
errorNoise = norm(cleanSignal - noisySignal, 'fro');
errorDenoise = norm(cleanSignal - denoisedSignal, 'fro');
