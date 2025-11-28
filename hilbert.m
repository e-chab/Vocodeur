function y = hilbert(x)
%HILBERT Minimal analytic signal implementation (toolbox-free).
%   y = HILBERT(x) returns the analytic signal of real-valued input x by
%   zeroing the negative-frequency components in the FFT domain. The
%   implementation supports column vectors or matrices (operates along the
%   first dimension).

x = double(x);
[n, m] = size(x);
if n == 0
    y = x;
    return;
end
X = fft(x);
h = zeros(n,1);
if mod(n,2) == 0
    % even
    h([1, n/2+1]) = 1;
    h(2:n/2) = 2;
else
    % odd
    h(1) = 1;
    h(2:(n+1)/2) = 2;
end
H = repmat(h, 1, m);
Y = X .* H;
y = ifft(Y);
end
