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
% order of AR model
orderAr = 1;
%% Signal generation and AR estimation
coefArEstSeg = cell(nSegs, 1);
hArSeg = cell(nSegs, 1);
fArSeg = cell(nSegs, 1);
psdArSeg = cell(nSegs, 1);
% FM signal
fmSignal = exp(1i * 2 * pi / fSample * phaseSeq) + sqrt(variance / 2) * (randn(1, nSamples) + 1i * randn(1, nSamples));
% AR parameter estimation of overall process via Yule-Walker method
coefArEst = aryule(fmSignal, orderAr);
% frequency response corresponding to AR(1)
[hAr, fAr] = freqz(1, coefArEst, nSamples, fSample);
% PSD by AR estimation
psdAr = abs(hAr) .^ 2;
% individual AR estimation on segmentations
for iSeg = 1: nSegs
    % AR parameter estimation of individual process via Yule-Walker method
    coefArEstSeg{iSeg} = aryule(fmSignal((iSeg - 1) * lengthSeg + 1: iSeg * lengthSeg), orderAr);
    % frequency response corresponding to AR(1)
    [hArSeg{iSeg}, fArSeg{iSeg}] = freqz(1, coefArEstSeg{iSeg}, nSamples / nSegs, fSample);
    % PSD by AR estimation
    psdArSeg{iSeg} = abs(hArSeg{iSeg}) .^ 2;
end
%% Result plot
% frequency and phase sequence
figure;
subplot(2, 1, 1);
plot(freqSeq);
grid on; grid minor;
legend('Frequency');
title('Frequency of FM signal');
xlabel('Time (sample)');
ylabel('Frequency (Hz)');
subplot(2, 1, 2);
plot(angle(exp(1i * 2 * pi / fSample * phaseSeq)));
grid on; grid minor;
legend('Phase');
title('Phase of FM signal');
xlabel('Time (sample)');
ylabel('Angle (rad)');
% overall
figure;
plot(fAr, pow2db(psdAr));
grid on; grid minor;
legend('AR (1)');
title('Overall estimation of FM signal by AR model');
xlabel('Frequency (Hz)');
ylabel('PSD (dB)');
% individual
figure;
for iSeg = 1: nSegs
    subplot(nSegs, 1, iSeg);
    plot(fArSeg{iSeg}, pow2db(psdArSeg{iSeg}));
    grid on; grid minor;
    legend('AR (1)');
    title(sprintf('Individual estimation of segment %d of FM signal by AR model', iSeg));
    xlabel('Frequency (Hz)');
    ylabel('PSD (dB)');
end
