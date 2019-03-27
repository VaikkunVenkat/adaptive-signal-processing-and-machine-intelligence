function [group] = preprocessing(signal, nOrders, delay)
% Function:
%   - return the delayed samples (previous values) used in AR prediction
%
% InputArg(s):
%   - signal: original signal
%   - nOrders: order of ARMA model (i.e. duration of memory)
%   - delay: delay in samples
%
% OutputArg(s):
%   - group: previous samples to predict the current signal value
%
% Comments:
%   - zero-padding depends on lag and delay
%
% Author & Date: Yang (i@snowztail.com) - 26 Mar 19

nSamples = length(signal);
group = zeros(nOrders, nSamples);

for iOrder = 1: nOrders
    % grouped samples to approximate the value at certain instant
    group(iOrder, :) = [zeros(1, iOrder + delay - 1), signal(1: nSamples - (iOrder + delay - 1))];
end
end
