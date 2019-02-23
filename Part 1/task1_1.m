clear; close all;
%% Initialisation
fs = 1e2;
t = 0: 1 / fs: 1;
N = 1024;
f = [80 150];
% xn = sin(2 * pi * f(1) * t) + sin(2 * pi * f(2) * t) + randn(size(t));
xn = sin(2 * pi * f(1) * t) + sin(2 * pi * f(2) * t);
% xn = randn(size(t));
%% ACF
acf = xcorr(xn, 'coeff');
acfFt = abs(fft(acf, N));
%% PSD
psd = abs(fft(xn, N) .^ 2) / (N + 1);
%% Result
figure;
plot(psd);
hold on;
plot(acfFt);
grid on;
legend('PSD', 'FT of ACF');
title('A case when PSD is not equal to FT of ACF (N=1024)');
xlabel('Frequency (Hz)');
ylabel('Power (rad^2/Hz)');
