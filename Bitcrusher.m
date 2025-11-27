function y = Bitcrusher(x, Fs, bits)
% Effet bitcrusher : réduit la résolution du signal
% x : signal d'entrée
% bits : nombre de bits de résolution (ex : 4, 8)

if nargin < 3, bits = 4; end
x = x(:);

% Normalisation du signal entre -1 et 1
x = x / max(abs(x));

% Quantification
levels = 2^bits;
y = round(x * (levels/2 - 1)) / (levels/2 - 1);

% Re-normalisation
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end
