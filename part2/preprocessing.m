function [prevGroup] = preprocessing(rawData, orderAr, delay)
% Function:
%   - return the delayed samples (previous values) used in AR prediction
%
% InputArg(s):
%   - rawData: original signal
%   - orderAr: order of AR model (i.e. duration of memory)
%   - delay: delay in samples
%
% OutputArg(s):
%   - prevGroup: previous samples to predict the current signal value
%
% Comments:
%   - zero-padding depends on lag and delay
%
% Author & Date: Yang (i@snowztail.com) - 26 Mar 19

nSamples = length(rawData);
prevGroup = zeros(orderAr, nSamples);
for iLag = 1: orderAr
    prevGroup(iLag, :) = [zeros(1, iLag + delay - 1), rawData(1: nSamples - (iLag + delay - 1))];
end
end
