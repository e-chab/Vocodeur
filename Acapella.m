function y = acapella(x, Fs)
% Effet acapella : isole la voix en supprimant les sons non vocaux
% Implémenté avec un passe-bande : moins sélectif qu'une suppression spectrale, mais mieux pour garder la voix naturelle sans dégrader la qualité vocale
% x : signal d'entrée
% Fs : fréquence d'échantillonnage

% Convertir en mono si nécessaire
if size(x,2) > 1
    x = mean(x,2);
end

% Filtre passe-bande assez étroit (500 Hz à 1000 Hz)
[b_band, a_band] = butter(2, [500 1000]/(Fs/2), 'bandpass');
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
