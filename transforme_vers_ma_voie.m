function y = transforme_vers_ma_voie(x, Fs, cible_file)
% Transforme une voix source pour se rapprocher d'une voix cible
% x : voix source
% Fs : fréquence d'échantillonnage
% cible_file : chemin vers la voix cible (optionnel)

if nargin < 3 || isempty(cible_file)
    localDir = fileparts(mfilename('fullpath'));
    candidates = { ...
        fullfile(localDir, 'Evil_laugh_elise.wav'), ...
        fullfile(localDir, 'Evil Laugh.wav')};
    cible_file = '';
    for k = 1:numel(candidates)
        if exist(candidates{k},'file') == 2
            cible_file = candidates{k};
            break;
        end
    end
    if isempty(cible_file)
        error('Aucun fichier cible trouve pour l''effet transforme_vers_ma_voie.');
    end
end

[cible, FsCible] = audioread(cible_file);
cible = localEnsureMono(cible);
x = localEnsureMono(x);

if FsCible ~= Fs
    cible = localResampleMatch(cible, FsCible, Fs);
end

pitchCible = estimate_pitch(cible, Fs);
pitchSource = estimate_pitch(x, Fs);

facteur = pitchCible / max(pitchSource, eps);
if ~isfinite(facteur) || facteur <= 0
    facteur = 1;
end

Nfft = 1024;
x_shifted = PVoc(x, facteur, Nfft, Nfft);
x_shifted = localMatchLength(x_shifted, numel(x));

formants = localEstimateFormants(cible, Fs, 3);
if isempty(formants)
    formants = [500 1500 2500];
end

y = x_shifted;
for f0 = formants
    bw = max(120, 0.25 * f0);
    fLow = max(80, f0 - bw/2);
    fHigh = min(Fs/2 - 100, f0 + bw/2);
    if fHigh <= fLow
        continue;
    end
    [b, a] = localBandpassRBJ(fLow, fHigh, Fs);
    y = filter(b, a, y);
end

if max(abs(y)) > 0
    y = y / max(abs(y));
end
end

function f0 = estimate_pitch(sig, Fs)
sig = sig(:) - mean(sig);
if all(sig == 0)
    f0 = 120;
    return;
end
[R, lags] = xcorr(sig, 'coeff');
mask = lags >= 0;
R = R(mask);
lags = lags(mask);
minLag = max(1, round(Fs/500));
maxLag = min(numel(lags), round(Fs/50));
if maxLag <= minLag
    f0 = 120;
    return;
end
segment = R(minLag:maxLag);
[~, idx] = max(segment);
lagVal = minLag + idx - 1;
f0 = Fs / lagVal;
if isnan(f0) || isinf(f0) || f0 < 50 || f0 > 500
    f0 = 120;
end
end

function sig = localEnsureMono(sig)
if isempty(sig)
    sig = zeros(0,1);
    return;
end
if size(sig,2) > 1
    sig = mean(sig,2);
end
sig = sig(:);
end

function y = localResampleMatch(sig, FsIn, FsOut)
if isempty(sig)
    y = sig;
    return;
end
duration = (numel(sig)-1)/FsIn;
if duration <= 0
    y = sig;
    return;
end
tOriginal = linspace(0, duration, numel(sig));
targetSamples = max(2, round(duration * FsOut) + 1);
tTarget = linspace(0, duration, targetSamples);
y = interp1(tOriginal, sig, tTarget, 'linear');
y = y(:);
end

function out = localMatchLength(sig, targetLen)
if isempty(sig)
    out = sig;
    return;
end
currentLen = numel(sig);
if currentLen == targetLen
    out = sig(:);
    return;
end
tOriginal = linspace(0, 1, currentLen);
tTarget = linspace(0, 1, targetLen);
out = interp1(tOriginal, sig(:).', tTarget, 'linear');
out = out(:);
end

function formants = localEstimateFormants(sig, Fs, nFormants)
sig = sig(:);
if isempty(sig)
    formants = [];
    return;
end
sig = sig - mean(sig);
N = length(sig);
Nfft = 2^nextpow2(min(max(2048, N), 16384));
win = 0.5 - 0.5*cos(2*pi*(0:N-1)/(max(N-1,1)));
segment = sig(1:min(N, Nfft));
if numel(segment) < numel(win)
    win = win(1:numel(segment));
end
segment = segment(:) .* win(:);
padded = zeros(Nfft,1);
padded(1:numel(segment)) = segment;
spec = abs(fft(padded)).^2;
freqAxis = (0:Nfft-1)*(Fs/Nfft);
mask = freqAxis >= 150 & freqAxis <= min(4000, Fs/2 - 50);
freqAxis = freqAxis(mask);
mag = spec(mask);
if isempty(mag)
    formants = [];
    return;
end
smoothed = localMovingAverage(mag, 9);
working = smoothed;
formants = zeros(1, nFormants);
binWidth = Fs / Nfft;
for k = 1:nFormants
    [peakVal, idx] = max(working);
    if peakVal <= 0
        formants = formants(1:k-1);
        break;
    end
    formants(k) = freqAxis(idx);
    guard = round(150 / binWidth);
    idxStart = max(1, idx - guard);
    idxEnd = min(numel(working), idx + guard);
    working(idxStart:idxEnd) = 0;
end
formants = formants(formants > 0);
end

function y = localMovingAverage(x, win)
win = max(1, round(win));
kernel = ones(win,1)/win;
y = conv(x, kernel, 'same');
end

function [b, a] = localBandpassRBJ(fLow, fHigh, Fs)
center = sqrt(fLow * fHigh);
bandwidth = max(fHigh - fLow, 10);
Q = center / bandwidth;
if Q <= 0
    Q = 0.5;
end
w0 = 2*pi*center/Fs;
alpha = sin(w0)/(2*Q);
b0 = alpha;
b1 = 0;
b2 = -alpha;
a0 = 1 + alpha;
a1 = -2*cos(w0);
a2 = 1 - alpha;
b = [b0/a0, b1/a0, b2/a0];
a = [1, a1/a0, a2/a0];
end
