clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% symmetrical frequency points
f = (-nSamples / 2: nSamples / 2 - 1) * (fSample / nSamples);
% signal with 1 exponential component
fExp1 = 0.3;
expWave{1} = exp(1i * 2 * pi * fExp1 * t);
% signal with 2 exponential components
fExp2 = [0.3, 0.32];
expWave{2} = exp(1i * 2 * pi * fExp2(1) * t) + exp(1i * 2 * pi * fExp2(2) * t);
% signal with 3 exponential components
fExp3 = [0.28, 0.3, 0.32];
expWave{3} = exp(1i * 2 * pi * fExp3(1) * t) + exp(1i * 2 * pi * fExp3(2) * t) + exp(1i * 2 * pi * fExp3(3) * t);
% number of exponential waves
nExps = 3;
% number of sampling points
point = 20: 10: 50;
% number of cases of sampling points
nPoints = length(point);
% noise power
pNoise = 0.2;
%% Exponentials of different frequencies and length
psd = cell(nExps, nPoints);
for iExp = 1: nExps
    for iPoint = 1: nPoints
        % noise
        noise = sqrt(pNoise / 2) * (randn(1, point(iPoint)) + 1i * randn(1, point(iPoint)));
        % noisy exponentials
        noisyExp = expWave{iExp}(1: point(iPoint)) + noise;
        % PSD with limited number of samples
        psd{iExp, iPoint} = abs(fftshift(fft(noisyExp, nSamples))) .^ 2 / point(iPoint);
    end
end
%% Result plot
legendStr = cell(nPoints, 1);
figure;
for iExp = 1: nExps
    subplot(nExps, 1, iExp);
    for iPoint = 1: nPoints
        plot(f, psd{iExp, iPoint}, 'LineWidth', 2);
        legendStr{iPoint} = ['N = ', num2str(point(iPoint))];
        hold on;
    end
    grid on; grid minor;
    title(sprintf('Periodogram of signal with %d exponential(s)', iExp));
    legend(legendStr);
    xlabel('Normalised frequency');
    ylabel('PSD');
    xlim([0.25, 0.4]);
end
