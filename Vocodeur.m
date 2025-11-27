%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VOCODEUR : Programme principal r�alisant un vocodeur de phase 
% et permettant de :
%
% 1- modifier le tempo (la vitesse de "prononciation")
%   sans modifier le pitch (fr�quence fondamentale de la parole)
%
% 2- modifier le pitch 
%   sans modifier la vitesse 
%
% 3- "robotiser" une voix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg = struct(...
	'audioFile','ASK',...
	'plotSpecWindow',128,...
	'plotSpecOverlap',120,...
	'plotSpecNfft',128,...
	'plotFigureStart',1,...
	'runTempo',true,...
	'runPitch',true,...
	'runRobot',true,...
	'runExtras',true,...
	'tempoSlow',2/3,...
	'tempoFast',3/2,...
	'pitchUp',[2 3],...
	'pitchDown',[3 2],...
	'robotFc',500,...
	'launchApp',false);

% S'assurer que tous les effets custom sont accessibles
scriptDir = fileparts(mfilename('fullpath'));
if ~isempty(scriptDir)
	addpath(scriptDir);
end

clipLibrary = get_demo_clips(scriptDir);
if isempty(clipLibrary)
	error('Aucun extrait audio disponible dans le dossier du projet.');
end

selectedClip = selectClipFromLibrary(cfg.audioFile, clipLibrary, scriptDir);
cfg.audioFile = selectedClip.path;
fprintf('Clip charge : %s (%s)\n', selectedClip.label, selectedClip.file);

if cfg.launchApp
	MixeurDJApp;
	return;
end

%% R�cup�ration d'un signal audio
%--------------------------------

[y,Fs]=audioread(cfg.audioFile);   %signal d'origine

% Remarque : si le signal est en st�r�o, ne traiter qu'une seule voie � la
% fois
y = y(:,1);

%% Courbes
%--------
N = length(y);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f-Fs/2;

figure(cfg.plotFigureStart)
subplot(311),plot(t,y)
title('Signal original')
subplot(312),plot(f,abs(fftshift(fft(y))))
subplot(313);
plotLocalSpectrogram(y,cfg.plotSpecWindow,cfg.plotSpecOverlap,cfg.plotSpecNfft,Fs);


%% Ecoute
%-------
disp('------------------------------------')
disp('SON ORIGINAL')
playAudio(y,Fs);

%-------------------------------
%% 1- MODIFICATION DE LA VITESSE
% (sans modification du pitch)
%-------------------------------
if cfg.runTempo
% PLUS LENT
rapp = cfg.tempoSlow;
ylent = PVoc(y,rapp,1024); 

% % % Ecoute
% % %-------
% disp('------------------------------------')
pause
disp('1- MODIFICATION DE LA VITESSE SANS MODIFIER LE PITCH')
% 
disp('Son en diminuant la vitesse sans modifier le pitch')
playAudio(ylent,Fs);

% Observation
%-------------
N = length(ylent);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f-Fs/2;

figure(cfg.plotFigureStart+1)
subplot(311),plot(t,ylent)
title('Signal "plus lent"')
subplot(312),plot(f,abs(fftshift(fft(ylent))))
subplot(313);
plotLocalSpectrogram(ylent,cfg.plotSpecWindow,cfg.plotSpecOverlap,cfg.plotSpecNfft,Fs);

% 
% % PLUS RAPIDE
rapp = cfg.tempoFast;
yrapide = PVoc(y,rapp,1024); 


% Ecoute 
% %-------
pause
disp('Son en augmentant la vitesse sans modifier le pitch')
playAudio(yrapide,Fs);

% Observation
%-------------
N = length(yrapide);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f-Fs/2;

figure(cfg.plotFigureStart+2)
subplot(311),plot(t,yrapide)
title('Signal "plus rapide"')
subplot(312),plot(f,abs(fftshift(fft(yrapide))))
subplot(313);
plotLocalSpectrogram(yrapide,cfg.plotSpecWindow,cfg.plotSpecOverlap,cfg.plotSpecNfft,Fs);
end



%----------------------------------
%% 2- MODIFICATION DU PITCH
% (sans modification de vitesse)
%----------------------------------
if cfg.runPitch
% Param�tres g�n�raux:
%---------------------
% Nombre de points pour la FFT/IFFT
Nfft = 256;

% Nombre de points (longueur) de la fen�tre de pond�ration 
% (par d�faut fen�tre de Hanning)
Nwind = Nfft;

% 1.1- Augmentation 
%-------------------
a = cfg.pitchUp(1);
b = cfg.pitchUp(2);
yvoc = PVoc(y, a/b,Nfft,Nwind);

% R�-�chantillonnage du signal temporel afin de garder la m�me vitesse
ypitch1 = localResample(yvoc,a,b);

%Somme de l'original et du signal modifi�
%Attention : on doit prendre le m�me nombre d'�chantillons
%Remarque : vous pouvez mettre un coefficient � ypitch pour qu'il
%intervienne + ou - dans la somme...
lmin = min(length(y),length(ypitch1));
ysomme = y(1:lmin)/max(abs(y(1:lmin))) + ypitch1(1:lmin)/max(abs(ypitch1(1:lmin)));

% % Ecoute
% %-------
% disp('------------------------------------')
pause
disp('2- MODIFICATION DU PITCH SANS MODIFIER LA VITESSE')
%  
disp('Son en augmentant le pitch sans modification de vitesse')
playAudio(ypitch1, Fs);
pause
disp('Somme du son original et du pr�c�dent')
playAudio(ysomme, Fs);

% Observation
%-------------
N = length(ypitch1);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f-Fs/2;

figure(cfg.plotFigureStart+3)
subplot(311),plot(t,ypitch1)
title('Signal avec "pitch" augment�')
subplot(312),plot(f,abs(fftshift(fft(ypitch1))))
subplot(313);
plotLocalSpectrogram(ypitch1,cfg.plotSpecWindow,cfg.plotSpecOverlap,cfg.plotSpecNfft,Fs);
%% 1.2- Diminution 
%-----------------

a = cfg.pitchDown(1);
b = cfg.pitchDown(2);
yvoc = PVoc(y, a/b,Nfft,Nwind); 

% R�-�chantillonnage du signal temporel afin de garder la m�me vitesse
ypitch2 = localResample(yvoc,a,b);  

%Somme de l'original et du signal modifi�
%Attention : on doit prendre le m�me nombre d'�chantillons
%Remarque : vous pouvez mettre un coefficient � ypitch pour qu'il
%intervienne + ou - dans la somme...
lmin = min(length(y),length(ypitch2));
ysomme = y(1:lmin)/max(abs(y(1:lmin))) + ypitch2(1:lmin)/max(abs(ypitch2(1:lmin)));

% Ecoute
%-------
 pause
 disp('Son en diminuant le pitch sans modification de vitesse')
 playAudio(ypitch2, Fs);
 pause
 disp('Somme du son original et du pr�c�dent')
 playAudio(ysomme, Fs);

% Observation
%-------------
N = length(ypitch2);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f-Fs/2;

figure(cfg.plotFigureStart+4)
subplot(311),plot(t,ypitch2)
title('Signal avec "pitch" diminu�')
subplot(312),plot(f,abs(fftshift(fft(ypitch2))))
subplot(313);
plotLocalSpectrogram(ypitch2,cfg.plotSpecWindow,cfg.plotSpecOverlap,cfg.plotSpecNfft,Fs);
end


%----------------------------
%% 3- ROBOTISATION DE LA VOIX
%-----------------------------
if cfg.runRobot
% Choix de la fr�quence porteuse (2000, 1000, 500, 200)
Fc = cfg.robotFc; 

yrob = Rob(y,Fc,Fs);

% Ecoute
%-------
pause
disp('------------------------------------')
disp('3- SON "ROBOTISE"')
playAudio(yrob,Fs)

% Observation
%-------------
N = length(yrob);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f-Fs/2;

figure(cfg.plotFigureStart+5)
subplot(311),plot(t,yrob)
title('Signal "robotis�"')
subplot(312),plot(f,abs(fftshift(fft(yrob))))
subplot(313);
plotLocalSpectrogram(yrob,cfg.plotSpecWindow,cfg.plotSpecOverlap,cfg.plotSpecNfft,Fs);
end

%--------------------------------------
%% 4- EFFETS SUPPLEMENTAIRES (BANQUE)
%--------------------------------------
if cfg.runExtras
targetVoice = '';
if ~isempty(scriptDir)
	preferred = fullfile(scriptDir,'Evil_laugh_elise.wav');
	if exist(preferred,'file') == 2
		targetVoice = preferred;
	else
		alt = fullfile(scriptDir,'Evil Laugh.wav');
		if exist(alt,'file') == 2
			targetVoice = alt;
		end
	end
end

extraEffects = {
	struct('name','Auto-wah','enabled',true,'fn',@(sig) Auto_wah(sig,Fs,300,2000,0.15)),
	struct('name','Acapella','enabled',true,'fn',@(sig) Acapella(sig,Fs)),
	struct('name','Autotune simplifie','enabled',true,'fn',@(sig) Autotune(sig,Fs)),
	struct('name','Bitcrusher','enabled',true,'fn',@(sig) Bitcrusher(sig,6,4)),
	struct('name','Bruit blanc','enabled',true,'fn',@(sig) Bruit_blanc(sig,8,0.7)),
	struct('name','Chorus / Echo','enabled',true,'fn',@(sig) Chorus(sig,Fs,1,0.35,0.4)),
	struct('name','Flanger','enabled',true,'fn',@(sig) Flanger(sig,Fs)),
	struct('name','Fuzz','enabled',true,'fn',@(sig) Fuzz(sig,8)),
	struct('name','Granularize','enabled',true,'fn',@(sig) Granularize(sig,Fs)),
	struct('name','Hard clipping','enabled',true,'fn',@(sig) Distort_hard_clipping(sig,5,0.3)),
	struct('name','Lo-fi','enabled',true,'fn',@(sig) Lo_fi(sig,6)),
	struct('name','Overdrive','enabled',true,'fn',@(sig) Overdrive(sig,Fs)),
	struct('name','Phaser','enabled',true,'fn',@(sig) Phaser(sig,Fs,0.5,0.8)),
	struct('name','Reverb large','enabled',true,'fn',@(sig) reverb(sig,Fs)),
	struct('name','Reverb douce','enabled',true,'fn',@(sig) Reverb2(sig,Fs,0.7,0.5)),
	struct('name','Ring mod','enabled',true,'fn',@(sig) RingMod(sig,Fs,150,0.85,0.8,0.3)),
	struct('name','Soft clipping','enabled',true,'fn',@(sig) Distort_soft_clipping(sig,Fs)),
	struct('name','Stereo movement','enabled',true,'fn',@(sig) Stereo_mov(sig,Fs)),
	struct('name','Tremolo','enabled',true,'fn',@(sig) Tremolo(sig,Fs,4,0.6)),
	struct('name','Transforme ma voix','enabled',~isempty(targetVoice),'fn',@(sig) transforme_vers_ma_voie(sig,Fs,targetVoice)),
	struct('name','Vibrato','enabled',true,'fn',@(sig) Vibrato(sig,Fs,6,0.003)),
	struct('name','Wah-wah','enabled',true,'fn',@(sig) Wah_wah(sig,Fs,1500,1800,700))
};

pause
disp('------------------------------------')
disp('4- EFFETS SUPPLEMENTAIRES')

failedEffects = {};
vizFig = cfg.plotFigureStart + 6;
for idx = 1:numel(extraEffects)
	effect = extraEffects{idx};
	if ~effect.enabled
		continue;
	end
	pause
	disp(['Effet : ' effect.name])
	try
		yeff = effect.fn(y);
	catch ME
		warning('Effet %s non applique : %s', effect.name, ME.message);
		failedEffects{end+1} = sprintf('%s (%s)', effect.name, ME.message); %#ok<AGROW>
		continue;
	end
	playAudio(yeff,Fs);
	visualizeEffect(yeff,Fs,vizFig,effect.name,cfg.plotSpecWindow,cfg.plotSpecOverlap,cfg.plotSpecNfft);
end

if ~isempty(failedEffects)
	fprintf('\nEffets en echec :\n');
	for k = 1:numel(failedEffects)
		fprintf(' - %s\n', failedEffects{k});
	end
else
	fprintf('\nTous les effets supplementaires ont ete joues avec succes.\n');
end
end

function clip = selectClipFromLibrary(selection, library, scriptDir)
%SELECLIP Choisit un extrait selon le parametre cfg.audioFile.
if nargin < 3
	scriptDir = '';
end
if isempty(library)
	error('La bibliotheque d''extraits est vide.');
end

if nargin < 1 || isempty(selection)
	selection = 1;
end

if ischar(selection) || (isstring(selection) && isscalar(selection))
	selStr = string(selection);
	if strcmpi(selStr,'ASK') || strcmpi(selStr,'MENU')
		clip = promptClipChoice(library);
		return;
	end
	idx = find(strcmpi({library.file}, selStr) | strcmpi({library.label}, selStr), 1);
	if isempty(idx)
		candidate = char(selStr);
		if exist(candidate,'file') ~= 2 && ~isempty(scriptDir)
			candidate = fullfile(scriptDir, candidate);
		end
		if exist(candidate,'file') == 2
			[~, name, ext] = fileparts(candidate);
			clip = struct('label', [name ext], 'file', [name ext], 'path', candidate);
			return;
		end
		error('Fichier audio %s introuvable.', selStr);
	end
	clip = library(idx);
	return;
elseif isnumeric(selection) && isscalar(selection)
	idx = round(selection);
	idx = max(1, min(numel(library), idx));
	clip = library(idx);
	return;
else
	error('Format de selection %s non supporte.', class(selection));
end
end

function clip = promptClipChoice(library)
fprintf('\n=== Banque d''extraits disponibles ===\n');
for k = 1:numel(library)
	fprintf('%2d) %s\n', k, library(k).label);
end
resp = input('Choisissez un numero (Enter=1) : ','s');
idx = str2double(resp);
if isnan(idx) || idx < 1 || idx > numel(library)
	idx = 1;
end
clip = library(idx);
end

function yout = localResample(y, p, q)
% Lightweight rational resampling using linear interpolation (avoids toolboxes)
if nargin ~= 3
	error('localResample requires exactly three inputs (signal, p, q).');
end

y = y(:);
if isempty(y)
	yout = y;
	return;
end

if p <= 0 || q <= 0
	error('Resampling factors p and q must be positive.');
end

n = numel(y);
tOriginal = 0:(n-1);
nOut = max(1, floor((n-1)*p/q) + 1);
tTarget = (0:(nOut-1)) * q / p;
tTarget(end) = min(tTarget(end), tOriginal(end));

yout = interp1(tOriginal, y, tTarget, 'linear');
yout = yout(:);
end

function visualizeEffect(sig, Fs, figNumber, labelText, winLen, overlap, nfft)
% Generic visualisation for arbitrary effects (handles mono or stereo)
if size(sig,2) > 1
	plotSig = sig(:,1);
	chanComment = ' (canal gauche)';
else
	plotSig = sig;
	chanComment = '';
end

plotSig = plotSig(:);
N = length(plotSig);
t = (0:N-1)/Fs;
f = (0:N-1)*Fs/N; f = f - Fs/2;

figure(figNumber); clf
subplot(311), plot(t, plotSig)
title(['Signal ' labelText chanComment])
xlabel('Temps (s)')
subplot(312), plot(f, abs(fftshift(fft(plotSig))))
xlabel('Frequence (Hz)')
subplot(313);
plotLocalSpectrogram(plotSig,winLen,overlap,nfft,Fs);
end

function playAudio(sig, Fs)
% Stop previous playback then play new audio scaled to full range
clear sound
soundsc(sig, Fs);
end

function plotLocalSpectrogram(x, windowLength, overlap, nfft, fs)
% Simple STFT-based spectrogram to avoid Signal Processing Toolbox usage
if size(x,2) > 1
	x = x(:,1);
end

hop = windowLength - overlap;
if hop <= 0
	error('Overlap must be smaller than the window length.');
end

if numel(x) < windowLength
	x = [x; zeros(windowLength - numel(x),1)];
end

nFrames = 1 + floor((numel(x) - windowLength)/hop);

if windowLength == 1
	win = 1;
else
	win = 0.5 - 0.5*cos(2*pi*(0:windowLength-1)/(windowLength-1));
end
spec = zeros(nfft, nFrames);
idx = 1;

for frame = 1:nFrames
	segment = x(idx:idx+windowLength-1) .* win(:);
	padded = zeros(nfft,1);
	padded(1:windowLength) = segment;
	spec(:,frame) = fft(padded);
	idx = idx + hop;
end

mag = abs(spec(1:nfft/2+1,:));
tAxis = ((0:nFrames-1)*hop)/fs;
fAxis = (0:nfft/2)*fs/nfft;

imagesc(tAxis, fAxis/1000, 20*log10(mag + eps));
axis xy;
xlabel('Time (s)');
ylabel('Frequency (kHz)');
colormap(gca,'jet');
colorbar('eastoutside');
end