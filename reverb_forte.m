function y = reverb_forte(x, Fs)
% REVERB_FORTE  Réverbération forte (grande salle / cathédrale)
%
%   y = reverb_forte(x, Fs)
%
%   x  : signal d'entrée (mono ou stéréo), de taille [N x 1] ou [N x 2]
%   Fs : fréquence d'échantillonnage en Hz
%
%   y  : signal de sortie avec réverbération "forte"
%
% Principe :
%   Implémente une réverbération "hard" avec plusieurs filtres à
%   rétroaction (feedback) successifs, mais cette fois avec :
%       - des délais plus longs (par ex. 50, 100, 150 ms),
%       - des gains plus élevés.
%
%   Formule sur chaque étage :
%
%       y = y + gain_coeff * filter(b, a, y)
%
%   avec :
%       b = [gain, 0, ..., 0, 1]
%       a = [1,    0, ..., 0, gain]
%
%   et :
%       Ndelay = delay * Fs
%
%   Le résultat est une traîne longue et dense qui enveloppe fortement
%   le signal original, simulant une très grande salle.
%
% ESIEE Paris - OBL-4101

    if nargin < 2
        error('reverb_forte : il faut au moins x et Fs en entrée.');
    end

    % Assurer un format [N x C]
    if isrow(x)
        x = x.';
    end

    [N, C] = size(x);

    % Copie de base du signal
    y = x;

    % --- Paramètres de la reverb "forte" ---
    % Délais plus grands (secondes)
    delays_s = [0.050, 0.100, 0.150];   % 50 ms, 100 ms, 150 ms
    % Gains plus élevés pour une traîne marquée
    gains    = [0.7,   0.65,  0.6];

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
