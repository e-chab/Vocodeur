function y = reverb_douce(x, Fs)
% REVERB_DOUCE  Réverbération douce (salle moyenne, traîne modérée)
%
%   y = reverb_douce(x, Fs)
%
%   x  : signal d'entrée (mono ou stéréo), de taille [N x 1] ou [N x 2]
%   Fs : fréquence d'échantillonnage en Hz
%
%   y  : signal de sortie avec réverbération "douce"
%
% Principe :
%   Implémente une réverbération en empilant plusieurs filtres à
%   rétroaction (feedback) successifs. Chaque filtre génère un écho
%   avec un gain décroissant et un délai différent :
%
%       y = y + gain_coeff * filter(b, a, y)
%
%   où b et a sont calculés à partir du gain et du délai :
%       b = [gain, 0, ..., 0, 1]
%       a = [1,    0, ..., 0, gain]
%
%   Le délai en nombre d'échantillons est :
%       Ndelay = delay * Fs
%
%   Cette version "douce" utilise des délais relativement courts et des
%   gains modérés, ce qui donne une traîne présente mais pas écrasante.
%
% ESIEE Paris - OBL-4101

    if nargin < 2
        error('reverb_douce : il faut au moins x et Fs en entrée.');
    end

    % Assurer un format [N x C]
    if isrow(x)
        x = x.';
    end

    [N, C] = size(x);

    % Copie de base du signal
    y = x;

    % --- Paramètres de la reverb "douce" ---
    % Délais (en secondes)
    delays_s = [0.020, 0.037, 0.058];   % 20 ms, 37 ms, 58 ms
    % Gains associés (feedback)
    gains    = [0.6,   0.5,   0.4];

    % Boucle sur chaque filtre de réverbération
    for k = 1:length(delays_s)
        delay_s = delays_s(k);
        gain    = gains(k);

        % Délai en nombre d'échantillons
        Ndelay = round(delay_s * Fs);

        % Coefficients du filtre :
        % b = [gain, 0, ..., 0, 1]
        % a = [1,    0, ..., 0, gain]
        b = zeros(1, Ndelay + 1);
        a = zeros(1, Ndelay + 1);

        b(1)      = gain;
        b(end)    = 1;
        a(1)      = 1;
        a(end)    = gain;

        % Application du filtre à rétroaction sur chaque canal
        for c = 1:C
            yc = y(:, c);
            % y <- y + gain_coeff * filter(b, a, y)
            y(:, c) = yc + gain * filter(b, a, yc);
        end
    end

    % Normalisation pour éviter l'écrêtage
    maxval = max(abs(y(:)));
    if maxval > 0
        y = y / maxval * 0.99; % petite marge de sécurité
    end
end
