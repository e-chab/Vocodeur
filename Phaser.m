function y = phaser(x, Fs, rate, depth)
% Effet phaser : balayage de phase sur le signal
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
% rate : fréquence de modulation (Hz)
% depth : profondeur de l'effet (0 à 1)


if nargin < 3, rate = 0.5; end % Fréquence de modulation par défaut (Hz)
if nargin < 4, depth = 0.7; end % Profondeur par défaut (0 à 1)

if size(x,2) > 1
    x = mean(x,2); % Convertir en mono si nécessaire
end
N = length(x);
y = zeros(size(x));

% Paramètres du filtre all-pass
M = 4; % nombre d'étages
f_mod = rate; % fréquence de modulation
LFO = depth * sin(2*pi*f_mod*(0:N-1)/Fs); % LFO sinus

for n = 1:N
    xn = x(n);
    for m = 1:M
        % Coefficient all-pass modulé
        a = 0.7 + 0.3 * LFO(n);
        if n == 1
            y(n) = xn;
        else
            y(n) = a * y(n-1) + xn - a * y(n);
        end
        xn = y(n);
    end
end

% Normalisation
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end
