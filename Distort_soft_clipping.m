function y = Distort_soft(x, Fs)
% Effet Distort_soft : distorsion douce (soft clipping) par fonction non linéaire
% x : signal d'entrée à distordre
% Fs : fréquence d'échantillonnage
%
% La distorsion douce simule le comportement d'un ampli analogique ou à lampes.
% Elle ajoute des harmoniques tout en gardant un son musical et arrondi.

%% Paramètre de distorsion
gain = 15; % Taux de distorsion (plus grand = plus saturé)

%% Application de la fonction non linéaire (soft clipping)
r = sign(x); % r = +1 ou -1 selon le signe de x
% La fonction 1-exp(-r*x*gain) crée une saturation progressive
% pour les valeurs élevées de x, le signal est compressé
% pour les petites valeurs, le signal reste linéaire
y = r .* (1 - exp(-r .* x * gain));

%% Normalisation du signal de sortie
if max(abs(y(:))) > 0
    y = y / max(abs(y(:)));
end
end
