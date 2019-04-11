clear; close all; init;
%% Initialisation
% normalised sampling frequency
fSample = 1e4;
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
% initial phase
phaseInit = 0;
% sampling time
t = (0: nSamples - 1) / fSample;
%% Balanced magnitude and phase
% balanced three-phase
balancedABC = amplitude .* cos(2 * pi * fPower * t + phaseInit + phaseShift);
% balanced two-axis (zero-component is zero)
balancedZeroAlphaBeta = clarke(balancedABC);
% complex Clarke voltage
balancedClarke = balancedZeroAlphaBeta(2, :) + 1i * balancedZeroAlphaBeta(3, :);
% circularity coefficient
[circularityBalanced, ~] = circularity(balancedClarke);
%% Unbalanced magnitude
ampDif = 0.2: 0.2: 0.8;
nAmps = length(ampDif);
unbalancedClarkeAmp = cell(nAmps, 1);
circularityUnbalancedAmp = zeros(nAmps, 1);
for iAmp = 1: nAmps
    % three-phase with unbalanced magnitude
    unbalancedABCAmp = (amplitude + [-ampDif(iAmp); 0; ampDif(iAmp)]) .* cos(2 * pi * fPower * t + phaseInit + phaseShift);
    % unbalanced two-axis (zero-component is non-zero)
    unbalancedZeroAlphaBetaAmp = clarke(unbalancedABCAmp);
    % complex Clarke voltage
    unbalancedClarkeAmp{iAmp} = unbalancedZeroAlphaBetaAmp(2, :) + 1i * unbalancedZeroAlphaBetaAmp(3, :);
    % circularity coefficient
    [circularityUnbalancedAmp(iAmp), ~] = circularity(unbalancedClarkeAmp{iAmp});
end
%% Unbalanced phase
phaseDif = 0.05: 0.05: 0.2;
nPhases = length(phaseDif);
unbalancedClarkePhase = cell(nPhases, 1);
circularityUnbalancedPhase = zeros(nPhases, 1);
for iPhase = 1: nPhases
    % phase delay
    phaseDelay = [0; -phaseDif(iPhase) * pi; phaseDif(iPhase) * pi];
    % three-phase with unbalanced phase
    unbalancedABCPhase = amplitude .* cos(2 * pi * fPower * t + phaseInit + phaseShift + phaseDelay);
    % unbalanced two-axis (zero-component is non-zero)
    unbalancedZeroAlphaBetaPhase = clarke(unbalancedABCPhase);
    % complex Clarke voltage
    unbalancedClarkePhase{iPhase} = unbalancedZeroAlphaBetaPhase(2, :) + 1i * unbalancedZeroAlphaBetaPhase(3, :);
    % circularity coefficient
    [circularityUnbalancedPhase(iPhase), ~] = circularity(unbalancedClarkePhase{iPhase});
end
%% Result plot
% Balanced vs unbalanced magnitude
legendStr = cell(nAmps + 1, 1);
figure;
subplot(1, 2, 1);
scatter(real(balancedClarke), imag(balancedClarke), 'k');
legendStr{1} = sprintf('Balanced \\rho = %.2f', circularityBalanced);
hold on;
for iAmp = 1: nAmps
    scatter(real(unbalancedClarkeAmp{iAmp}), imag(unbalancedClarkeAmp{iAmp}));
    legendStr{iAmp + 1} = sprintf('\\DeltaV = %.1f \\rho = %.2f', ampDif(iAmp), circularityUnbalancedAmp(iAmp));
    hold on;
end
legend(legendStr);
title('Circularity diagram with unbalanced magnitudes');
xlabel('Real part');
ylabel('Imaginary part');
xlim([-2 2]);
ylim([-2 2]);
set(gcf, 'position', [10, 10, 500, 500])
% Balanced vs unbalanced phase
legendStr = cell(nPhases + 1, 1);
subplot(1, 2, 2);
scatter(real(balancedClarke), imag(balancedClarke), 'k');
legendStr{1} = sprintf('Balanced \\rho = %.2f', circularityBalanced);
hold on;
for iPhase = 1: nPhases
    scatter(real(unbalancedClarkePhase{iPhase}), imag(unbalancedClarkePhase{iPhase}));
    legendStr{iPhase + 1} = sprintf('\\Delta\\phi = %.2f\\pi \\rho = %.2f', phaseDif(iPhase), circularityUnbalancedPhase(iPhase));
    hold on;
end
legend(legendStr);
title('Circularity diagram with unbalanced phases');
xlabel('Real part');
ylabel('Imaginary part');
xlim([-2 2]);
ylim([-2 2]);
set(gcf, 'position', [10, 10, 500, 500])
