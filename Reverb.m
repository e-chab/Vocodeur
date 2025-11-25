function y = reverb(x, Fs)
% Effet Reverb : ajoute une réverbération synthétique par filtres à rétroaction
% x : signal d'entrée à réverbérer
% Fs : fréquence d'échantillonnage

% Paramètres de la réverbération
% gain : contrôle la force de la réverbération
% delay : temps de retard entre les échos (en secondes)
gain = 0.9;
delay = 0.02;

% Conversion du délai en nombre d'échantillons
Ndelay = delay * Fs;

% Initialisation du signal de sortie
y = x;

% La réverbération est simulée par 3 filtres à rétroaction successifs
% Chaque filtre ajoute un écho avec un gain décroissant et un délai différent
for i = 1:3
    % Création des coefficients du filtre pour chaque itération
    % b : coefficients du signal d'entrée (feedforward)
    % a : coefficients du signal de sortie (feedback)
    b = [gain, zeros(1, round(Ndelay/i)), 1];
    a = [1, zeros(1, round(Ndelay/i)), gain];
    % gain_coeff : atténuation supplémentaire pour chaque écho
    gain_coeff = gain / (4 - i);
    % Application du filtre et addition au signal de sortie
    y = y + filter(b, a, y) * gain_coeff;
end

% Le résultat est un signal enrichi par plusieurs échos, typique d'une réverb numérique simple
end
