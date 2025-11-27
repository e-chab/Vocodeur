function generatedFiles = generate_extrait(outputDir)
%GENERATE_EXTRAIT Crée 10 extraits WAV synthétiques pour les démonstrations.
%   generatedFiles = generate_extrait() écrit les fichiers à côté du script.
%   generatedFiles = generate_extrait(outputDir) force un dossier cible.

if nargin < 1 || isempty(outputDir)
    outputDir = fileparts(mfilename('fullpath'));
end
if ~isfolder(outputDir)
    error('Le dossier cible %s est introuvable.', outputDir);
end

Fs  = 44100;          % fréquence d'échantillonnage
dur = 6;              % durée de chaque extrait (en secondes) < 10 s
N   = round(Fs*dur);  % nombre d'échantillons
t   = ((0:N-1)/Fs).';

% Petite fonction de fade in/out (pour éviter les clics)
fadeDur = 0.01;                   % 10 ms
Nfade   = round(fadeDur*Fs);
win     = ones(N,1);
fade    = linspace(0,1,Nfade)';
win(1:Nfade)              = fade;
win(end-Nfade+1:end)      = flipud(fade);

generatedFiles = {};

% -------------------------------------------------------------------------
% 1) Pop / mélodie simple (sine lead sur gamme majeure)
% -------------------------------------------------------------------------
noteDur = 0.5;                          % 0.5 s par note => 12 notes ~ 6 s
Nnote   = round(noteDur*Fs);

% Fréquences de notes (en Hz) proches d'une gamme de La majeur
freqs = [440 494 523 587 659 587 523 494 440 392 440 494];

y1 = zeros(N,1);
for k = 1:numel(freqs)
    idxStart = (k-1)*Nnote + 1;
    idxEnd   = min(k*Nnote, N);
    idx      = idxStart:idxEnd;
    tn       = ((0:numel(idx)-1)/Fs).';
    y1(idx)  = 0.8*sin(2*pi*freqs(k).*tn) + 0.2*sin(2*pi*2*freqs(k).*tn);
end

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_pop_melodie.wav',y1,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 2) Ligne de basse simple (style funk / groove lent)
% -------------------------------------------------------------------------
y2 = zeros(N,1);
bassFreqs = [55 65 73 82 65 73 82 55];    % notes graves
noteDur2  = dur / numel(bassFreqs);
Nnote2    = round(noteDur2*Fs);

for k = 1:numel(bassFreqs)
    idxStart = (k-1)*Nnote2 + 1;
    idxEnd   = min(k*Nnote2, N);
    idx      = idxStart:idxEnd;
    tn       = ((0:numel(idx)-1)/Fs).';
    env      = exp(-3*tn);               % enveloppe décroissante
    y2(idx)  = 0.9*sin(2*pi*bassFreqs(k).*tn) .* env;
end

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_basse_groove.wav',y2,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 3) Accords lents (type pad / ambient soft)
% -------------------------------------------------------------------------
chordFreqs = [261.63 329.63 392.00];   % Do majeur (C-E-G)
modEnv = 1 + 0.1*sin(2*pi*0.2*t) + 0.1*sin(2*pi*0.05*t);
y3 = zeros(N,1);
for f = chordFreqs
    y3 = y3 + (sin(2*pi*f*t) .* modEnv);
end
envSlow = linspace(0,1,N).*linspace(1,0.3,N);  % montée puis légère descente
y3 = y3(:).*envSlow(:);
generatedFiles{end+1,1} = writeClip(outputDir,'extrait_accords_lents.wav',y3,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 4) Chiptune / 8-bit (carré + vibrato)
% -------------------------------------------------------------------------
baseFreq = 440;
vibrato  = 5;             % Hz
freqInst = baseFreq + 40*sin(2*pi*vibrato*t);
square   = sign(sin(2*pi*freqInst.*t));   % onde carrée approximative
vol = 0.7 + 0.3*sin(2*pi*1.5*t);          % variations façon "jeu vidéo"
y4  = square(:).*vol(:);
generatedFiles{end+1,1} = writeClip(outputDir,'extrait_chiptune.wav',y4,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 5) Beat électro très simple (kick + snare)
% -------------------------------------------------------------------------
y5 = zeros(N,1);
kickDur = 0.12; Nk = round(kickDur*Fs);          % Kick (sine grave + enveloppe)
tk      = ((0:Nk-1)/Fs).';
kick    = sin(2*pi*60*tk) .* exp(-25*tk);

snDur = 0.08; Ns = round(snDur*Fs);              % Snare (bruit + enveloppe)
ts    = ((0:Ns-1)/Fs).';
snare = randn(Ns,1) .* exp(-35*ts);

beatStep = 0.5;              % 120 BPM (~0.5 s entre kicks)
kickPos  = 1:round(beatStep*Fs):N-Nk;
snPos    = round(0.25*Fs):round(beatStep*Fs):N-Ns;

for p = kickPos
    idx = p:(p+Nk-1);
    y5(idx) = y5(idx) + kick;
end

for p = snPos
    idx = p:(p+Ns-1);
    y5(idx) = y5(idx) + snare;
end

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_beat_electro.wav',y5,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 6) Walking bass "jazz"
% -------------------------------------------------------------------------
y6 = zeros(N,1);
bassFreqs2 = [55 62 69 74 82 74 69 62 55 50 55 62]; % petite marche
noteDur3   = 0.5;
Nnote3     = round(noteDur3*Fs);

for k = 1:numel(bassFreqs2)
    idxStart = (k-1)*Nnote3 + 1;
    if idxStart > N, break; end
    idxEnd = min(k*Nnote3, N);
    idx    = idxStart:idxEnd;
    tn     = ((0:numel(idx)-1)/Fs).';
    env    = exp(-2*tn);
    y6(idx)= y6(idx) + 0.8*sin(2*pi*bassFreqs2(k).*tn).*env;
end

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_jazz_bass.wav',y6,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 7) Arpèges "classique"
% -------------------------------------------------------------------------
y7 = zeros(N,1);
arpFreqs = [261.63 329.63 392.00 523.25]; % C-E-G-C'
noteDur4 = 0.25;
Nnote4   = round(noteDur4*Fs);
kmax     = floor(N/Nnote4);

for k = 1:kmax
    f      = arpFreqs( mod(k-1,numel(arpFreqs))+1 );
    idxStart = (k-1)*Nnote4 + 1;
    idxEnd   = min(k*Nnote4, N);
    idx      = idxStart:idxEnd;
    tn       = ((0:numel(idx)-1)/Fs).';
    env      = exp(-5*tn);
    y7(idx)  = y7(idx) + 0.8*sin(2*pi*f.*tn).*env;
end

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_classique_arpege.wav',y7,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 8) Ambient / drone (pads + bruit léger)
% -------------------------------------------------------------------------
fPad  = [220 277 330];   % accord mineur
y8    = zeros(N,1);
for f = fPad
    y8 = y8 + 0.8*sin(2*pi*f*t + 0.2*sin(2*pi*0.1*t));
end
noise = 0.1*randn(N,1);
env8  = linspace(0,1,N).*linspace(1,0.2,N);
y8    = y8(:).*env8(:) + noise;

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_ambient.wav',y8,win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 9) Loop "lofi" (mélodie simple + bruit de fond)
% -------------------------------------------------------------------------
fLofi  = 330;
mel    = sin(2*pi*fLofi*t) .* (0.6+0.4*sin(2*pi*0.5*t));
hiss   = 0.03*randn(size(t));          % bruit type "cassette"
wow    = 1 + 0.01*sin(2*pi*0.3*t);    % légère dérive de pitch
y9     = sin(2*pi*fLofi*wow.*t).*0.6 + mel.*0.4 + hiss;

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_lofi_loop.wav',y9(:),win,Fs); %#ok<AGROW>

% -------------------------------------------------------------------------
% 10) Percussions "world" (claps / toms synthétiques)
% -------------------------------------------------------------------------
y10 = zeros(N,1);

tomDur = 0.15; Nt = round(tomDur*Fs);          % "tom" = sin grave + enveloppe
tt     = ((0:Nt-1)/Fs).';
tom    = sin(2*pi*110*tt).*exp(-20*tt);

clapDur = 0.08; Nc = round(clapDur*Fs);         % "clap" = bruit court
tc      = ((0:Nc-1)/Fs).';
clap    = randn(Nc,1).*exp(-40*tc);

tomPos  = 1:round(0.75*Fs):N-Nt;
clPos   = round(0.37*Fs):round(0.75*Fs):N-Nc;

for p = tomPos
    idx = p:(p+Nt-1);
    y10(idx) = y10(idx) + tom;
end

for p = clPos
    idx = p:(p+Nc-1);
    y10(idx) = y10(idx) + clap;
end

generatedFiles{end+1,1} = writeClip(outputDir,'extrait_percusions.wav',y10,win,Fs); %#ok<AGROW>

disp('10 extraits .wav générés.');
end

function fullPath = writeClip(outputDir, filename, signal, win, Fs)
signal = signal(:);
if numel(win) >= numel(signal)
    window = win(1:numel(signal));
else
    window = ones(numel(signal),1);
    window(1:numel(win)) = win;
    window(numel(win)+1:end) = win(end);
end
signal = signal .* window;
peak = max(abs(signal)) + 1e-12;
signal = signal / peak;
fullPath = fullfile(outputDir, filename);
audiowrite(fullPath, signal, Fs);
end
