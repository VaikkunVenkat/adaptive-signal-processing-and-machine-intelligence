clear; close all; init;
%% Initialisation
% length of signal
nSamples = 1e3;
% number of realisations
nRps = 1e2;
% MA coefficients
coefMa = [1.5+1i, 2.5-0.5i];
% filter order (length)
orderFilter = 2;
% learning step size
step = 0.1;
% LMS leakage
leak = 0;
%% WLMA signal
% CSCG noise
whiteNoise = 1 / sqrt(2) * (randn(nRps, nSamples) + 1i * randn(nRps, nSamples));
% WLMA (1)
wlmaSignal = whiteNoise + coefMa(1) * [zeros(nRps, 1), whiteNoise(:, 1: end - 1)] + coefMa(2) * [zeros(nRps, 1), conj(whiteNoise(:, 1: end - 1))];
%% CLMS and ACLMS
errorClms = cell(nRps, 1);
errorAclms = cell(nRps, 1);
for iRp = 1: nRps
    % desired signal with unit delay
    delayedSignal = [0, conj(wlmaSignal(iRp, 1: end - 1))];
    % delay and group the white noise
    [group] = preprocessing(whiteNoise(iRp, :), orderFilter, 1);
    % prediction by CLMS
    [~, ~, errorClms{iRp}] = clms(group, delayedSignal, step, leak);
    % prediction by ACLMS
    [~, ~, ~, errorAclms{iRp}] = aclms(group, delayedSignal, step, leak);
end
errorSquareClmsAvg = mean(abs(cat(3, errorClms{:})) .^ 2, 3);
errorSquareAclmsAvg = mean(abs(cat(3, errorAclms{:})) .^ 2, 3);
%% Result plot
% CSCG noise vs WLMA process: instance
figure;
subplot(1, 2, 1);
scatter(real(whiteNoise(:)), imag(whiteNoise(:)), 1, 'k');
legend('White noise');
title('Circularity of white noise');
xlabel('Real part');
ylabel('Imaginary part');
subplot(1, 2, 2);
scatter(real(wlmaSignal(:)), imag(wlmaSignal(:)), 1, 'r');
legend('WLMA (1)');
title('Circularity of WLMA (1) process');
xlabel('Real part');
ylabel('Imaginary part');
% error
figure;
plot(pow2db(errorSquareClmsAvg));
hold on;
plot(pow2db(errorSquareAclmsAvg));
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS');
title('Learning curves of CLMS and ACLMS');
xlabel('Time (sample)');
ylabel('Error square (dB)');
