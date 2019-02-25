clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% symmetrical frequency points
f = (-nSamples / 2: nSamples/ 2 - 1) * (fSample / nSamples);
% FFT points
nFft = 1024;
% exponentials of normalised frequency: 0.3, 0.32
freqExp{1} = [0.3, 0.32];
expWave{1} = exp(1i * 2 * pi * freqExp{1}(1) * t) + exp(1i * 2 * pi * freqExp{1}(2) * t);
% exponentials of normalised frequency: 0.12, 0.27, 0.35
freqExp{2} = [0.23 0.27 0.35];
expWave{2} = exp(1i * 2 * pi * freqExp{2}(1) * t) + exp(1i * 2 * pi * freqExp{2}(2) * t) + exp(1i * 2 * pi * freqExp{2}(3) * t);
% exponentials of normalised frequency: 0.1, 0.2, 0.3, 0.4
freqExp{3} = [0.1 0.2 0.3 0.4];
expWave{3} = exp(1i * 2 * pi * freqExp{3}(1) * t) + exp(1i * 2 * pi * freqExp{3}(2) * t) + exp(1i * 2 * pi * freqExp{3}(3) * t) + exp(1i * 2 * pi * freqExp{3}(4) * t);
% number of sampling points
nPoints = 20: 15: 50;
% noise power
noisePower = 0.2;
% declare vars
psd = cell(length(expWave), length(nPoints));
%% Exponentials of different frequencies and length
for iWave = 1: length(expWave)
    for iLength = 1: length(nPoints)
        % noise
        noise = sqrt(noisePower / 2) * (randn(1, nPoints(iLength)) + 1i * randn(1, nPoints(iLength)));
        % noisy exponentials
        noisyExp = expWave{iWave}(1: nPoints(iLength)) + noise;
        % PSD with limited number of samples
        psd{iWave, iLength} = abs(fftshift(fft(noisyExp, nFft))) .^ 2 / nPoints(iLength);
    end
end
%% Result plots
figure;
for iWave = 1: length(expWave)
    for iLength = 1: length(nPoints)
        subplot(length(expWave), length(nPoints), (iWave - 1) * length(nPoints) + iLength);
        plot(f, psd{iWave, iLength});
        grid on; grid minor;
        title(['N = ', sprintf('%d, ', nPoints(iLength)), 'f = ', sprintf('%.2f ', freqExp{iWave})]);
        xlabel('Normalised frequency');
        ylabel('PSD');
    end
end
