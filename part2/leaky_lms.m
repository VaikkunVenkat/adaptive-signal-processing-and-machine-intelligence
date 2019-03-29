function [weightLms, prediction, error] = leaky_lms(group, signal, step, leak)
% Function:
%   - leaky LMS adaptive predictor based on ARMA model
%
% InputArg(s):
%   - group: previous samples to predict the current signal value
%   - signal: desired signal
%   - step: learning step size
%   - leak: leakage coefficient
%
% OutputArg(s):
%   - weightLms: weight of LMS filter
%   - prediction: filter output
%   - error: prediction error vector
%
% Comments:
%   - may converge to incorrect values if autocovariance matrix is
%   rank-deficient
%
% Author & Date: Yang (i@snowztail.com) - 26 Mar 19

[order, nSamples] = size(group);
weightLms = zeros(order, nSamples + 1);
prediction = zeros(1, nSamples);
error = zeros(1, nSamples);

for iSample = 1: nSamples
    % predicted signal based on current weight and previous samples
    prediction(iSample) = weightLms(:, iSample)' * group(:, iSample);
    % prediction error
    error(iSample) = signal(iSample) - prediction(iSample);
    % update weight
    weightLms(:, iSample + 1) = (1 - step * leak) * weightLms(:, iSample) + step * error(iSample) * group(:, iSample);
end
% remove the first term
weightLms = weightLms(:, 2: end);
end

