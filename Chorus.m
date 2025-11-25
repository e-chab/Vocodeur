function y = Chorus(x, Fs, n_copies, delay_s, intensity)
% Fonction permettant d'obtenir un effet chorus ou echo généralisé,
% en ajoutant un certain nombre de copies du signal original, chacune
% décalée d'un délai souhaité et pondérée par une intensité donnée.
% 
% x : signal d'entrée (mono ou stéréo)
% Fs : fréquence d'échantillonnage du signal d'entrée (en Hertz)
% n_copies : nombre de copies à ajouter (défaut : 1)
% delay_s : délai entre chaque copie (en secondes, défaut : 0.5)
% intensity : intensité de chaque copie (défaut : 0.4)
%
% Si n_copies = 1, delay_s = 0.5 et intensity = 0.4, le comportement est celui d'un echo classique.

y = x;
%% Initialisation des paramètres par défaut (une echo classsique)
if nargin < 3
    n_copies = 1; % Par défaut, une seule copie 
end
if nargin < 4
    delay_s = 0.5; % Par défaut, délai de 0.5s
end
if nargin < 5
    intensity = 0.4; % Par défaut, intensité de 0.4
end

%% Conversion mono -> stéréo si besoin
if size(x,2) == 1
    x = [x x]; % Convertit le signal mono en stéréo
end
N = size(x,1); % Nombre d'échantillons
delay_samples = round(delay_s * Fs); % Délai en nombre d'échantillons

%% Initialisation du signal de sortie
y = x; % On part du signal original

%% Ajout des copies retardées et pondérées
for k = 1:n_copies
    shift = k * delay_samples; % Décalage pour la k-ième copie
    for ch = 1:2 % Traitement des deux voies stéréo
        % Ajoute la copie retardée et pondérée à la sortie
        y((shift+1):end,ch) = y((shift+1):end,ch) + intensity * x(1:(end-shift),ch);
    end
end

%% Normalisation du signal de sortie
maxval = max(abs(y(:)));
if maxval > 0
    y = y / maxval;
end
end
