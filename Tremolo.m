function y = Tremolo(x, Fs, Fc, alpha)
% Effet Tremolo : modulation périodique du volume
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
% Fc : fréquence de modulation ie. fréquence de l'enveloppe (Hz)
% alpha : profondeur du tremolo (0 à 1) 

%% Initialisation par défaut des paramètres
if nargin < 3
    Fc = 3;      % Fréquence de modulation par défaut
    alpha = 0.5; % Profondeur par défaut
end

%% Calcul de l'enveloppe sinusoïdale
% Longueur du signal d'entrée :
N = length(x);
% Vecteur temps :
t = (0:N-1)/Fs;
% Calcul de l'enveloppe :
env = (1 + alpha * sin(2*pi*Fc*t))'; 

%% Multiplication point à point entre l'enveloppe et le signal d'entrée
y = env .* x;

% Normalisation du signal de sortie
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end
