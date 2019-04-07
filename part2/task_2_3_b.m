clear; init;
%% Initialisation
% normalised sampling frequency
fSample = 1;
% length of signal
nSamples = 1e3;
% sampling time
t = (0: nSamples - 1) / fSample;
% amplitudes of sine waves
aSine = 1;
% normalised frequencies of sine waves
fSine = 5e-3;
% clean sinusoidal signal
signal = aSine * sin(2 * pi * fSine * t);
% number of realisations
nRps = 1e2;
% coefficients of noise as MA process (correspond to lags)
coefMa = [0 0.5];
% variance of innovations
variance = 1;
% learning step size
step = 0.01;
% delays of the linear predictor
delay = 3: 25;
% delay = 3;
% number of delays
nDelays = length(delay);
% filter order (length)
% orderFilter = 1: 20;
orderFilter = 5: 5: 20;
% number of orders
nOrders = length(orderFilter);
% LMS leakage
leak = 0;
% transient duration
nTransients = 50;
%% Generate noise
% generate MA model
maModel = arima('MA', coefMa, 'Variance', variance, 'Constant', 0);
% simulate noise by MA model
[maSignal, innovation] = simulate(maModel, nSamples, 'NumPaths', nRps);
% coloured noise by MA filter
colouredNoise = maSignal';
% white noise as innovation
whiteNoise = innovation';
%% Adaptive line enhancer
errorSquare = cell(nOrders, nDelays, nRps);
mspe = zeros(nOrders, nDelays);
for iOrder = 1: nOrders
    for iDelay = 1: nDelays
        for iRp = 1: nRps
            % add coloured noise
            noisySignal = signal + colouredNoise(iRp, :);
            % preprocess the signal corrupted by coloured noise 
            [group] = preprocessing(noisySignal, orderFilter(iOrder), delay(iDelay));
            % signal predicted by ALE
            [~, signalAle, ~] = leaky_lms(group, noisySignal, step, leak);
            % prediction error square
            errorSquare{iOrder, iDelay, iRp} = (signal(nTransients + 1: end) - signalAle(nTransients + 1: end)) .^ 2;
        end
        % mean square prediction error
        mspe(iOrder, iDelay) = mean(cell2mat(errorSquare(iOrder, iDelay, :)), 'all');
    end
end
%% Result plot
% MSPE vs delay
legendStr = cell(nOrders, 1);
% figure;
subplot(2, 1, 1);
for iOrder = 1: nOrders
    plot(delay, pow2db(mspe(iOrder, :)), 'LineWidth', 2);
    legendStr{iOrder} = sprintf('M = %d', orderFilter(iOrder));
    hold on;
end
grid on; grid minor;
legend(legendStr, 'location', 'southeast');
title('MSPE against delay and filter order');
xlabel('Delay (sample)');
ylabel('MSPE (dB)');
xlim([min(delay), max(delay)]);
% MSPE vs filter order
subplot(2, 1, 2);
nDelayPlots = 1;
legendStr = cell(nDelayPlots, 1);
for iDelayPlot = 1: nDelayPlots
    plot(orderFilter, pow2db(mspe(:, iDelayPlot)), 'LineWidth', 2);
    legendStr{iDelayPlot} = sprintf('\\Delta = %d', delay(iDelayPlot));
    hold on;
end
grid on; grid minor;
legend(legendStr, 'location', 'southeast');
title('MSPE against filter order');
xlabel('Filter order');
ylabel('MSPE (dB)');
