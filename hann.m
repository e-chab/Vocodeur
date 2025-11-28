function w = hann(n)
%HANN Fallback Hann window implementation (Signal Processing Toolbox independent).
%   w = HANN(N) returns an N-point symmetric Hann window column vector.
%   This helper is provided so that scripts using the Hann window do not
%   require the Signal Processing Toolbox. If the official toolbox version
%   is available, MATLAB will pick it up before this file.

if ~(isscalar(n) && n == floor(n) && n > 0)
    error('hann:invalidLength','La taille N doit être un entier positif.');
end
if n == 1
    w = 1;
    return;
end
w = 0.5 - 0.5*cos(2*pi*(0:n-1)'/(n-1));
end
