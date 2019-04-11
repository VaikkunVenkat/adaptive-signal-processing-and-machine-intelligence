function [hAclms, gAclms, prediction, error] = aclms(group, signal, step, leak)
% Function:
%   - augmented complex LMS adaptive predictor based on WL-ARMA model
%
% InputArg(s):
%   - group: previous samples to predict the current signal value
%   - signal: desired signal
%   - step: learning step size
%   - leak: leakage coefficient
%
% OutputArg(s):
%   - hAclms: weight on the original signal
%   - gAclms: weight on the conjugate signal
%   - prediction: filter output
%   - error: prediction error vector
%
% Comments:
%   - the ACLMS outperforms CLMS for second order noncircular signals
%
% Author & Date: Yang (i@snowztail.com) - 30 Mar 19

[order, nSamples] = size(group);
hAclms = zeros(order, nSamples + 1);
gAclms = zeros(order, nSamples + 1);
prediction = zeros(1, nSamples);
error = zeros(1, nSamples);

for iSample = 1: nSamples
    % predicted signal based on current weight and previous samples
    prediction(iSample) = hAclms(:, iSample)' * group(:, iSample) + gAclms(:, iSample)' * conj(group(:, iSample));
    % prediction error
    error(iSample) = signal(iSample) - prediction(iSample);
    % update weight
    hAclms(:, iSample + 1) = (1 - step * leak) * hAclms(:, iSample) + step * conj(error(iSample)) * group(:, iSample);
    gAclms(:, iSample + 1) = (1 - step * leak) * gAclms(:, iSample) + step * conj(error(iSample)) * conj(group(:, iSample));
end
% remove the first term
hAclms = hAclms(:, 2: end);
gAclms = gAclms(:, 2: end);
end
