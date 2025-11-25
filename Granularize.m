function y = Granularize(x, Fs)
% Effet Granularize : applique une synthèse granulaire au signal audio
% x : signal d'entrée à granulariser (mono ou stéréo)
% Fs : fréquence d'échantillonnage
%
% Le signal est découpé en grains de longueur aléatoire, fenêtrés et modulés en amplitude.
% Les grains sont superposés pour créer des textures glitchées ou étirées.

%% Paramètres
grainNumber = 800;      % Nombre de grains
TgrainMax = 2;          % Durée max d'un grain (s)
grainMax = Fs * TgrainMax;
TgrainMin = 1;          % Durée min d'un grain (s)
grainMin = Fs * TgrainMin;
grainLength = grainMin + round((grainMax-grainMin) * rand(1,grainNumber)); % Longueur aléatoire

%% Initialisation
N = size(x,1);
if size(x,2) == 1
    x = [x x]; % Convertit le signal mono en stéréo
end
y = zeros(N,2); % Signal de sortie (stéréo)

%% Ordonnancement des grains
sequence = round(linspace(1, N, grainNumber)); % Position de départ de chaque grain
ampEnv = rand(grainNumber,1);                  % Amplitude aléatoire pour chaque grain
startIndex = linspace(1, N - grainMax, grainNumber);
endIndex = startIndex + grainLength - 1;

%% Calcul de la granulation pour chaque canal
for c = 1:2 % Pour chaque canal stéréo
    for n = 1:grainNumber
        % Cas limite : grain déborde la fin du signal
        if (sequence(n)+grainLength(n)-1) > (N-1)
            y_sample = x(sequence(n):N,c);
            slope = 2.5;
            win_y = window(@kaiser,grainLength(n),slope);
            grain = y_sample .* win_y(1:1+(N-sequence(n)));
            index_start = floor(startIndex(n));
            index_end = index_start+(N-sequence(n));
            y(index_start:index_end,c) = y(index_start:index_end,c) + ampEnv(n) * grain;
            break;
        else
            y_sample = x(sequence(n):(sequence(n)+grainLength(n)-1),c);
        end
        slope = 2.5; % Paramètre de la fenêtre Kaiser
        win_y = kaiser(grainLength(n),slope); % Fenêtrage du grain
        grain = y_sample .* win_y;
        grainMod = grain * ampEnv(n); % Modulation d'amplitude
        index_start = floor(startIndex(n));
        index_end = floor(endIndex(n));
        y(index_start:index_end,c) = y(index_start:index_end,c) + grainMod;
    end
end

% Résultat : le signal est transformé en une texture granulaire stéréo
end