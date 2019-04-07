clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1500;
% length of signal
nSamples = 1500;
% variance of white noise
variance = 0.05;
% number of segmentations
nSegs = 3;
% length of segmentations
lengthSeg = 500;
% function to determine FM frequency
freqFunc = @(n) ((1 <= n) & (n <= 500)) .* 100 + ((501 <= n) & (n <= 1000)) .* (100 + (n - 500) / 2) + ((1001 <= n) & (n <= 1500)) .* (100 + ((n - 1000) / 25) .^ 2);
% frequency sequence
freqSeq = freqFunc(1: nSamples);
% phase sequence
phaseSeq = cumsum(freqSeq);
% filter order (length)
orderFilter = 1;
% learning step size
step = [1e0, 1e-1, 1e-2, 1e-3];
% number of step size
nSteps = length(step);
% LMS leakage
leak = 0;
% FM signal
fmSignal = exp(1i * 2 * pi / fSample * phaseSeq) + sqrt(variance / 2) * (randn(1, nSamples) + 1i * randn(1, nSamples));
% % number of evaluation points
% nPoints = 1024;
%% AR-CLMS and frequency analysis
psdArClms = cell(nSteps, 1);
% delay and group the FM signal
[group] = preprocessing(fmSignal, orderFilter, 1);
for iStep = 1: nSteps
    % prediction by CLMS
    [hArClms, ~, ~] = clms(group, fmSignal, step(iStep), leak);
    for iSample = 1: nSamples
        % frequency spectrum at each instant
        [hFreqArClms, fArClms] = freqz(1, [1; -conj(hArClms(iSample))], nSamples, fSample);
        % store PSD
        psdArClms{iStep}(:, iSample) = abs(hFreqArClms) .^ 2;
    end
    % remove outliers (50 times larger than median)
    medianPsdArClms = 50 * median(psdArClms{iStep}, 'all');
    psdArClms{iStep}(psdArClms{iStep} > medianPsdArClms) = medianPsdArClms;
end
%% Result plot
figure;
for iStep = 1: nSteps
    subplot(nSteps, 1, iStep);
    mesh(psdArClms{iStep});
    view(2);
    cbar = colorbar;
    cbar.Label.String = 'PSD (dB)';
    grid on; grid minor;
    legend(sprintf('CLMS-AR (%d)', orderFilter));
    title([sprintf('Time-frequency diagram of FM signal by CLMS \\mu = '), num2str(step(iStep))]);
    xlabel('Time (sample)');
    ylabel('Frequency (Hz)');
end
