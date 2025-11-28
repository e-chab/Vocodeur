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
clip.pop = tryLoadMonoClip(scriptDir, 'extrait_pop_melodie.wav', clip.extrait);
clip.beat = tryLoadMonoClip(scriptDir, 'extrait_beat_electro.wav', clip.extrait);
clip.basse = tryLoadMonoClip(scriptDir, 'extrait_basse_groove.wav', clip.extrait);
clip.jazz = tryLoadMonoClip(scriptDir, 'extrait_jazz_bass.wav', clip.extrait);
clip.classique = tryLoadMonoClip(scriptDir, 'extrait_classique_arpege.wav', clip.extrait);
clip.lofi = tryLoadMonoClip(scriptDir, 'extrait_lofi_loop.wav', clip.extrait);

%% Effet Speed
saveTriplePlot(applySpeed(clip.extrait, 0.6), clip.extrait.Fs, ...
    'Speed - Extrait (rapp=0.6)', fullfile(figDir, 'speed_extrait_rapp06.png'), clip.extrait.y);
saveTriplePlot(applySpeed(clip.extrait, 1.5), clip.extrait.Fs, ...
    'Speed - Extrait (rapp=1.5)', fullfile(figDir, 'speed_extrait_rapp15.png'), clip.extrait.y);
saveTriplePlot(applySpeed(clip.halleluia, 0.8), clip.halleluia.Fs, ...
    'Speed - Halleluia (rapp=0.8)', fullfile(figDir, 'speed_halleluia_rapp08.png'), clip.halleluia.y);
saveTriplePlot(applySpeed(clip.voix, 1.2), clip.voix.Fs, ...
    'Speed - Voix (rapp=1.2)', fullfile(figDir, 'speed_voix_rapp12.png'), clip.voix.y);

%% Effet Pitch
saveTriplePlot(applyPitch(clip.extrait, 3, 2), clip.extrait.Fs, ...
    'Pitch up - Extrait (3/2)', fullfile(figDir, 'pitch_extrait_up.png'), clip.extrait.y);
saveTriplePlot(applyPitch(clip.extrait, 2, 3), clip.extrait.Fs, ...
    'Pitch down - Extrait (2/3)', fullfile(figDir, 'pitch_extrait_down.png'), clip.extrait.y);
saveTriplePlot(applyPitch(clip.halleluia, 5, 4), clip.halleluia.Fs, ...
    'Pitch up +4 demi-tons', fullfile(figDir, 'pitch_halleluia_up4.png'), clip.halleluia.y);
saveTriplePlot(applyPitch(clip.voix, 6, 5), clip.voix.Fs, ...
    'Pitch up - Voix', fullfile(figDir, 'pitch_voix_up.png'), clip.voix.y);
savePitchFlowchart(fullfile(figDir, 'pitch_flowchart.png'));
savePitchOverlayTime(clip.extrait, fullfile(figDir, 'pitch_overlay_time.png'));
savePitchOverlayFreq(clip.extrait, fullfile(figDir, 'pitch_overlay_freq.png'));

%% Robotisation
saveTriplePlot(applyRobot(clip.extrait, 500), clip.extrait.Fs, ...
    'Robotisation Extrait fc=500 Hz', fullfile(figDir, 'robot_extrait_fc500.png'), clip.extrait.y);
saveTriplePlot(applyRobot(clip.extrait, 1500), clip.extrait.Fs, ...
    'Robotisation Extrait fc=1500 Hz', fullfile(figDir, 'robot_extrait_fc1500.png'), clip.extrait.y);
saveTriplePlot(applyRobot(clip.halleluia, 800), clip.halleluia.Fs, ...
    'Robotisation Halleluia fc=800 Hz', fullfile(figDir, 'robot_halleluia_fc800.png'), clip.halleluia.y);
saveTriplePlot(applyRobot(clip.voix, 800), clip.voix.Fs, ...
    'Robotisation Voix fc=800 Hz', fullfile(figDir, 'robot_voix_fc800.png'), clip.voix.y);

%% Chorus / Echo (deux scénarios)
chorusEcho = Chorus(clip.extrait.y, clip.extrait.Fs, 1, 0.42, 0.5);
saveTriplePlot(chorusEcho, clip.extrait.Fs, 'Chorus écho - Extrait.wav', ...
    fullfile(figDir, 'effect_chorus_echo.png'), clip.extrait.y);

chorusLayer = Chorus(clip.pop.y, clip.pop.Fs, 3, 0.035, 0.7);
saveTriplePlot(chorusLayer, clip.pop.Fs, 'Chorus choeur - extrait\_pop\_melodie.wav', ...
    fullfile(figDir, 'effect_chorus_layer.png'), clip.pop.y);

%% Flanger
flangerSig = Flanger(clip.pop.y, clip.pop.Fs);
saveTriplePlot(flangerSig, clip.pop.Fs, 'Flanger - extrait\_pop\_melodie.wav', ...
    fullfile(figDir, 'effect_flanger.png'), clip.pop.y);

%% Reverse
reverseSig = flipud(clip.extrait.y);
saveTriplePlot(normalizeSignal(reverseSig), clip.extrait.Fs, 'Reverse - Extrait.wav', ...
    fullfile(figDir, 'effect_reverse.png'), clip.extrait.y);

%% Tremolo
tremSig = Tremolo(clip.voix.y, clip.voix.Fs, 6, 0.6, 'sin');
saveTriplePlot(tremSig, clip.voix.Fs, 'Tremolo - Evil\_laugh\_elise.wav', ...
    fullfile(figDir, 'effect_tremolo.png'), clip.voix.y);

%% Vibrato
vibratoSig = Vibrato(clip.halleluia.y, clip.halleluia.Fs, 5, 0.003);
saveTriplePlot(vibratoSig, clip.halleluia.Fs, 'Vibrato - Halleluia.wav', ...
    fullfile(figDir, 'effect_vibrato.png'), clip.halleluia.y);

%% Overdrive
overSig = Overdrive(clip.jazz.y, clip.jazz.Fs);
saveTriplePlot(overSig, clip.jazz.Fs, 'Overdrive - extrait\_jazz\_bass.wav', ...
    fullfile(figDir, 'effect_overdrive.png'), clip.jazz.y);

%% Distorsion douce
softSig = Distort_soft(clip.pop.y, clip.pop.Fs);
saveTriplePlot(softSig, clip.pop.Fs, 'Soft clip - extrait\_pop\_melodie.wav', ...
    fullfile(figDir, 'effect_softclip.png'), clip.pop.y);

%% Distorsion forte
hardSig = Distort_hard(clip.beat.y, clip.beat.Fs, 6, 0.35);
saveTriplePlot(hardSig, clip.beat.Fs, 'Hard clip - extrait\_beat\_electro.wav', ...
    fullfile(figDir, 'effect_hardclip.png'), clip.beat.y);

%% Fuzz
fuzzSig = Fuzz(clip.basse.y, clip.basse.Fs);
saveTriplePlot(fuzzSig, clip.basse.Fs, 'Fuzz - extrait\_basse\_groove.wav', ...
    fullfile(figDir, 'effect_fuzz.png'), clip.basse.y);

%% Granularisation
granSig = Granularize(clip.classique.y, clip.classique.Fs);
saveTriplePlot(granSig(:,1), clip.classique.Fs, 'Granularize - extrait\_classique\_arpege.wav', ...
    fullfile(figDir, 'effect_granularize.png'), clip.classique.y);

%% Wah-Wah
wahSig = Wah_wah(clip.basse.y, clip.basse.Fs, 2000, 1800, 700);
saveTriplePlot(wahSig, clip.basse.Fs, 'Wah-Wah - extrait\_basse\_groove.wav', ...
    fullfile(figDir, 'effect_wahwah.png'), clip.basse.y);

%% Auto-wah
autoWahSig = Auto_wah(clip.pop.y, clip.pop.Fs, 300, 2200, 0.12);
saveTriplePlot(autoWahSig, clip.pop.Fs, 'Auto-wah - extrait\_pop\_melodie.wav', ...
    fullfile(figDir, 'effect_autowah.png'), clip.pop.y);

%% Mouvement stéréo
stereoSig = Stereo_mov(clip.extrait.y, clip.extrait.Fs);
saveStereoMovementFigure(stereoSig, clip.extrait.y, clip.extrait.Fs, ...
    fullfile(figDir, 'effect_stereo_move.png'));

%% Phaser
phaserSig = Phaser(clip.jazz.y, clip.jazz.Fs, 0.5, 0.8);
saveTriplePlot(phaserSig, clip.jazz.Fs, 'Phaser - extrait\_jazz\_bass.wav', ...
    fullfile(figDir, 'effect_phaser.png'), clip.jazz.y);

%% Autotune
autotuneSig = Autotune(clip.halleluia.y, clip.halleluia.Fs);
saveTriplePlot(autotuneSig, clip.halleluia.Fs, 'Autotune - Halleluia.wav', ...
    fullfile(figDir, 'effect_autotune.png'), clip.halleluia.y);

%% Bitcrusher
bitcrusherSig = Bitcrusher(clip.extrait.y, 6, 4);
saveTriplePlot(bitcrusherSig, clip.extrait.Fs, 'Bitcrusher - Extrait.wav', ...
    fullfile(figDir, 'effect_bitcrusher.png'), clip.extrait.y);

%% Bruit blanc
noiseSig = Bruit_blanc(clip.extrait.y, 8, 0.7);
saveTriplePlot(noiseSig, clip.extrait.Fs, 'Bruit blanc - Extrait.wav', ...
    fullfile(figDir, 'effect_bruit_blanc.png'), clip.extrait.y);

%% Transforme ma voix
transformeSig = Transforme_vers_ma_voix(clip.voix.y, clip.voix.Fs);
saveTriplePlot(transformeSig, clip.voix.Fs, 'Transforme ma voix - Evil\_laugh\_elise.wav', ...
    fullfile(figDir, 'effect_transforme_ma_voix.png'), clip.voix.y);

%% Harmonizer
harmo = applyHarmonizer(clip.voix, 3, 2);
saveTriplePlot(harmo, clip.voix.Fs, 'Harmonizer (quinte)', ...
    fullfile(figDir, 'harmonizer_voix_quinte.png'), clip.voix.y);

%% Voix "alien"
alien = applyAlien(clip.classique);
saveTriplePlot(alien, clip.classique.Fs, 'Voix "alien" - extrait\_classique\_arpege.wav', ...
    fullfile(figDir, 'alien_voix.png'), clip.classique.y);

%% Reverbs
reverbLarge = applyLargeReverb(clip.voix.y, clip.voix.Fs);
saveTriplePlot(reverbLarge, clip.voix.Fs, 'Reverb large', ...
    fullfile(figDir, 'effect_reverb_large.png'), clip.voix.y);

reverbSoft = applySoftReverb(clip.voix.y, clip.voix.Fs);
saveTriplePlot(reverbSoft, clip.voix.Fs, 'Reverb douce', ...
    fullfile(figDir, 'effect_reverb_douce.png'), clip.voix.y);

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

function result = applyLargeReverb(sig, Fs)
if size(sig,2) > 1
    sig = mean(sig, 2);
end
sig = normalizeSignal(sig);
delays = round([0.02 0.037 0.058] * Fs);
gains = [0.6 0.5 0.4];
y = sig;
for k = 1:numel(delays)
    tap = zeros(size(sig));
    tap(1:end-delays(k)) = sig(1+delays(k):end);
    y = y + gains(k) * tap;
end
result = normalizeSignal(y);
end

function result = applySoftReverb(sig, Fs)
if size(sig,2) > 1
    sig = mean(sig, 2);
end
sig = normalizeSignal(sig);
tailDur = min(2*Fs, numel(sig));
t = (0:tailDur-1)'/Fs;
ir = exp(-t/0.5) .* (0.7 + 0.3*cos(2*pi*1.5*t));
ir = ir / max(sum(abs(ir)), eps);
wet = conv(sig, ir, 'full');
wet = wet(1:numel(sig));
result = normalizeSignal(0.6 * wet + 0.4 * sig);
end

function saveTriplePlot(y, Fs, titleStr, outPath, varargin)
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
ref = [];
if ~isempty(varargin)
    ref = varargin{1};
    if size(ref,1) == 1
        ref = ref.';
    end
    if size(ref,2) > 1
        ref = mean(ref,2);
    end
    ref = ref(:);
end
if ~isempty(ref)
    minLen = min(numel(sig), numel(ref));
    sig = sig(1:minLen);
    ref = ref(1:minLen);
else
    minLen = numel(sig);
end
sig = normalizeSignal(sig);
if ~isempty(ref)
    ref = normalizeSignal(ref);
end
t = (0:minLen-1)/Fs;
Ysig = abs(fftshift(fft(sig)));
f = linspace(-Fs/2, Fs/2, numel(sig));
if ~isempty(ref)
    Yref = abs(fftshift(fft(ref)));
else
    Yref = [];
end
win = max(64, round(0.04 * Fs));
overlap = round(0.75 * win);
nfft = 2048;
fig = figure('Visible','off','Position',[100 100 900 900]);
subplot(3,1,1);
if ~isempty(ref)
    plot(t, ref, 'Color',[0.4 0.4 0.4],'LineWidth',1.1); hold on;
    plot(t, sig, 'Color',[0.75 0.05 0.75],'LineWidth',1.1);
    legend({'Original','Effet'},'Location','best');
else
    plot(t, sig, 'LineWidth',1.1);
end
xlabel('Temps (s)'); ylabel('Amplitude'); title([titleStr ' - superposition temporelle']); grid on;
subplot(3,1,2);
if ~isempty(ref)
    plot(f/1000, Yref, 'Color',[0.4 0.4 0.4],'LineWidth',1.05); hold on;
    plot(f/1000, Ysig, 'Color',[0.75 0.05 0.75],'LineWidth',1.05);
    legend({'Original','Effet'},'Location','best');
else
    plot(f/1000, Ysig, 'LineWidth',1.05);
end
xlabel('Fréquence (kHz)'); ylabel('|X(f)|'); title('Superposition fréquentielle'); grid on;
subplot(3,1,3);
[S, fAxis, tAxis] = localSpectrogram(sig, Fs, win, overlap, nfft);
imagesc(tAxis, fAxis/1000, 20*log10(abs(S)+eps)); axis xy;
xlabel('Temps (s)'); ylabel('Fréquence (kHz)'); title('Spectrogramme du signal traité');
colormap(parula); colorbar;
exportgraphics(fig, outPath, 'Resolution',300);
close(fig);
end

function saveStereoMovementFigure(y, ref, Fs, outPath)
if isempty(y)
    warning('Signal vide pour Stereo movement');
    return;
end
if size(y,2) < 2
    y = [y y];
end
left = y(:,1);
right = y(:,2);
if nargin < 2 || isempty(ref)
    ref = mean(y,2);
end
if size(ref,1) == 1
    ref = ref.';
end
if size(ref,2) > 1
    ref = mean(ref,2);
end
minLen = min([numel(left), numel(right), numel(ref)]);
left = left(1:minLen);
right = right(1:minLen);
ref = ref(1:minLen);
t = (0:minLen-1)/Fs;
[S,fAxis,tAxis] = localSpectrogram(left, Fs, max(64, round(0.04*Fs)), round(0.75*max(64, round(0.04*Fs))), 2048);
fig = figure('Visible','off','Position',[100 100 900 900]);
subplot(3,1,1);
plot(t, ref, 'Color',[0.4 0.4 0.4],'LineWidth',1); hold on;
plot(t, left, 'Color',[0.75 0.05 0.75],'LineWidth',1.1);
grid on;
xlabel('Temps (s)'); ylabel('Canal L');
title('Canal gauche vs. original');
legend({'Original','Gauche'},'Location','best');
subplot(3,1,2);
plot(t, ref, 'Color',[0.4 0.4 0.4],'LineWidth',1); hold on;
plot(t, right, 'Color',[0.05 0.55 0.9],'LineWidth',1.1);
grid on;
xlabel('Temps (s)'); ylabel('Canal R');
title('Canal droit vs. original');
legend({'Original','Droite'},'Location','best');
subplot(3,1,3);
imagesc(tAxis, fAxis/1000, 20*log10(abs(S)+eps)); axis xy;
xlabel('Temps (s)'); ylabel('Fréquence (kHz)');
title('Spectrogramme du canal gauche');
colormap(parula); colorbar;
sgtitle('Stereo movement - Extrait.wav');
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

function clip = tryLoadMonoClip(scriptDir, filename, fallbackClip)
filePath = fullfile(scriptDir, filename);
if exist(filePath, 'file') == 2
    clip = loadMonoClip(scriptDir, filename);
else
    if nargin < 3 || isempty(fallbackClip)
        error('Fichier %s introuvable et aucun repli fourni.', filename);
    end
    clip = fallbackClip;
end
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

function savePitchFlowchart(outPath)
fig = figure('Visible','off','Position',[100 100 900 500]);
axes(fig,'Position',[0 0 1 1]);
axis off;
boxes = struct( ...
    'input',[0.04 0.6 0.2 0.25], ...
    'pvoc',[0.3 0.6 0.2 0.25], ...
    'resample',[0.56 0.6 0.2 0.25], ...
    'mix',[0.78 0.6 0.18 0.25], ...
    'params',[0.18 0.15 0.27 0.25], ...
    'outputs',[0.55 0.15 0.3 0.25]);
addFlowBox(fig, boxes.input, sprintf('Entrée x(t)\nratio p=a/b'));
addFlowBox(fig, boxes.pvoc, sprintf('PVoc\n(Time-stretch p)'));
addFlowBox(fig, boxes.resample, sprintf('Rééchantillonnage\nResample(b,a)'));
addFlowBox(fig, boxes.mix, sprintf('Mix dry/wet\nNormalisation'));
addFlowBox(fig, boxes.params, sprintf('Paramètres\n- p dans [0.2,1.9]\n- Fenêtre 256 ou 1024\n- Overlap 75 %%'));
addFlowBox(fig, boxes.outputs, sprintf('Sortie y(t)\nMême durée\nPitch ajusté'));
addArrow(fig, boxes.input, boxes.pvoc);
addArrow(fig, boxes.pvoc, boxes.resample);
addArrow(fig, boxes.resample, boxes.mix);
addArrow(fig, boxes.params, boxes.pvoc);
addArrow(fig, boxes.mix, boxes.outputs);
annotation(fig,'textbox',[0.05 0.05 0.9 0.08], ...
    'String','Organigramme pitch-shifting : chaque bloc correspond à une étape du script pitch_speed', ...
    'LineStyle','none','HorizontalAlignment','center','FontWeight','bold', ...
    'Interpreter','none');
exportgraphics(fig, outPath, 'Resolution',300);
close(fig);
end

function addFlowBox(fig, pos, label)
annotation(fig,'rectangle',pos,'LineWidth',1.6,'FaceColor',[0.94 0.97 1]);
annotation(fig,'textbox',pos,'String',label,'LineStyle','none', ...
    'HorizontalAlignment','center','FontWeight','bold','FontSize',12,'Interpreter','none');
end

function addArrow(fig, srcPos, dstPos)
x1 = srcPos(1) + srcPos(3);
x2 = dstPos(1);
y1 = srcPos(2) + srcPos(4)/2;
y2 = dstPos(2) + dstPos(4)/2;
annotation(fig,'arrow',[x1 x2],[y1 y2],'LineWidth',1.4);
end

function savePitchOverlayTime(clip, outPath)
orig = normalizeSignal(clip.y);
up = normalizeSignal(applyPitch(clip, 2, 1));
down = normalizeSignal(applyPitch(clip, 1, 2));
minLen = min([numel(orig), numel(up), numel(down)]);
orig = orig(1:minLen);
up = up(1:minLen);
down = down(1:minLen);
t = (0:minLen-1)/clip.Fs;
windowDur = min(0.6, t(end));
idx = t <= windowDur;
fig = figure('Visible','off','Position',[100 100 900 400]);
plot(t(idx), orig(idx), 'k','LineWidth',1.2); hold on;
plot(t(idx), up(idx), 'Color',[0.89 0.1 0.1],'LineWidth',1.2);
plot(t(idx), down(idx), 'Color',[0.1 0.4 0.85],'LineWidth',1.2);
xlabel('Temps (s)'); ylabel('Amplitude (norm.)');
title('Superposition temporelle : original vs pitch x2 et /2');
legend({'Original','Pitch x2','Pitch /2'},'Location','best','Interpreter','none'); grid on;
exportgraphics(fig, outPath, 'Resolution',300);
close(fig);
end

function savePitchOverlayFreq(clip, outPath)
orig = normalizeSignal(clip.y);
up = normalizeSignal(applyPitch(clip, 2, 1));
down = normalizeSignal(applyPitch(clip, 1, 2));
minLen = min([numel(orig), numel(up), numel(down)]);
orig = orig(1:minLen);
up = up(1:minLen);
down = down(1:minLen);
nfft = 8192;
[fAxis, magOrig] = oneSidedSpectrum(orig, clip.Fs, nfft);
[~, magUp] = oneSidedSpectrum(up, clip.Fs, nfft);
[~, magDown] = oneSidedSpectrum(down, clip.Fs, nfft);
fig = figure('Visible','off','Position',[100 100 900 400]);
plot(fAxis/1000, magOrig, 'k','LineWidth',1.3); hold on;
plot(fAxis/1000, magUp, 'Color',[0.89 0.1 0.1],'LineWidth',1.1);
plot(fAxis/1000, magDown, 'Color',[0.1 0.4 0.85],'LineWidth',1.1);
xlabel('Fréquence (kHz)'); ylabel('Magnitude normalisée');
title('Superposition fréquentielle : simple décalage spectral');
legend({'Original','Pitch x2','Pitch /2'},'Location','northeast','Interpreter','none'); grid on;
xlim([0 8]);
exportgraphics(fig, outPath, 'Resolution',300);
close(fig);
end

function [fAxis, mag] = oneSidedSpectrum(sig, Fs, nfft)
sig = sig(:);
if numel(sig) < nfft
    sig = [sig; zeros(nfft - numel(sig),1)];
else
    sig = sig(1:nfft);
end
Y = abs(fft(sig, nfft));
mag = Y(1:nfft/2+1);
mag = mag / max(mag + eps);
fAxis = (0:(nfft/2)) * (Fs / nfft);
end
