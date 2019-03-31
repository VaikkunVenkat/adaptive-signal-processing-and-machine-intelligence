clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1e3;
% nominal frequency of three-phase system
fPower = 50;
% length of signal
nSamples = 1e3;
% number of phases
nPhases = 3;
% amplitudes of phases
amplitude = ones(nPhases, 1);
% phase shift
phaseShift = [0; -2/3 * pi; 2/3 * pi];
% phase delay of unbalanced system
phaseDelay = [0; 0.1 * pi; 0.2 * pi];
% initial phase
phaseInit = 0;
% sampling time
t = (0: nSamples - 1) / fSample;
% filter order (length)
orderFilter = 1;
% learning step size
step = 0.05;
% LMS leakage
leak = 0;
%% Balanced magnitude and phase
% balanced three-phase
balancedABC = amplitude .* cos(2 * pi * fPower * t + phaseInit + phaseShift);
% balanced two-axis (zero-component is zero)
balancedZeroAlphaBeta = clarke(balancedABC);
% complex Clarke voltage
balancedClarke = balancedZeroAlphaBeta(2, :) + 1i * balancedZeroAlphaBeta(3, :);
% circularity coefficient
[circularityBalanced, ~] = circularity(balancedClarke);
% delay and group the white noise
[groupBalanced] = preprocessing(balancedClarke, orderFilter, 1);
% prediction by CLMS
[hBalancedClms, ~, errorBalancedClms] = clms(groupBalanced, balancedClarke, step, leak);
% prediction by ACLMS
[hBalancedAclms, gBalancedAclms, ~, errorBalancedAclms] = aclms(groupBalanced, balancedClarke, step, leak);
% nominal frequency of balanced system
fPowerBalancedClms = abs(fSample / (2 * pi) * atan(imag(hBalancedClms) ./ real(hBalancedClms)));
fPowerBalancedAclms = abs(fSample / (2 * pi) * atan(sqrt(imag(hBalancedAclms) .^2 - abs(gBalancedAclms) .^ 2) ./ real(hBalancedAclms)));
%% Unbalanced phase
% three-phase with unbalanced phase
unbalancedABC = amplitude .* cos(2 * pi * fPower * t + phaseInit + phaseShift + phaseDelay);
% unbalanced two-axis (zero-component is non-zero)
unbalancedZeroAlphaBeta = clarke(unbalancedABC);
% complex Clarke voltage
unbalancedClarke = unbalancedZeroAlphaBeta(2, :) + 1i * unbalancedZeroAlphaBeta(3, :);
% circularity coefficient
[circularityUnbalanced, ~] = circularity(unbalancedClarke);
% delay and group the white noise
[groupUnbalanced] = preprocessing(unbalancedClarke, orderFilter, 1);
% prediction by CLMS
[hUnbalancedClms, ~, errorUnbalancedClms] = clms(groupUnbalanced, unbalancedClarke, step, leak);
% prediction by ACLMS
[hUnbalancedAclms, gUnbalancedAclms, ~, errorUnbalancedAclms] = aclms(groupUnbalanced, unbalancedClarke, step, leak);
% nominal frequency of balanced system
fPowerUnbalancedClms = abs(fSample / (2 * pi) * atan(imag(hUnbalancedClms) ./ real(hUnbalancedClms)));
fPowerUnbalancedAclms = abs(fSample / (2 * pi) * atan(sqrt(imag(hUnbalancedAclms) .^2 - abs(gUnbalancedAclms) .^ 2) ./ real(hUnbalancedAclms)));
%% Result plot
% frequency
figure;
subplot(2, 1, 1);
plot(fPowerBalancedClms);
hold on;
plot(fPowerBalancedAclms);
hold on;
plot([0 nSamples], [fPower fPower], 'k--');
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS', 'True');
title('Nominal frequency estimation for balanced system');
xlabel('Time (sample)');
ylabel('Frequency (Hz)');
ylim([0 100]);
subplot(2, 1, 2)
plot(fPowerUnbalancedClms);
hold on;
plot(fPowerUnbalancedAclms);
hold on;
plot([0 nSamples], [fPower fPower], 'k--');
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS', 'True');
title('Nominal frequency estimation for phase unbalanced system');
xlabel('Time (sample)');
ylabel('Frequency (Hz)');
ylim([0 100]);
% error
figure;
subplot(2, 1, 1);
plot(pow2db(abs(errorBalancedClms) .^ 2));
hold on;
plot(pow2db(abs(errorBalancedAclms) .^ 2));
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS');
title('Learning curves for balanced system');
xlabel('Time (sample)');
ylabel('Error square (dB)');
subplot(2, 1, 2);
plot(pow2db(abs(errorUnbalancedClms) .^ 2));
hold on;
plot(pow2db(abs(errorUnbalancedAclms) .^ 2));
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS');
title('Learning curves for phase unbalanced system');
xlabel('Time (sample)');
ylabel('Error square (dB)');
