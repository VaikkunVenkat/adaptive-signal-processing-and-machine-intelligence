function [weight, prediction, error] = lms_tanh(group, signal, step, leak, scale, weight)
% Function:
%   - nonlinear leaky LMS adaptive predictor based on ARMA model with tanh 
%   activation function
%
% InputArg(s):
%   - group: previous samples to predict the current signal value
%   - signal: desired signal
%   - step: learning step size
%   - leak: leakage coefficient
%   - scale: influence of the activation function
%   - weight: initial weight
%
% OutputArg(s):
%   - weight: weight of the filter
%   - prediction: filter output
%   - error: prediction error vector
%
% Comments:
%   - the scale should be carefully chosen to minimise MSE
%
% Author & Date: Yang (i@snowztail.com) - 2 Apr 19

[order, nSamples] = size(group);
prediction = zeros(1, nSamples);
error = zeros(1, nSamples);
weight(order, nSamples + 1) = 0;

for iSample = 1: nSamples
    % predicted signal based on current weight and previous samples
    prediction(iSample) = scale * tanh(weight(:, iSample)' * group(:, iSample));
    % prediction error
    error(iSample) = signal(iSample) - prediction(iSample);
    % update weight
    weight(:, iSample + 1) = (1 - step * leak) * weight(:, iSample) + step * error(iSample) * group(:, iSample);
end
% remove the first term
weight = weight(:, 2: end);
end

