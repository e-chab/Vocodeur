function y = Flanger(x, Fs)
% Effet Flanger : mélange le signal original avec une copie retardée modulée
% x : signal d'entrée
% Fs : fréquence d'échantillonnage
%
% Le flanger crée un effet de balayage et d'ondulation typique des sons "space" ou "jet d'avion".
% Il utilise un délai court (quelques ms) modulé par un LFO sinusoïdal.

%% Paramètres
max_time_delay = 0.003; % Délai maximal (secondes)
rate = 1;               % Fréquence de modulation du délai (Hz)
coeff = 0.7;            % Coefficient d'amplitude du mélange

%% LFO (Low Frequency Oscillator) pour moduler le délai
index = 1:length(x);
lfo = sin(2 * pi * index * (rate/Fs))'; % LFO sinusoïdal

%% Initialisations
max_samp_delay = round(max_time_delay * Fs); % Délai maximal en échantillons
y = zeros(length(x),1); % Signal de sortie

%% Calcul de l'effet flanger
for i = (max_samp_delay+1):length(x)
    abs_lfo = abs(lfo(i)); % Valeur du LFO (0 à 1)
    Idelay = ceil(abs_lfo * max_samp_delay); % Délai modulé
    % Mélange du signal original et du signal retardé
    y(i) = (coeff * x(i)) + coeff * (x(i - Idelay));
end

% Résultat : le son "ondule" et "balaye" grâce au délai modulé
end
