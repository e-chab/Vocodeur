function y = Stereo_mov(x, Fs)
% Effet Stereo_mov (auto-panning) : crée un mouvement stéréo gauche-droite-gauche
% x : signal d'entrée (stéréo recommandé)
% Fs : fréquence d'échantillonnage
%
% Cet effet divise le signal en 4 parties et fait balayer le son entre les canaux gauche et droit.
% Sur un signal mono, il duplique le canal pour éviter les erreurs, mais l'effet n'a alors aucun intérêt perceptible.

%% Initialisation
[rows, columns] = size(x);
if columns == 1
    x = [x x]; % Convertit le signal mono en stéréo même si l'effet n'a alors aucun interret, nous avons placé cette mesure par précaution pour ne pas avoir d'erreur
    columns = 2;
end
y = zeros(length(x),2);

%% Choix aléatoire du sens de départ
s = rand;
if s >= 0.5
    weight = [0 1]; % Démarre à droite
else
    weight = [1 0]; % Démarre à gauche
end

%% Découpage en 4 parties égales
step = floor(rows / 4);

%% Traitement des 4 phases (aller-retour stéréo)
for i = 0:3
    w1 = weight(1); w2 = weight(2);
    coeff_left = linspace(w1, w2, step).';
    coeff_right = linspace(w2, w1, step).';
    rank_begin = 1 + i * step;
    rank_end = rank_begin + step - 1;
    % Applique le mouvement de panning
    y(rank_begin:rank_end,1) = x(rank_begin:rank_end,1) .* coeff_left;
    y(rank_begin:rank_end,2) = x(rank_begin:rank_end,2) .* coeff_right;
    % Inverse le sens pour l'aller-retour
    temp = weight(1);
    weight(1) = weight(2);
    weight(2) = temp;
end

% Résultat : le son se déplace automatiquement dans le champ stéréo
end
