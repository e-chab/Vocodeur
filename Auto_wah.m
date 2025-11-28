function y = Auto_wah(x, Fs, minFreq, maxFreq, Q)
% Effet Auto-wah : wah-wah dont la fréquence centrale dépend de l'enveloppe du signal
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
% minFreq, maxFreq : plage de balayage (Hz)
% Q : facteur de qualité du filtre

if nargin < 3, minFreq = 800; end
if nargin < 4, maxFreq = 1800; end
if nargin < 5, Q = 0.1; end

x = x(:);
N = length(x);

% Calcul de l'enveloppe du signal
env = abs(hilbert(x));
% Normalisation de l'enveloppe entre 0 et 1
env = (env - min(env)) / (max(env) - min(env));
% Fréquence centrale modulée par l'enveloppe
Fc = minFreq + (maxFreq - minFreq) * env;

f = 2 * sin((pi * Fc(1))/Fs);

% Initialisation
m = Q;
yh = zeros(N,1); yh(1) = x(1);
yb = zeros(N,1); yb(1) = f * yh(1);
yl = zeros(N,1); yl(1) = f * yb(1);

for n = 2:N
    yh(n) = x(n) - yl(n-1) - 2*m*yb(n-1);
    yb(n) = f * yh(n) + yb(n-1);
    yl(n) = f * yb(n) + yl(n-1);
    f = 2 * sin((pi*Fc(n))/Fs);
end

y = yb / max(abs(yb));
end
