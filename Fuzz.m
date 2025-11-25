function y = Fuzz(x, gain)
% Effet Fuzz : distorsion extrême par écrêtage carré
% x : signal d'entrée (mono ou stéréo)
% gain : amplification avant distorsion (défaut : 10)

if nargin < 2, gain = 10; end
x = x(:) * gain; % Amplifie le signal

% Applique une fonction de distorsion très non linéaire (fuzz)
y = sign(x) .* (abs(x) > 0.4); % Ecrêtage carré

% Normalisation
if max(abs(y)) > 0
    y = y / max(abs(y));
end
end
