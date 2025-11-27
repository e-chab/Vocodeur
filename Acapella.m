function y = Acapella(x, Fs)
% Effet acapella : isole la voix en supprimant les sons non vocaux
% Implémenté avec un passe-bande : moins sélectif qu'une suppression spectrale, mais mieux pour garder la voix naturelle sans dégrader la qualité vocale
% x : signal d'entrée
% Fs : fréquence d'échantillonnage

% Convertir en mono si nécessaire
if size(x,2) > 1
    x = mean(x,2);
end

% Filtre passe-bande assez étroit (500 Hz à 1000 Hz)
[b_band, a_band] = localBandpass(500, 1000, Fs);
x_band = filter(b_band, a_band, x);

% Suppression des parties faibles avec seuil absolu (absolu pour que si l'audio n'a pas de voix, tout soit mis à zéro)
seuil = 0.02; % seuil absolu
y = x_band;
y(abs(y) < seuil) = 0;

% Normalisation
if max(abs(y)) > 0
    y = y / max(abs(y));
end

end

function [b, a] = localBandpass(fLow, fHigh, Fs)
% Second-order band-pass using RBJ audio EQ cookbook equations
center = sqrt(fLow * fHigh);
bandwidth = max(fHigh - fLow, eps);
Q = center / bandwidth;
if Q <= 0
    Q = 0.5;
end
w0 = 2*pi*center/Fs;
alpha = sin(w0)/(2*Q);

b0 = alpha;
b1 = 0;
b2 = -alpha;
a0 = 1 + alpha;
a1 = -2*cos(w0);
a2 = 1 - alpha;

b = [b0/a0, b1/a0, b2/a0];
a = [1, a1/a0, a2/a0];
end
