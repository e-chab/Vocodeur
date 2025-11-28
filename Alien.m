function y = Alien(x, Fs, pitchFactor, carrier, Nfft, Nwind)
% y = Alien(x, Fs, pitchFactor, carrier, Nfft, Nwind)
% Effet "Alien" combinant un pitch shift (PVoc) et une robotisation (Rob).
% - pitchFactor (>1 monte, <1 baisse), defaut 1.6
% - carrier (Hz) pour Rob, defaut 900
% - Nfft/Nwind pour PVoc, defaut 512/512

if nargin < 3 || isempty(pitchFactor), pitchFactor = 1.6; end
if nargin < 4 || isempty(carrier),     carrier = 900;    end
if nargin < 5 || isempty(Nfft),        Nfft = 512;       end
if nargin < 6 || isempty(Nwind),       Nwind = Nfft;     end

x = double(x);
if isempty(x) || isempty(Fs) || Fs <= 0
    y = x;
    return;
end

% Ensure 2D (samples x channels)
if isrow(x), x = x.'; end
if size(x,2) > 2
    x = x(:,1:2);
end

% Process per channel
numCh = size(x,2);
y = zeros(0,1);
for ch = 1:numCh
    sig = x(:,ch);
    sig = sig(:);

    % Pitch shift via PVoc time-stretch + resampling to keep duration
    s1 = PVoc(sig, pitchFactor, Nfft, Nwind);
    s2 = localResampleLinear(s1, pitchFactor, 1);

    % Robotize for metallic/alien timbre
    s3 = Rob(s2, carrier, Fs);

    % Ajout d'un vibrato subtil (fréquence 6 Hz, profondeur 2 ms)
    s4 = Vibrato(s3, Fs, 6, 0.002);
    % Ajout d'un trémolo subtil triangulaire (fréquence 4 Hz, profondeur 0.15)
    s5 = Tremolo(s4, Fs, 4, 0.15, 'triangle');

    % Normalize and collect
    if any(isfinite(s5))
        m = max(1e-9, max(abs(s5)));
        s5 = s5 ./ m;
    end

    if ch == 1
        y = s5(:);
    else
        n = min(numel(y), numel(s5));
        y = y(1:n) + s5(1:n);
    end
end

% Final normalization
if any(isfinite(y))
    y = y ./ max(1e-9, max(abs(y)));
end

end

function yout = localResampleLinear(y, p, q)
% Minimal linear-resample helper, p/q is expansion factor
    y = y(:);
    if isempty(y)
        yout = y; return;
    end
    if p <= 0 || q <= 0
        error('Invalid resampling factors.');
    end
    n = numel(y);
    tOriginal = 0:(n-1);
    nOut = max(1, floor((n-1)*p/q) + 1);
    tTarget = (0:(nOut-1)) * q / p;
    tTarget(end) = min(tTarget(end), tOriginal(end));
    yout = interp1(tOriginal, y, tTarget, 'linear');
    if isempty(yout)
        yout = y(1); % fallback single sample
    end
    yout = yout(:);
end
