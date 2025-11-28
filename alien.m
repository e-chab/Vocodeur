function y = Alien(x, Fs)
%ALIEN  Effet "Alien" : voix / son extraterrestre.
%
%   y = Alien(x, Fs)
%   x  : signal d'entrée (mono ou stéréo)
%   Fs : fréquence d'échantillonnage
%
%   Chaîne de traitement :
%     1) Pitch up (plus aigu) avec PVoc
%     2) Robotisation (Rob)
%     3) Vibrato léger
%     4) Tremolo subtil
%     5) Normalisation

    % --- Sécurité arguments ---
    if nargin < 2 || isempty(x)
        y = x;
        return;
    end

    % --- Mono obligatoire pour simplifier ---
    if size(x,2) > 1
        x = mean(x,2);
    end
    x = x(:);   % vecteur colonne

    fprintf('ALIEN: start, len=%d, min=%.3f, max=%.3f\n', ...
        numel(x), min(x), max(x));

    %% 1) Pitch up via PVoc (si dispo)
    pitchFactor = 1.5;   % >1 => plus aigu

    try
        % Même style que dans l'appli (Nfft = 1024, Nwind = 1024)
        y = PVoc(x, pitchFactor, 1024, 1024);
        fprintf('ALIEN: PVoc OK, len=%d\n', numel(y));
    catch ME
        warning('ALIEN: PVoc a plante (%s), fallback simple resampling.', ME.message);
        idx = 1/pitchFactor : 1/pitchFactor : numel(x);
        if idx(end) > numel(x)
            idx(end) = numel(x);
        end
        y = interp1(1:numel(x), x, idx, 'linear')';
        fprintf('ALIEN: fallback resampling, len=%d\n', numel(y));
    end

    %% 2) Robotisation (timbre métallique)
    carrierFreq = 650;  % Hz (un peu plus haut que Robotize classique)
    try
        y = Rob(y, carrierFreq, Fs);
        fprintf('ALIEN: Rob OK, len=%d\n', numel(y));
    catch ME
        warning('ALIEN: Rob a plante (%s), on saute cette etape.', ME.message);
    end

    %% 3) Vibrato léger
    vibRate  = 6;      % Hz
    vibDepth = 0.004;  % petite variation de pitch
    try
        y = Vibrato(y, Fs, vibRate, vibDepth);
        fprintf('ALIEN: Vibrato OK\n');
    catch ME
        warning('ALIEN: Vibrato a plante (%s), on saute cette etape.', ME.message);
    end

    %% 4) Tremolo subtil (modulation d’amplitude)
    tremRate  = 5;    % Hz
    tremDepth = 0.6;
    try
        y = Tremolo(y, Fs, tremRate, tremDepth);
        fprintf('ALIEN: Tremolo OK\n');
    catch ME
        warning('ALIEN: Tremolo a plante (%s), on saute cette etape.', ME.message);
    end

    %% 5) Normalisation
    maxVal = max(abs(y));
    if maxVal > 0
        y = 0.98 * (y ./ maxVal);
    end

    fprintf('ALIEN: end, len=%d, min=%.3f, max=%.3f\n', ...
        numel(y), min(y), max(y));
end

[x,Fs] = audioread('Extrait.wav');   % ou un autre fichier qui est dans ton dossier
yAlien = Alien(x, Fs);

