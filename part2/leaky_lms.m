function [wLms, prediction, error] = leaky_lms(prevGroup, rawData, step, leak)
% Function:
%   - LMS adaptive predictor based on AR model
%
% InputArg(s):
%   - prevGroup: previous samples to predict the current signal value
%   - rawData: original signal
%   - step: learning step size
%   - leak: leakage coefficient
%
% OutputArg(s):
%   - wLms: weight of LMS filter
%   - prediction: filter output
%   - error: prediction error vector
%
% Comments:
%   - zero-padding is necessary
%
% Author & Date: Yang (i@snowztail.com) - 26 Mar 19

[orderAr, nSamples] = size(prevGroup);
wLms = zeros(orderAr, nSamples);
prediction = zeros(1, nSamples);
error = zeros(1, nSamples);
for iSample = 1: nSamples
    prediction(iSample) = wLms(:, iSample)' * prevGroup(:, iSample);
    error(iSample) = rawData(iSample) - prediction(iSample);
    wLms(:, iSample + 1) = (1 - step * leak) * wLms(:, iSample) + step * error(iSample) * prevGroup(:, iSample);
end
% remove the first term
wLms = wLms(:, 2: end);
end

