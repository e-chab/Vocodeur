function generate_report_figures()
%GENERATE_REPORT_FIGURES Exporte les figures temps/spectre/spectrogramme du rapport.
%
% Le script suppose que les fichiers audio fournis (Extrait.wav, Halleluia.wav,
% Evil_laugh_elise.wav) sont présents dans le même dossier que ce script.
%
% Chaque figure comprend trois sous-graphiques :
%   1. Forme temporelle normalisée
%   2. Spectre en magnitude (FFT centrée)
%   3. Spectrogramme (fenêtre de 40 ms, recouvrement à 75 %)
%
% Les fichiers sont exportés au format PNG (300 dpi) dans le dossier "figures".

scriptDir = fileparts(mfilename('fullpath'));
addpath(scriptDir);
figDir = fullfile(scriptDir, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

% Chargement des clips (mono)
clip.extrait = loadMonoClip(scriptDir, 'Extrait.wav');
clip.halleluia = loadMonoClip(scriptDir, 'Halleluia.wav');
clip.voix = loadPreferredVoice(scriptDir);
targetVoiceFile = clip.voix.file;

%% Effet Speed
saveTriplePlot(applySpeed(clip.extrait, 0.6), clip.extrait.Fs, ...
    'Speed - Extrait (rapp=0.6)', fullfile(figDir, 'speed_extrait_rapp06.png'));
saveTriplePlot(applySpeed(clip.extrait, 1.5), clip.extrait.Fs, ...
    'Speed - Extrait (rapp=1.5)', fullfile(figDir, 'speed_extrait_rapp15.png'));
saveTriplePlot(applySpeed(clip.halleluia, 0.8), clip.halleluia.Fs, ...
    'Speed - Halleluia (rapp=0.8)', fullfile(figDir, 'speed_halleluia_rapp08.png'));
saveTriplePlot(applySpeed(clip.voix, 1.2), clip.voix.Fs, ...
    'Speed - Voix (rapp=1.2)', fullfile(figDir, 'speed_voix_rapp12.png'));

%% Effet Pitch
saveTriplePlot(applyPitch(clip.extrait, 3, 2), clip.extrait.Fs, ...
    'Pitch up - Extrait (3/2)', fullfile(figDir, 'pitch_extrait_up.png'));
saveTriplePlot(applyPitch(clip.extrait, 2, 3), clip.extrait.Fs, ...
    'Pitch down - Extrait (2/3)', fullfile(figDir, 'pitch_extrait_down.png'));
saveTriplePlot(applyPitch(clip.halleluia, 5, 4), clip.halleluia.Fs, ...
    'Pitch up +4 demi-tons', fullfile(figDir, 'pitch_halleluia_up4.png'));
saveTriplePlot(applyPitch(clip.voix, 6, 5), clip.voix.Fs, ...
    'Pitch up - Voix', fullfile(figDir, 'pitch_voix_up.png'));

%% Robotisation
saveTriplePlot(applyRobot(clip.extrait, 500), clip.extrait.Fs, ...
    'Robotisation Extrait fc=500 Hz', fullfile(figDir, 'robot_extrait_fc500.png'));
saveTriplePlot(applyRobot(clip.extrait, 1500), clip.extrait.Fs, ...
    'Robotisation Extrait fc=1500 Hz', fullfile(figDir, 'robot_extrait_fc1500.png'));
saveTriplePlot(applyRobot(clip.halleluia, 800), clip.halleluia.Fs, ...
    'Robotisation Halleluia fc=800 Hz', fullfile(figDir, 'robot_halleluia_fc800.png'));
saveTriplePlot(applyRobot(clip.voix, 800), clip.voix.Fs, ...
    'Robotisation Voix fc=800 Hz', fullfile(figDir, 'robot_voix_fc800.png'));

%% Effets supplémentaires (banque)
effectDefs = [
    struct('title','Auto-wah','file','effect_autowah.png','clip','voix', ...
        'fn',@(sig,Fs) Auto_wah(sig,Fs,300,2000,0.15));
    struct('title','Wah-Wah','file','effect_wahwah.png','clip','voix', ...
        'fn',@(sig,Fs) Wah_wah(sig,Fs,1500,1800,700));
    struct('title','Tremolo','file','effect_tremolo.png','clip','voix', ...
        'fn',@(sig,Fs) Tremolo(sig,Fs,4,0.8));
    struct('title','Vibrato','file','effect_vibrato.png','clip','voix', ...
        'fn',@(sig,Fs) Vibrato(sig,Fs,6,0.003));
    struct('title','Ring Mod','file','effect_ringmod.png','clip','voix', ...
        'fn',@(sig,Fs) RingMod(sig,Fs,150,0.85,0.8,0.3));
    struct('title','Transforme ma voix','file','effect_transforme_ma_voix.png','clip','extrait', ...
        'fn',@(sig,Fs) transforme_vers_ma_voie(sig,Fs,targetVoiceFile));
    struct('title','Acapella','file','effect_acapella.png','clip','halleluia', ...
        'fn',@(sig,Fs) Acapella(sig,Fs));
    struct('title','Autotune','file','effect_autotune.png','clip','halleluia', ...
        'fn',@(sig,Fs) Autotune(sig,Fs));
    struct('title','Bitcrusher','file','effect_bitcrusher.png','clip','voix', ...
        'fn',@(sig,Fs) Bitcrusher(sig,6,4));
    struct('title','Lo-fi','file','effect_lofi.png','clip','voix', ...
        'fn',@(sig,Fs) Lo_fi(sig,6));
    struct('title','Bruit blanc','file','effect_bruit_blanc.png','clip','voix', ...
        'fn',@(sig,Fs) Bruit_blanc(sig,8,0.7));
    struct('title','Chorus / Echo','file','effect_chorus_echo.png','clip','voix', ...
        'fn',@(sig,Fs) Chorus(sig,Fs,1,0.35,0.4));
    struct('title','Flanger','file','effect_flanger.png','clip','voix', ...
        'fn',@(sig,Fs) Flanger(sig,Fs));
    struct('title','Phaser','file','effect_phaser.png','clip','voix', ...
        'fn',@(sig,Fs) Phaser(sig,Fs,0.5,0.8));
    struct('title','Fuzz','file','effect_fuzz.png','clip','voix', ...
        'fn',@(sig,Fs) Fuzz(sig,10));
    struct('title','Hard Clip','file','effect_hardclip.png','clip','voix', ...
        'fn',@(sig,Fs) Distort_hard_clipping(sig,6,0.35));
    struct('title','Soft Clip','file','effect_softclip.png','clip','voix', ...
        'fn',@(sig,Fs) Distort_soft_clipping(sig,Fs));
    struct('title','Overdrive','file','effect_overdrive.png','clip','voix', ...
        'fn',@(sig,Fs) Overdrive(sig,Fs));
    struct('title','Granularize','file','effect_granularize.png','clip','voix', ...
        'fn',@(sig,Fs) Granularize(sig,Fs));
    struct('title','Reverb large','file','effect_reverb_large.png','clip','voix', ...
        'fn',@(sig,Fs) reverb(sig,Fs));
    struct('title','Reverb douce','file','effect_reverb_douce.png','clip','voix', ...
        'fn',@(sig,Fs) Reverb2(sig,Fs,0.7,0.5));
    struct('title','Stereo movement','file','effect_stereo_move.png','clip','voix', ...
        'fn',@(sig,Fs) Stereo_mov(sig,Fs));
];

for k = 1:numel(effectDefs)
    def = effectDefs(k);
    clipRef = clip.(def.clip);
    try
        processed = def.fn(clipRef.y, clipRef.Fs);
    catch ME
        warning('Impossible de générer %s : %s', def.title, ME.message);
        continue;
    end
    saveTriplePlot(processed, clipRef.Fs, ['Effet ' def.title], ...
        fullfile(figDir, def.file));
end

%% Harmonizer
harmo = applyHarmonizer(clip.voix, 3, 2);
saveTriplePlot(harmo, clip.voix.Fs, 'Harmonizer (quinte)', ...
    fullfile(figDir, 'harmonizer_voix_quinte.png'));

%% Voix "alien"
alien = applyAlien(clip.voix);
saveTriplePlot(alien, clip.voix.Fs, 'Voix "alien"', ...
    fullfile(figDir, 'alien_voix.png'));

fprintf('Figures exportées dans %s\n', figDir);
end

%% -------------------------------------------------------------------------
function result = applySpeed(clip, rapp)
y = PVoc(clip.y, rapp, 1024, 1024);
result = normalizeSignal(y);
end

function result = applyPitch(clip, a, b)
yvoc = PVoc(clip.y, a/b, 256, 256);
ypitch = localResample(yvoc, a, b);
result = normalizeSignal(ypitch);
end

function result = applyRobot(clip, fc)
result = normalizeSignal(Rob(clip.y, fc, clip.Fs));
end

function result = applyHarmonizer(clip, a, b)
yShift = applyPitch(clip, a, b);
sig = normalizeSignal(clip.y);
mix = sig(1:min(length(sig), length(yShift))) + ...
      yShift(1:min(length(sig), length(yShift)));
result = normalizeSignal(mix);
end

function result = applyAlien(clip)
pitched = applyPitch(clip, 2, 1);
result = applyRobot(struct('y', pitched, 'Fs', clip.Fs), 1200);
end

function saveTriplePlot(y, Fs, titleStr, outPath)
if isempty(y)
    warning('Signal vide pour %s', titleStr);
    return;
end
if size(y,1) == 1
    y = y.';
end
if size(y,2) > 1
    sig = mean(y,2);
else
    sig = y;
end
sig = sig(:);
t = (0:numel(sig)-1)/Fs;
Y = abs(fftshift(fft(sig)));
f = linspace(-Fs/2, Fs/2, numel(sig));
win = max(64, round(0.04 * Fs));
overlap = round(0.75 * win);
nfft = 2048;
fig = figure('Visible','off','Position',[100 100 900 900]);
subplot(3,1,1);
plot(t, sig);
xlabel('Temps (s)'); ylabel('Amplitude'); title([titleStr ' - temporel']); grid on;
subplot(3,1,2);
plot(f/1000, Y);
xlabel('Fréquence (kHz)'); ylabel('|X(f)|'); title('Spectre centré'); grid on;
subplot(3,1,3);
[S, fAxis, tAxis] = localSpectrogram(sig, Fs, win, overlap, nfft);
imagesc(tAxis, fAxis/1000, 20*log10(abs(S)+eps)); axis xy;
xlabel('Temps (s)'); ylabel('Fréquence (kHz)'); title('Spectrogramme');
colormap(parula); colorbar;
exportgraphics(fig, outPath, 'Resolution',300);
close(fig);
end

function clip = loadMonoClip(scriptDir, filename)
filePath = fullfile(scriptDir, filename);
if exist(filePath, 'file') ~= 2
    error('Fichier %s introuvable.', filename);
end
[y, Fs] = audioread(filePath);
if size(y,2) > 1
    y = mean(y,2);
end
clip.y = y;
clip.Fs = Fs;
clip.file = filePath;
end

function clip = loadPreferredVoice(scriptDir)
candidates = { 'Evil_laugh_elise.wav', 'Evil Laugh.wav', 'Extrait.wav' };
for k = 1:numel(candidates)
    filePath = fullfile(scriptDir, candidates{k});
    if exist(filePath,'file') == 2
        clip = loadMonoClip(scriptDir, candidates{k});
        return;
    end
end
error('Aucun fichier voix personnelle trouvé (Evil_laugh_elise.wav, Evil Laugh.wav, Extrait.wav).');
end

function y = normalizeSignal(x)
x = x(:);
peak = max(abs(x));
if peak > 0
    y = x / peak;
else
    y = x;
end
end

function yout = localResample(y, p, q)
% Copie adaptée de Vocodeur.m pour un rééchantillonnage rationnel léger.
y = y(:);
if isempty(y)
    yout = y;
    return;
end
if p <= 0 || q <= 0
    error('Facteurs de rééchantillonnage invalides.');
end
n = numel(y);
tOriginal = 0:(n-1);
nOut = max(1, floor((n-1)*p/q) + 1);
tTarget = (0:(nOut-1)) * q / p;
tTarget(end) = min(tTarget(end), tOriginal(end));
yout = interp1(tOriginal, y, tTarget, 'linear');
yout = yout(:);
end

function [S, fAxis, tAxis] = localSpectrogram(sig, Fs, win, overlap, nfft)
%LOCAL SPECTROGRAM Simple STFT implementation (no toolbox requirement).
sig = sig(:);
if nargin < 5 || isempty(nfft)
    nfft = max(256, 2^nextpow2(win));
end
hop = win - overlap;
if hop <= 0
    error('Le recouvrement doit être strictement inférieur à la taille de fenêtre.');
end
if numel(sig) < win
    sig = [sig; zeros(win - numel(sig), 1)];
end
frameStarts = 1:hop:(numel(sig) - win + 1);
if isempty(frameStarts)
    frameStarts = 1;
end
numFrames = numel(frameStarts);
halfIdx = floor(nfft/2) + 1;
S = zeros(halfIdx, numFrames);
tAxis = zeros(1, numFrames);
w = 0.5 - 0.5*cos(2*pi*(0:win-1)'/(win-1));
for idx = 1:numFrames
    startPos = frameStarts(idx);
    frame = sig(startPos:startPos + win - 1) .* w;
    fftFrame = fft(frame, nfft);
    S(:, idx) = fftFrame(1:halfIdx);
    tAxis(idx) = (startPos - 1 + win/2) / Fs;
end
fAxis = (0:halfIdx-1) * (Fs / nfft);
end
