function [signalZeroAlphaBeta] = clarke(signalABC)
% Function: 
%   - power invariant version of the Clarke transform
%
% InputArg(s):
%   - signalABC: components of the three-phase system in the ABC reference 
%   frame (rows correspond to phases)
%
% OutputArg(s):
%   - signalZeroAlphaBeta: zero, alpha and beta components of the two-axis 
%   system in the stationary reference frame (rows correspond to phases)
%
% Comments:
%   - note the sequence is Zero-Alpha-Beta
%
% Author & Date: Yang (i@snowztail.com) - 31 Mar 19

clarkeMat = sqrt(2/3) * [sqrt(1/2) sqrt(1/2) sqrt(1/2); 1 -1/2 -1/2; 0 sqrt(3/4) -sqrt(3/4)];
signalZeroAlphaBeta = clarkeMat * signalABC;
end

