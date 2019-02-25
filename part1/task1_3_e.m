clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% exponentials of normalised frequency: 0.3, 0.32
freqExp = [0.3, 0.32];
expWave = exp(1i * 2 * pi * freqExp(1) * t) + exp(1i * 2 * pi * freqExp(2) * t);
nPoints = 20: 15: 50;
% noise power
noisePower = 0.2;
% number of random processes to generate
nRps = 1e2;
% declare vars
psdMusic = cell(length(nPoints), nRps);
psdMusicMean = cell(length(nPoints), 1);
psdMusicStd = cell(length(nPoints), 1);
%% Exponentials of different length
for iLength = 1: length(nPoints)
    for iRp = 1: nRps
        % noise
        noise = sqrt(noisePower / 2) * (randn(1, nPoints(iLength)) + 1i * randn(1, nPoints(iLength)));
        % noisy exponentials
        noisyExp = expWave(1: nPoints(iLength)) + noise;
        % obtain the unbiased correlation matrix with dimension 15-by-15
        % - X: X'X is a biased estimate of the autocorrelation matrix
        % - cor: autocorrelation matrix estimate roughly equal to X'*X
        [~, cor] = corrmtx(noisyExp, 14, 'mod');
        % spectrum estimation by MUSIC algorthm
        % - psdMusic: pseudospectrum
        % - f: (normalised) frequency points
        [psdMusic{iLength, iRp}, f] = pmusic(cor, 2, [], fSample);
    end
    % mean
    psdMusicMean{iLength} = mean(cell2mat(psdMusic(iLength, :)), 2);
    % standard deviation
    psdMusicStd{iLength} = std(cell2mat(psdMusic(iLength, :)), [], 2);
end
%% Pseudospectrum plot
% mean
figure;
for iLength = 1: length(nPoints)
    subplot(length(nPoints), 1, iLength);
    % individual realisations
    for iRp = 1: nRps
        irPlot = plot(f, psdMusic{iLength, iRp}, 'linewidth', 2, 'color', 'k');
        hold on;
    end
    meanPlot = plot(f, psdMusicMean{iLength}, 'linewidth', 2, 'color', 'r'); 
    set(gca, 'xlim', [0.25 0.40]);
    grid on; grid minor;
    legend([irPlot, meanPlot], {'Realisations', 'Mean'});
    title(['PSD estimate by MUSIC (N = ', sprintf('%d, ', nPoints(iLength)), 'f =', sprintf(' %.2f ', freqExp), ')']);
    xlabel('Normalised frequency (\pi rad/sample)');
    ylabel('Pseudospectrum');
end
% variance
figure;
for iLength = 1: length(nPoints)
    subplot(length(nPoints), 1, iLength);
    % individual realisations
    for iRp = 1: nRps
        irPlot = plot(f, psdMusic{iLength, iRp}, 'linewidth', 2, 'color', 'k');
        hold on;
    end
    stdPlot = plot(f, psdMusicStd{iLength}, 'linewidth', 2, 'color', 'm'); 
    set(gca, 'xlim', [0.25 0.40]);
    grid on; grid minor;
    legend([irPlot, stdPlot], {'Realisations', 'Standard deviation'});
    title(['Standard deviation of the MUSIC estimate (N = ', sprintf('%d, ', nPoints(iLength)), 'f =', sprintf(' %.2f', freqExp), ')']);
    xlabel('Normalised frequency (\pi rad/sample)');
    ylabel('Pseudospectrum');
end
