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
sError = abs(sClean - sTrain) .^ 2;
%% Result plot
% singular values
figure;
stem(sClean);
hold on;
stem(sTrain);
legend('Clean signal', 'Noisy signal');
title('Singular values of clean and noisy signal');
xlabel('Singular value index');
ylabel('Magnitude');
% square error
figure;
stem(sError, 'k');
legend('Square error');
title('Square error between singular values of clean and noisy signal');
xlabel('Singular value index');
ylabel('Magnitude square');
