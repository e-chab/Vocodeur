function y = Bruit_blanc(x, RSB, mix)
% Ajoute un bruit blanc gaussien avec un RSB cible.
% x   : signal d'entree (mono ou stereo)
% RSB : rapport signal/bruit en dB (defaut 10 dB)
% mix : coefficient multiplicatif pour le bruit (defaut 1).
%
% Compatibilite : si la fonction est appelee comme Bruit_blanc(x, Fs)
% (ancienne signature), on ignore ce second argument puisqu'un RSB ne
% depasse jamais 120 dB. On retombe ainsi sur les valeurs par defaut.

if nargin >= 2 && ~isempty(RSB) && RSB > 120
    RSB = [];
end

if nargin < 2 || isempty(RSB), RSB = 10; end
if nargin < 3 || isempty(mix), mix = 1.0; end

x = double(x);
signalPower = mean(x(:).^2);
if signalPower <= 0
    signalPower = 1e-6;
end

noisePower = signalPower / (10^(RSB/10));
sigma = sqrt(noisePower);
noise = sigma * randn(size(x));

y = x + mix * noise;

peak = max(abs(y(:)));
if peak > 0
    y = y / peak;
end
end
