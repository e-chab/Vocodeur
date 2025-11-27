function y = Buit_blanc(x, Fs, RSB)
% Effet Buit_blanc : génère un bruit blanc gaussien pour un signal audio x
% avec un rapport signal à bruit (RSB) donné (en dB).
% x : signal d'entrée
% Fs : fréquence d'échantillonnage (inutile ici, pour homogénéité)
% RSB : rapport signal à bruit en dB (ex : 20, 5, 0, -10)

if nargin < 3
    RSB = 10; % Valeur par défaut
end
x = x(:); % S'assure que x est un vecteur colonne
N = length(x);

% Calcul de la puissance moyenne du signal
Rxx = xcorr(x, 'biased');
Ps = max(Rxx); % Puissance moyenne du signal

% Calcul de l'écart type du bruit pour le RSB choisi
sigma = sqrt(Ps/(10^(RSB/10)));

% Génération du bruit blanc gaussien
noise = sigma * randn(N,1);

% Normalisation du bruit (optionnelle, pour cohérence avec les autres effets)
if max(abs(noise)) > 0
    y = noise / max(abs(noise));
else
    y = noise;
end
end
