clear; close all; init;
%% Initialisation
pcr = load('data/PCR_Data/PCAPCR.mat');
cleanSignal = pcr.X;
noisySignal = pcr.Xnoise;
%% SVD decomposition
% singular value of clean signal
svClean = svd(cleanSignal);
% rank of clean signal
rankClean = rank(cleanSignal);
% singular value of noisy signal
svNoisy = svd(noisySignal);
% rank of clean signal
rankNoisy = rank(noisySignal);
% square error between singular values
svError = abs(svClean - svNoisy) .^ 2;
%% Result plot
% singular values
figure;
stem(svClean);
hold on;
stem(svNoisy);
legend('Clean signal', 'Noisy signal');
title('Singular values of clean and noisy signal');
xlabel('Singular value index');
ylabel('Magnitude');
% square error
figure;
stem(svError, 'k');
legend('Square error');
title('Square error between singular values of clean and noisy signal');
xlabel('Singular value index');
ylabel('Magnitude square');
