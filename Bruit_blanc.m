function y = Bruit_blanc(x, RSB, mix)
% Ajoute un bruit blanc gaussien avec un RSB cible
% x : signal d'entrée (mono ou stéréo)
% RSB : rapport signal/bruit en dB (défaut 10 dB)
% mix : coefficient multiplicatif du bruit (0..1, défaut 1)

if nargin < 2, RSB = 10; end
if nargin < 3, mix = 1.0; end

x = double(x);
signalPower = mean(x(:).^2);
if signalPower <= 0
    signalPower = 1e-6;
end

noisePower = signalPower / (10^(RSB/10));
sigma = sqrt(noisePower);
noise = sigma * randn(size(x));

y = x + mix * noise;

if max(abs(y(:))) > 0
    y = y / max(abs(y(:)));
end
end
