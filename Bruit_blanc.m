function y = Bruit_blanc(x, RSB)
% Génère un bruit blanc gaussien pour un signal audio x
% avec un rapport signal à bruit (RSB) donné (en dB).
% Retourne le bruit blanc y (même taille que x)
%
% x : signal audio d entrée
% RSB : rapport signal à bruit en dB (ex : 20, 5, 0, -10)

if nargin < 2
    RSB = 10; % Valeur par défaut
end

x = x(:); % S assure que x est un vecteur colonne
N = length(x);

% Calcul de la puissance moyenne du signal
Rxx = xcorr(x, 'biased');
Ps = max(Rxx); % Puissance moyenne du signal

% Calcul de l écart type du bruit pour le RSB choisi
sigma = sqrt(Ps/(10^(RSB/10)));

% Génération du bruit blanc gaussien
noise = sigma * randn(N,1);

y = noise;
end
