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


%% R�cup�ration d'un signal audio
%--------------------------------

% [y,Fs]=audioread('Diner.wav');   %signal d'origine
 [y,Fs]=audioread('Extrait.wav');   %signal d'origine
% [y,Fs]=audioread('Halleluia.wav');   %signal d'origine

% Remarque : si le signal est en st�r�o, ne traiter qu'une seule voie � la
% fois
y = y(:,1);

%% Courbes
%--------
N = length(y);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(1)
subplot(311),plot(t,y)
title('Signal original')
subplot(312),plot(f,abs(fftshift(fft(y))))
subplot(313);
plotLocalSpectrogram(y,128,120,128,Fs);


%% Ecoute
%-------
disp('------------------------------------')
disp('SON ORIGINAL')
soundsc(y,Fs);

%-------------------------------
%% 1- MODIFICATION DE LA VITESSE
% (sans modification du pitch)
%-------------------------------
% PLUS LENT
rapp = 2/3;
ylent = PVoc(y,rapp,1024); 

% % % Ecoute
% % %-------
% disp('------------------------------------')
pause
disp('1- MODIFICATION DE LA VITESSE SANS MODIFIER LE PITCH')
% 
disp('Son en diminuant la vitesse sans modifier le pitch')
soundsc(ylent,Fs);

% Observation
%-------------
N = length(ylent);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(2)
subplot(311),plot(t,ylent)
title('Signal "plus lent"')
subplot(312),plot(f,abs(fftshift(fft(ylent))))
subplot(313);
plotLocalSpectrogram(ylent,128,120,128,Fs);

% 
% % PLUS RAPIDE
rapp = 3/2;
yrapide = PVoc(y,rapp,1024); 


% Ecoute 
% %-------
pause
disp('Son en augmentant la vitesse sans modifier le pitch')
soundsc(yrapide,Fs);

% Observation
%-------------
N = length(yrapide);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(3)
subplot(311),plot(t,yrapide)
title('Signal "plus rapide"')
subplot(312),plot(f,abs(fftshift(fft(yrapide))))
subplot(313);
plotLocalSpectrogram(yrapide,128,120,128,Fs);



%----------------------------------
%% 2- MODIFICATION DU PITCH
% (sans modification de vitesse)
%----------------------------------
% Param�tres g�n�raux:
%---------------------
% Nombre de points pour la FFT/IFFT
Nfft = 256;

% Nombre de points (longueur) de la fen�tre de pond�ration 
% (par d�faut fen�tre de Hanning)
Nwind = Nfft;

% 1.1- Augmentation 
%-------------------
a = 2;
b = 3;
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
soundsc(ypitch1, Fs);
pause
disp('Somme du son original et du pr�c�dent')
soundsc(ysomme, Fs);

% Observation
%-------------
N = length(ypitch1);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(4)
subplot(311),plot(t,ypitch1)
title('Signal avec "pitch" augment�')
subplot(312),plot(f,abs(fftshift(fft(ypitch1))))
subplot(313);
plotLocalSpectrogram(ypitch1,128,120,128,Fs);
%% 1.2- Diminution 
%-----------------

a = 3;
b = 2;
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
 soundsc(ypitch2, Fs);
 pause
 disp('Somme du son original et du pr�c�dent')
 soundsc(ysomme, Fs);

% Observation
%-------------
N = length(ypitch2);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(5)
subplot(311),plot(t,ypitch2)
title('Signal avec "pitch" diminu�')
subplot(312),plot(f,abs(fftshift(fft(ypitch2))))
subplot(313);
plotLocalSpectrogram(ypitch2,128,120,128,Fs);


%----------------------------
%% 3- ROBOTISATION DE LA VOIX
%-----------------------------
% Choix de la fr�quence porteuse (2000, 1000, 500, 200)
Fc = 500; 

yrob = Rob(y,Fc,Fs);

% Ecoute
%-------
pause
disp('------------------------------------')
disp('3- SON "ROBOTISE"')
soundsc(yrob,Fs)

% Observation
%-------------
N = length(yrob);
t = [0:N-1]/Fs;
f = [0:N-1]*Fs/N; f = f-Fs/2;

figure(6)
subplot(311),plot(t,yrob)
title('Signal "robotis�"')
subplot(312),plot(f,abs(fftshift(fft(yrob))))
subplot(313);
plotLocalSpectrogram(yrob,128,120,128,Fs);

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