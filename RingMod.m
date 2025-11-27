function y = RingMod(x, Fs, carrierFreq, depth, vibratoFreq, vibratoDepth)
% Effet RingMod : modulation multiplicative pour un timbre metallique
% x : signal d'entree (mono ou stereo)
% Fs : frequence d'echantillonnage
% carrierFreq : frequence de la porteuse (Hz)
% depth : quantite d'effet (0..1)
% vibratoFreq : frequence de la modulation lente de la porteuse (Hz)
% vibratoDepth : amplitude relative de cette modulation (0..1)

if nargin < 3 || isempty(carrierFreq), carrierFreq = 150; end
if nargin < 4 || isempty(depth), depth = 0.8; end
if nargin < 5 || isempty(vibratoFreq), vibratoFreq = 0.7; end
if nargin < 6 || isempty(vibratoDepth), vibratoDepth = 0.25; end

depth = max(0, min(1, depth));
vibratoDepth = max(0, min(0.95, vibratoDepth));

x = double(x);
N = size(x,1);
if N == 0
    y = x;
    return;
end

t = (0:N-1)'/Fs;
instFreq = carrierFreq * (1 + vibratoDepth * sin(2*pi*vibratoFreq*t));
instFreq = max(5, instFreq); % evite les frequences nulles
phase = 2*pi*cumsum(instFreq) / Fs;
carrier = sin(phase);

if size(x,2) == 1
    modSig = x .* carrier;
else
    modSig = x .* [carrier carrier];
end

y = (1 - depth) * x + depth * modSig;

maxVal = max(abs(y(:)));
if maxVal > 0
    y = y / maxVal;
end
end
