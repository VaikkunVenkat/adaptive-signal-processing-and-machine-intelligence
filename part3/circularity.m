function [circularityCoef, circularityQuot] = circularity(signal)
% Function:
%   - return the circularity coefficient and quotient of the given signal
%
% InputArg(s):
%   - signal: complex vector
%
% OutputArg(s):
%   - circularityCoef: circularity coefficient
%   - circularityQuot: circularity quotient
%
% Comments:
%   - quotient is complex while coefficient is real
%   - both measure the degree of non-circularity
%
% Author & Date: Yang (i@snowztail.com) - 30 Mar 19

% covariance
cov = mean(abs(signal) .^ 2);
% pseudocovariance
pseudoCov = mean(signal .^ 2);
% circularity coefficient
circularityCoef = abs(pseudoCov) / cov;
% circularity quotient
circularityQuot = pseudoCov / cov;
end

