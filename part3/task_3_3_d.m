clear; close all; init;
%% Initialisation
eeg = load('data/EEG_Data/EEG_Data_Assignment1.mat');
% analog sampling frequency
fSample = eeg.fs;
% remove mean
poz = (eeg.POz - mean(eeg.POz))';
% length of segment
nSamples = 1200;
% index of segment start position
pos = 1000;
% choose a segment to reduce the computational burden
poz = poz(pos: pos + nSamples - 1);
% learning step size
step = 1;
% LMS leakage
leak = [0, 1e-3, 1e-2];
% number of leaks
nLeaks = length(leak);
% DFT matrix (row complex phasor as filter input)
dftMat = 1 / nSamples * exp(1i * (1: nSamples)' * pi / nSamples * (0: nSamples - 1));
% % frequency points
% f = (0: nSamples - 1) .* (fSample / nSamples);
%% DFT-CLMS
psdDftClms = cell(nLeaks, 1);
for iLeak = 1: nLeaks
    % CLMS: complex phasor (DFT) -> FM signal
    [hFreqDftClms, ~, ~] = clms(dftMat, poz, step, leak(iLeak));
    % store PSD
    psdDftClms{iLeak} = abs(hFreqDftClms) .^ 2;
    % remove outliers (50 times larger than median)
    medianPsdDftClms = 50 * median(psdDftClms{iLeak}, 'all');
    psdDftClms{iLeak}(psdDftClms{iLeak} > medianPsdDftClms) = medianPsdDftClms;
end
%% Result plot
figure;
for iLeak = 1: nLeaks
    % DFT-CLMS
    subplot(nLeaks, 1, iLeak);
    mesh(psdDftClms{iLeak});
    view(2);
    cbar = colorbar;
    cbar.Label.String = 'PSD (dB)';
    grid on; grid minor;
    legend('DFT-CLMS');
    title(['Time-frequency diagram of EEG signal by DFT-CLMS of step ', num2str(step), ' leak ', num2str(leak(iLeak))]);
    xlabel('Time (sample)');
    ylabel('Frequency (Hz)');
    ylim([0 100]);
end
