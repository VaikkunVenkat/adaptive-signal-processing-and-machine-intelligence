function [weightGngd, prediction, error] = gngd(group, signal, step, rate, leak)
% Function:
%   - GNGD (generalised normalised gradient descent) NLMS predictor with 
%   normalised step size based on ARMA model
%
% InputArg(s):
%   - group: previous samples to predict the current signal value
%   - signal: original signal
%   - step: initial step size
%   - rate: learning rate
%   - leak: leakage coefficient
%
% OutputArg(s):
%   - weightGngd: weight of GNGD NLMS filter
%   - prediction: filter output
%   - error: prediction error vector
%
% Comments:
%   - NLMS is independent of signal power
%   - the regularisation factor is gradient adaptive (GNGD)
%   - both LMS and NLMS converge to Wiener solution
%
% Author & Date: Yang (i@snowztail.com) - 28 Mar 19

[order, nSamples] = size(group);
weightGngd = zeros(order, nSamples + 1);
prediction = zeros(1, nSamples);
error = zeros(1, nSamples);
regular = ones(1, nSamples + 1) / step;

for iSample = 1: nSamples
    % predicted signal based on current weight and previous samples
    prediction(iSample) = weightGngd(:, iSample)' * group(:, iSample);
    % prediction error
    error(iSample) = signal(iSample) - prediction(iSample);
    % update weight
    weightGngd(:, iSample + 1) = (1 - leak / regular(iSample)) * weightGngd(:, iSample) + 1 / (regular(iSample) + group(:, iSample)' * group(:, iSample)) * error(iSample) * group(:, iSample);
    % update regularisation factor by GNGD
    if iSample > 1
        regular(iSample + 1) = regular(iSample) - rate * step * error(iSample) * error(iSample - 1) * group(:, iSample)' * group(:, iSample - 1) / (regular(iSample - 1) + group(:, iSample - 1)' * group(:, iSample - 1)) ^ 2;
    end
end
% remove the first term
weightGngd = weightGngd(:, 2: end);
end
