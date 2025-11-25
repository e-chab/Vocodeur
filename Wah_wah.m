function y = Wah_wah(x, Fs, speed, center_Freq, delta)
% Effet wah-wah classique
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
% speed : vitesse du wah (Hz/s)
% center_Freq : fréquence centrale (Hz)
% delta : largeur du balayage (Hz)

if nargin < 3, speed = 2000; end % Vitesse par défaut
if nargin < 4, center_Freq = 1800; end % Fréquence centrale par défaut
if nargin < 5, delta = 875; end % Largeur par défaut

Nspeed = speed / Fs; % Conversion de la vitesse en échantillons
m = 0.05;            % Amortissement du filtre
minFreq = center_Freq - delta; % Fréquence minimale du balayage
maxFreq = center_Freq + delta; % Fréquence maximale du balayage

% Génère le vecteur des fréquences centrales du filtre
Fc = minFreq : Nspeed : maxFreq;
while(length(Fc) < length(x))
    Fc = [Fc (maxFreq:-Nspeed:minFreq)]; % Balayage descendant
    Fc = [Fc (minFreq:Nspeed:maxFreq)];  % Balayage montant
end
Fc = Fc(1:length(x)); % Ajuste la taille à celle du signal

f = 2 * sin((pi * Fc(1))/Fs); % Fréquence caractéristique initiale
Q = 2 * m;                    % Largeur du passe-bande

% Initialisation des sorties des filtres
% Passe-haut
 yh = zeros(size(x)); yh(1) = x(1);
% Passe-bande
 yb = zeros(size(x)); yb(1) = f * yh(1);
% Passe-bas
 yl = zeros(size(x)); yl(1) = f * yb(1);

% Application du filtre variable à chaque échantillon
for n = 2:length(x)
    % Filtre passe-haut
    yh(n) = x(n) - yl(n-1) - Q * yb(n-1);
    % Filtre passe-bande
    yb(n) = f * yh(n) + yb(n-1);
    % Filtre passe-bas
    yl(n) = f * yb(n) + yl(n-1);
    % Mise à jour de la fréquence caractéristique
    f = 2 * sin((pi*Fc(n))/Fs);
end

% Normalisation du signal de sortie
if max(abs(yb)) > 0
    y = yb / max(abs(yb));
else
    y = yb;
end
end
