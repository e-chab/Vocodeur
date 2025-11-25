function y = Distort1(x, gain, threshold)
% Effet Distort1 : distorsion dure par hard clipping
% x : signal d'entrée (mono ou stéréo)
% gain : amplification avant distorsion (défaut : 5)
% threshold : seuil de clipping (défaut : 0.3)

if nargin < 2, gain = 5; end
if nargin < 3, threshold = 0.3; end

x = x * gain;

% Hard clipping
y = min(max(x, -threshold), threshold);

% Normalisation
if max(abs(y(:))) > 0
    y = y / max(abs(y(:)));
end
end
