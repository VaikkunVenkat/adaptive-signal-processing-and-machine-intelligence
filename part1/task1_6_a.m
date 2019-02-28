clear; close all; init;
%% Initialisation
pcr = load('data/PCR_Data/PCAPCR.mat');
xClean = pcr.X;
xTrain = pcr.Xnoise;
%% SVD decomposition
% singular value of clean signal
sClean = svd(xClean);
% rank of clean signal
rankClean = rank(xClean);
% singular value of noisy signal
sTrain = svd(xTrain);
% rank of clean signal
rankTrain = rank(xTrain);
% square error between singular values
error = abs(sClean - sTrain) .^ 2;
%% Result plot
% singular values
figure;
subplot(2, 1, 1);
stem(sTrain, 'k-x');
hold on;
stem(sClean, 'r--o');
legend('Noisy signal', 'Clean signal');
title('Singular values of noisy and clean signal');
xlabel('Singular value index');
ylabel('Magnitude');
% square error
subplot(2, 1, 2);
stem(error, 'm:s');
legend('Square error');
title('Square error between singular values of noisy and clean signal');
xlabel('Subspace dimension index');
ylabel('Error magnitude square');
