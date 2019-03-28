function [weightGass, prediction, error] = gass(group, signal, step, rate, leak, algorithm)
% Function:
%   - GASS (gradient adaptive stepsize) LMS predictor with adaptive step 
%   size based on ARMA model
%
% InputArg(s):
%   - group: previous samples to predict the current signal value
%   - signal: original signal
%   - step: initial step size
%   - rate: learning rate
%   - leak: leakage coefficient
%   - algorithm: select from 'Benveniste', 'Ang', 'Matthews'
%
% OutputArg(s):
%   - weightGass: weight of GASS LMS filter
%   - prediction: filter output
%   - error: prediction error vector
%
% Comments:
%   - adaptive step size by Benveniste, Ang-Farhang, Matthews-Xie
%
% Author & Date: Yang (i@snowztail.com) - 27 Mar 19

[nOrders, nSamples] = size(group);
weightGass = zeros(nOrders, nSamples + 1);
prediction = zeros(1, nSamples);
error = zeros(1, nSamples);
costFun = zeros(nOrders, nSamples + 1);
step(nSamples + 1) = 0;

for iSample = 1: nSamples
    % predicted signal based on current weight and previous samples
    prediction(iSample) = weightGass(:, iSample)' * group(:, iSample);
    % prediction error
    error(iSample) = signal(iSample) - prediction(iSample);
    % update weight
    weightGass(:, iSample + 1) = (1 - step(iSample) * leak) * weightGass(:, iSample) + step(iSample) * error(iSample) * group(:, iSample);
    % update step size by learning rate and cost function
    step(iSample + 1) = step(iSample) + rate * error(iSample) * group(:, iSample)' * costFun(:, iSample);
    % update cost function
    switch algorithm.name
        case 'Benveniste'
            costFun(:, iSample + 1) = (eye(nOrders) - step(iSample) * group(:, iSample) * group(:, iSample)') * costFun(:, iSample) + error(iSample) * group(:, iSample);
        case 'Ang'
            costFun(:, iSample + 1) = algorithm.param * costFun(:, iSample) + error(iSample) * group(:, iSample);
        case 'Matthews'
            costFun(:, iSample + 1) = error(iSample) * group(:, iSample);
    end
end
% remove the first term
weightGass = weightGass(:, 2: end);
end
