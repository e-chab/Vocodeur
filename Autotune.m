function y = autotune(x, Fs)
% Effet autotune simple pour voix
% x : signal d entrée
% Fs : fréquence d échantillonnage

% Paramètres de l effet
window_size = round(0.02 * Fs); % 20 ms
hop_size = round(window_size / 2);

% Détection de la fréquence fondamentale (pitch tracking)
pitch = pitch_track(x, Fs, window_size, hop_size);

% Correction vers la note la plus proche (gamme chromatique)
notes = 440 * 2.^(([0:11]-9)/12); % La gamme chromatique autour de 440 Hz

% Initialisation du signal de sortie
y = zeros(size(x));

window = hann(window_size); % Fenêtre Hann pour lisser
crossfade = linspace(0,1,hop_size)'; % Fondu croissant
for i = 1:hop_size:length(x)-window_size
    segment = x(i:i+window_size-1);
    segment = segment .* window; % Appliquer la fenêtre Hann
    f0 = pitch(round(i/hop_size)+1);
    [~, idx] = min(abs(notes - f0));
    target_pitch = notes(idx);
    % Pitch shifting
    shifted = pitch_shift(segment, Fs, f0, target_pitch);
    shifted = shifted .* window; % Appliquer la fenêtre Hann après pitch shift
    % Overlap-add avec crossfade
    y(i:i+hop_size-1) = y(i:i+hop_size-1) .* (1-crossfade) + shifted(1:hop_size) .* crossfade;
    y(i+hop_size:i+window_size-1) = y(i+hop_size:i+window_size-1) + shifted(hop_size+1:end);
end

% Normalisation
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end

function pitch = pitch_track(x, Fs, window_size, hop_size)
% Détection simple de la fréquence fondamentale par autocorrélation
N = length(x);
pitch = zeros(1, ceil(N/hop_size));
for i = 1:hop_size:N-window_size
    segment = x(i:i+window_size-1);
    [acor, lag] = xcorr(segment);
    acor = acor(lag>=0);
    lag = lag(lag>=0);
    [~, idx] = max(acor(ceil(Fs/1000):end)); % Ignore lags < 1ms
    lag_val = lag(ceil(Fs/1000)-1+idx);
    pitch(round(i/hop_size)+1) = Fs/lag_val;
end
end

function y = pitch_shift(x, Fs, original_pitch, target_pitch)
% Pitch shifting par rééchantillonnage
ratio = target_pitch / original_pitch;
if isnan(ratio) || isinf(ratio) || ratio <= 0
    y = x;
    return;
end
N = length(x);
t = (0:N-1)/Fs;
new_t = t / ratio;
y = interp1(t, x, new_t, 'linear', 0);
if length(y) < N
    y = [y; zeros(N-length(y),1)];
else
    y = y(1:N);
end
y = y(:);
end
