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
phaseDelay = [0; 0.2 * pi; 0.4 * pi];
% amplitude difference of unbalanced system
ampDif = 0.4;
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
unbalancedPhaseABC = amplitude .* cos(2 * pi * fPower * t + phaseInit + phaseShift + phaseDelay);
% unbalanced two-axis (zero-component is non-zero)
unbalancedPhaseZeroAlphaBeta = clarke(unbalancedPhaseABC);
% complex Clarke voltage
unbalancedPhaseClarke = unbalancedPhaseZeroAlphaBeta(2, :) + 1i * unbalancedPhaseZeroAlphaBeta(3, :);
% circularity coefficient
[circularityUnbalancedPhase, ~] = circularity(unbalancedPhaseClarke);
% delay and group the white noise
[groupUnbalancedPhase] = preprocessing(unbalancedPhaseClarke, orderFilter, 1);
% prediction by CLMS
[hUnbalancedPhaseClms, ~, errorUnbalancedPhaseClms] = clms(groupUnbalancedPhase, unbalancedPhaseClarke, step, leak);
% prediction by ACLMS
[hUnbalancedPhaseAclms, gUnbalancedPhaseAclms, ~, errorUnbalancedPhaseAclms] = aclms(groupUnbalancedPhase, unbalancedPhaseClarke, step, leak);
% nominal frequency of balanced system
fPowerUnbalancedPhaseClms = abs(fSample / (2 * pi) * atan(imag(hUnbalancedPhaseClms) ./ real(hUnbalancedPhaseClms)));
fPowerUnbalancedPhaseAclms = abs(fSample / (2 * pi) * atan(sqrt(imag(hUnbalancedPhaseAclms) .^2 - abs(gUnbalancedPhaseAclms) .^ 2) ./ real(hUnbalancedPhaseAclms)));
%% Unbalanced magnitude
% three-phase with unbalanced amplitude
unbalancedAmpABC = (amplitude + [-ampDif; 0; ampDif]) .* cos(2 * pi * fPower * t + phaseInit + phaseShift);
% unbalanced two-axis (zero-component is non-zero)
unbalancedAmpZeroAlphaBeta = clarke(unbalancedAmpABC);
% complex Clarke voltage
unbalancedAmpClarke = unbalancedAmpZeroAlphaBeta(2, :) + 1i * unbalancedAmpZeroAlphaBeta(3, :);
% circularity coefficient
[circularityUnbalancedAmp, ~] = circularity(unbalancedAmpClarke);
% delay and group the white noise
[groupUnbalancedAmp] = preprocessing(unbalancedAmpClarke, orderFilter, 1);
% prediction by CLMS
[hUnbalancedAmpClms, ~, errorUnbalancedAmpClms] = clms(groupUnbalancedAmp, unbalancedAmpClarke, step, leak);
% prediction by ACLMS
[hUnbalancedAmpAclms, gUnbalancedAmpAclms, ~, errorUnbalancedAmpAclms] = aclms(groupUnbalancedAmp, unbalancedAmpClarke, step, leak);
% nominal frequency of balanced system
fPowerUnbalancedAmpClms = abs(fSample / (2 * pi) * atan(imag(hUnbalancedAmpClms) ./ real(hUnbalancedAmpClms)));
fPowerUnbalancedAmpAclms = abs(fSample / (2 * pi) * atan(sqrt(imag(hUnbalancedAmpAclms) .^2 - abs(gUnbalancedAmpAclms) .^ 2) ./ real(hUnbalancedAmpAclms)));
%% Result plot
% frequency
figure;
% balanced
subplot(3, 1, 1);
plot(fPowerBalancedClms, 'LineWidth', 2);
hold on;
plot(fPowerBalancedAclms, 'LineWidth', 2);
hold on;
plot([0 nSamples], [fPower fPower], 'k--', 'LineWidth', 2);
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS', 'True');
title(sprintf('Frequency estimation for balanced system \\rho = 0'));
xlabel('Time (sample)');
ylabel('Frequency (Hz)');
ylim([0 100]);
% unbalanced phase
subplot(3, 1, 2)
plot(fPowerUnbalancedPhaseClms, 'LineWidth', 2);
hold on;
plot(fPowerUnbalancedPhaseAclms, 'LineWidth', 2);
hold on;
plot([0 nSamples], [fPower fPower], 'k--', 'LineWidth', 2);
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS', 'True');
title(sprintf('Frequency estimation for phase unbalanced system \\rho = %.2f', circularityUnbalancedPhase));
xlabel('Time (sample)');
ylabel('Frequency (Hz)');
ylim([0 100]);
% unbalanced magnitude
subplot(3, 1, 3)
plot(fPowerUnbalancedAmpClms, 'LineWidth', 2);
hold on;
plot(fPowerUnbalancedAmpAclms, 'LineWidth', 2);
hold on;
plot([0 nSamples], [fPower fPower], 'k--', 'LineWidth', 2);
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS', 'True');
title(sprintf('Frequency estimation for magnitude unbalanced system \\rho = %.2f', circularityUnbalancedAmp));
xlabel('Time (sample)');
ylabel('Frequency (Hz)');
ylim([0 100]);
% error
figure;
% balanced
subplot(3, 1, 1);
plot(pow2db(abs(errorBalancedClms) .^ 2), 'LineWidth', 2);
hold on;
plot(pow2db(abs(errorBalancedAclms) .^ 2), 'LineWidth', 2);
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS');
title(sprintf('Learning curves for balanced system \\rho = 0'));
xlabel('Time (sample)');
ylabel('Error square (dB)');
% unbalanced phase
subplot(3, 1, 2);
plot(pow2db(abs(errorUnbalancedPhaseClms) .^ 2), 'LineWidth', 2);
hold on;
plot(pow2db(abs(errorUnbalancedPhaseAclms) .^ 2), 'LineWidth', 2);
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS');
title(sprintf('Learning curves for phase unbalanced system \\rho = %.2f', circularityUnbalancedPhase));
xlabel('Time (sample)');
ylabel('Error square (dB)');
% unbalanced magnitude
subplot(3, 1, 3);
plot(pow2db(abs(errorUnbalancedAmpClms) .^ 2), 'LineWidth', 2);
hold on;
plot(pow2db(abs(errorUnbalancedAmpAclms) .^ 2), 'LineWidth', 2);
hold off;
grid on; grid minor;
legend('CLMS', 'ACLMS');
title(sprintf('Learning curves for magnitude unbalanced system \\rho = %.2f', circularityUnbalancedAmp));
xlabel('Time (sample)');
ylabel('Error square (dB)');
