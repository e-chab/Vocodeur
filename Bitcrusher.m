function y = Bitcrusher(x, bits, downsampleFactor)
% Effet Bitcrusher : réduction de la résolution + sous-échantillonnage
% x : signal d'entrée (mono ou stéréo)
% bits : profondeur de quantification (défaut : 6 bits)
% downsampleFactor : maintien d'un échantillon sur N (défaut : 4)

if nargin < 2 || isempty(bits), bits = 6; end
if nargin < 3 || isempty(downsampleFactor), downsampleFactor = 4; end

if downsampleFactor < 1
    downsampleFactor = 1;
end

x = double(x);
if isvector(x)
    x = x(:); % garantit une colonne pour les signaux mono
end
peak = max(abs(x(:)));
if peak > 0
    xNorm = x / peak;
else
    xNorm = x;
end

levels = max(2, 2^bits);
quantized = round(xNorm * (levels/2 - 1)) / (levels/2 - 1);

y = quantized;
numSamples = size(y,1);
numChannels = size(y,2);
for ch = 1:numChannels
    chan = y(:,ch);
    for idx = 1:downsampleFactor:numSamples
        blockEnd = min(idx + downsampleFactor - 1, numSamples);
        chan(idx:blockEnd) = chan(idx);
    end
    y(:,ch) = chan;
end

if peak > 0
    y = y * peak;
end

if max(abs(y(:))) > 0
    y = y / max(abs(y(:)));
end
end
