function y = Acapella(x, Fs)
% ACAPELLA  Effet acapella simple sans toolbox (filtrage fréquentiel)
%   y = Acapella(x, Fs)
%   x  : signal d'entrée (mono ou stéréo)
%   Fs : fréquence d'échantillonnage
%
%   Principe :
%     - On passe en mono (si stéréo)
%     - On passe dans le domaine fréquentiel (FFT)
%     - On garde uniquement une bande [f1, f2] typique de la voix
%     - On remet à zéro le reste (musique, basses profondes, aigus)
%     - Seuil + normalisation

    if nargin < 2
        error('Acapella : il faut appeler la fonction avec (x, Fs).');
    end

    % 1) Mono
    if size(x,2) > 1
        x = mean(x, 2);
    end
    x = x(:);   % vecteur colonne

    N  = numel(x);
    Xf = fft(x);

    % 2) Définition de la bande vocale (à ajuster si tu veux)
    f1 = 300;      % Hz (grave)
    f2 = 3400;     % Hz (aigu)

    % Axe fréquentiel associé à la FFT "directe"
    freqs = (0:N-1) * (Fs / N);

    % 3) Masque passe-bande fréquentiel
    mask = zeros(size(Xf));

    % Bande "directe" (0 -> Fs/2)
    idxBandPos = (freqs >= f1) & (freqs <= f2);

    % Symétrique pour les composantes complexes conjuguées (partie haute)
    % Fréquences entre (Fs-f2) et (Fs-f1)
    idxBandNeg = (freqs >= (Fs - f2)) & (freqs <= (Fs - f1));

    mask(idxBandPos | idxBandNeg) = 1;

    % Application du masque fréquentiel
    Xf_filtered = Xf .* mask;

    % 4) Retour au temps
    y = real(ifft(Xf_filtered));

    % 5) Seuil pour virer les zones très faibles
    seuil = 0.02;
    y(abs(y) < seuil) = 0;

    % 6) Normalisation
    maxVal = max(abs(y));
    if maxVal > 0
        y = y ./ maxVal * 0.98;
    end
end
