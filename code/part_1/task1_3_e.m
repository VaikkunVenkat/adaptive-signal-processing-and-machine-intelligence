clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1024;
% sampling time
t = (0: nSamples - 1) / fSample;
% exponentials of normalised frequency: 0.3, 0.32
fExp = [0.3, 0.32];
% signal with 2 exponential components
expWave = exp(1i * 2 * pi * fExp(1) * t) + exp(1i * 2 * pi * fExp(2) * t);
% number of sampling points
point = 20: 10: 50;
% number of cases of sampling points
nPoints = length(point);
% noise power
pNoise = 0.2;
% number of random processes to generate
nRps = 1e2;
%% Exponentials of different length
psdMusic = cell(nPoints, nRps);
psdMusicMean = cell(nPoints, 1);
psdMusicStd = cell(nPoints, 1);
for iPoint = 1: nPoints
    for iRp = 1: nRps
        % noise
        noise = sqrt(pNoise / 2) * (randn(1, point(iPoint)) + 1i * randn(1, point(iPoint)));
        % noisy exponentials
        noisyExp = expWave(1: point(iPoint)) + noise;
        % obtain the unbiased correlation matrix with dimension 15-by-15
        [~, cor] = corrmtx(noisyExp, 14, 'mod');
        % spectrum estimation by MUSIC algorthm
        [psdMusic{iPoint, iRp}, f] = pmusic(cor, 2, [], fSample);
    end
    % mean
    psdMusicMean{iPoint} = mean(cell2mat(psdMusic(iPoint, :)), 2);
    % standard deviation
    psdMusicStd{iPoint} = std(cell2mat(psdMusic(iPoint, :)), [], 2);
end
%% Pseudospectrum plot
% mean
figure;
for iPoint = 1: nPoints
    subplot(nPoints, 2, 2 * (iPoint - 1) + 1);
    % individual realisations
    for iRp = 1: nRps
        irPlot = plot(f, psdMusic{iPoint, iRp}, 'k', 'LineWidth', 2);
        hold on;
    end
    meanPlot = plot(f, psdMusicMean{iPoint}, 'r', 'LineWidth', 2);
    grid on; grid minor;
    legend([irPlot, meanPlot], {'Individual', 'Mean'});
    title(['PSD estimate by MUSIC: N = ', num2str(point(iPoint))]);
    xlabel('Normalised frequency (\pi rad/sample)');
    ylabel('Pseudospectrum');
    xlim([0.25 0.40]);
end
% variance
for iPoint = 1: length(point)
    subplot(length(point), 2, 2 * iPoint);
    % individual realisations
    for iRp = 1: nRps
        irPlot = plot(f, psdMusic{iPoint, iRp}, 'k', 'LineWidth', 2);
        hold on;
    end
    stdPlot = plot(f, psdMusicStd{iPoint}, 'm', 'LineWidth', 2);
    grid on; grid minor;
    legend([irPlot, stdPlot], {'Individual', 'Standard deviation'});
    title(['Standard deviation of the MUSIC estimate: N = ', num2str(point(iPoint))]);
    xlabel('Normalised frequency (\pi rad/sample)');
    ylabel('Pseudospectrum');
    xlim([0.25 0.40]);
end
