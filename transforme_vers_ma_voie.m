function y = transforme_vers_ma_voie(x, Fs, cible_file)
% y = transforme_vers_ma_voie(x, Fs, cible_file)
% Transforme la voix d'entrée x pour qu'elle ressemble à la voix cible (ex: Evil_laugh_elise.wav)
% x : signal à transformer
% Fs : fréquence d'échantillonnage
% cible_file : nom du fichier audio de la voix cible
%
% Etapes :
% 1. Analyse de la voix cible (hauteur, formants)
% 2. Pitch shifting et filtrage des formants sur x

% Lecture de la voix cible
[cible, Fs2] = audioread(cible_file);
if Fs2 ~= Fs
    cible = resample(cible, Fs, Fs2);
end
cible = cible(:,1); % Mono
x = x(:,1); % Mono

% 1. Estimation de la hauteur fondamentale (pitch) par autocorrélation
pitch_cible = estimate_pitch(cible, Fs);
pitch_source = estimate_pitch(x, Fs);

% 2. Calcul du facteur de transposition
facteur = pitch_cible / pitch_source;

% 3. Pitch shifting
Nfft = 1024;
Nwind = 1024;
x_shifted = PVoc(x, facteur, Nfft, Nwind);
if length(x_shifted) ~= length(x)
    % Interpolation linéaire pour ajuster la durée
    x_shifted = interp1(linspace(0,1,length(x_shifted)), x_shifted, linspace(0,1,length(x)), 'linear');
end

% 4. Estimation des formants principaux de la voix cible
[S,F] = periodogram(cible,[],[],Fs);
[~,formant_idx] = findpeaks(S,'NPeaks',3,'SortStr','descend');
formant_freqs = F(formant_idx);
if length(formant_freqs) < 3
    formant_freqs = [500 1500 2500]; % Valeurs par défaut si estimation échoue
end

% 5. Filtrage passe-bande autour des formants principaux
bpFilt = designfilt('bandpassiir','FilterOrder',6, ...
    'HalfPowerFrequency1',max(50,formant_freqs(1)-100), ...
    'HalfPowerFrequency2',min(Fs/2-1,formant_freqs(end)+100), ...
    'SampleRate',Fs);

y = filter(bpFilt, x_shifted);

% 6. Normalisation
y = y / max(abs(y));
end

function f0 = estimate_pitch(sig, Fs)
% Estimation simple de la fréquence fondamentale par autocorrélation
sig = sig - mean(sig);
[R, lags] = xcorr(sig, 'coeff');
R = R(lags >= 0);
lags = lags(lags >= 0);
[min_lag, max_lag] = deal(round(Fs/500), round(Fs/50)); % Plage typique voix humaine (50-500 Hz)
search_range = R(min_lag:max_lag);
[~, idx] = max(search_range);
f0 = Fs / (min_lag + idx - 1);
if isnan(f0) || isinf(f0) || f0 < 50 || f0 > 500
    f0 = 120; % Valeur par défaut raisonnable
end
end
