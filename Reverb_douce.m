function y = Reverb2(x, Fs, decay, mix)
% Effet Reverb2 : ajoute une réverbération simple par convolution
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
% decay : temps de décroissance (s, défaut 0.5)
% mix : proportion du signal réverbéré (0 à 1, défaut 0.5)

if nargin < 3, decay = 0.5; end
if nargin < 4, mix = 0.5; end

x = x(:);
N = length(x);

% Crée une impulsion de réverbération exponentielle
impulse_len = round(decay * Fs);
impulse = exp(-linspace(0, 3, impulse_len));
impulse = impulse / sum(impulse); % Normalisation

% Convolution du signal avec l'impulsion
reverb = conv(x, impulse, 'same');

% Mixage du signal original et réverbéré
y = (1-mix)*x + mix*reverb;

% Normalisation
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end
