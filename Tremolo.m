function y = Tremolo(x, Fs, Fc, alpha, envelope_type)
% Effet Tremolo : modulation périodique du volume
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
% Fc : fréquence de modulation ie. fréquence de l'enveloppe (Hz)
% alpha : profondeur du tremolo (0 à 1)
% envelope_type : type d'enveloppe appliquée au volume
%   'sin'     : enveloppe sinusoïdale (par défaut)
%   'triangle': enveloppe triangulaire
%   'square'  : enveloppe carrée
%
% Le tremolo module le volume du signal selon une enveloppe choisie.
% - Sinusoïdale : modulation douce et régulière
% - Triangle    : modulation linéaire, effet plus mécanique
% - Carrée      : alternance brutale entre deux niveaux de volume
% Le paramètre alpha contrôle la profondeur de la modulation.
% Exemple : y = Tremolo(x, Fs, 5, 0.7, 'triangle')

%% Initialisation par défaut des paramètres
if nargin < 3
    Fc = 3;      % Fréquence de modulation par défaut
    alpha = 0.5; % Profondeur par défaut
end
if nargin < 5 || isempty(envelope_type)
    envelope_type = 'sin'; % Sinusoïdale par défaut
end


% Longueur du signal d'entrée :
N = length(x);
% Vecteur temps :
t = (0:N-1)/Fs;

% Calcul de l'enveloppe selon le type choisi
switch lower(envelope_type)
    case 'sin'
        env = (1 + alpha * sin(2*pi*Fc*t))';
    case 'triangle'
        env = (1 + alpha * sawtooth(2*pi*Fc*t, 0.5))'; % triangle
    case 'square'
        env = (1 + alpha * square(2*pi*Fc*t))';
    otherwise
        env = (1 + alpha * sin(2*pi*Fc*t))'; % défaut sinusoïdal
end

%% Multiplication point à point entre l'enveloppe et le signal d'entrée

y = env .* x;

% Normalisation du signal de sortie
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end
