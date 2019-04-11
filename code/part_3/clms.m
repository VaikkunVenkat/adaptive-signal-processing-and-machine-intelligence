function [hClms, prediction, error] = clms(group, signal, step, leak)
% Function:
%   - complex LMS adaptive predictor based on WL-ARMA model
%
% InputArg(s):
%   - group: previous samples to predict the current signal value
%   - signal: desired signal
%   - step: learning step size
%   - leak: leakage coefficient
%
% OutputArg(s):
%   - hClms: weight on the original signal
%   - prediction: filter output
%   - error: prediction error vector
%
% Comments:
%   - may converge in mean or error square
%
% Author & Date: Yang (i@snowztail.com) - 30 Mar 19

[order, nSamples] = size(group);
hClms = zeros(order, nSamples + 1);
prediction = zeros(1, nSamples);
error = zeros(1, nSamples);

for iSample = 1: nSamples
    % predicted signal based on current weight and previous samples
    prediction(iSample) = hClms(:, iSample)' * group(:, iSample);
    % prediction error
    error(iSample) = signal(iSample) - prediction(iSample);
    % update weight
    hClms(:, iSample + 1) = (1 - step * leak) * hClms(:, iSample) + step * conj(error(iSample)) * group(:, iSample);
end
% remove the first term
hClms = hClms(:, 2: end);
end
