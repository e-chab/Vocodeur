function y = Vibrato(x, Fs, Modfreq, Tdelay)
% Effet vibrato : modulation périodique de la hauteur
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
% Modfreq : fréquence de modulation (Hz)
% Tdelay : profondeur du vibrato (en secondes)

if nargin < 3, Modfreq = 5; end % Fréquence de modulation par défaut (Hz)
if nargin < 4, Tdelay = 0.003; end % Profondeur par défaut (3 ms)

x = x(:); % S'assure que le signal est en colonne
N = length(x); % Nombre d'échantillons
t = (0:N-1)'/Fs; % Vecteur temps

% Génère le LFO sinusoïdal pour moduler le délai
% delay : valeur du délai en secondes pour chaque échantillon
% n_delay : valeur du délai en nombre d'échantillons

delay = Tdelay * sin(2*pi*Modfreq*t); % LFO sinus
n_delay = round(delay * Fs); % Décalage en échantillons

y = zeros(size(x)); % Initialisation du signal de sortie
for n = 1:N
    idx = n - n_delay(n); % Calcul de l'indice décalé
    if idx < 1
        idx = 1; % Bord inférieur
    elseif idx > N
        idx = N; % Bord supérieur
    end
    y(n) = x(idx); % Affecte la valeur décalée
end

% Normalisation du signal de sortie
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end