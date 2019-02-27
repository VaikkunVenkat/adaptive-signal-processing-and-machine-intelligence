clear; close all; init;
%% Initialisation
pcr = load('data/PCR_Data/PCAPCR.mat');
%% SVD decomposition
% singular value of clean signal
svClean = svd(pcr.X);
% rank of clean signal
rankClean = rank(pcr.X);
% singular value of noisy signal
svNoisy = svd(pcr.Xnoise);
% rank of clean signal
rankNoisy = rank(pcr.Xnoise);
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
