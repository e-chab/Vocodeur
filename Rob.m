function yrob = Rob(y,fc,Fs)

% S'assurer que y est colonne
y = y(:);

Nh = length(y);
t  = (0:Nh-1)'/Fs;   % vecteur temps colonne

% Robotisation par modulation complexe
yrob = real(y .* exp(-1j*2*pi*fc*t));

% Normalisation pour éviter la saturation
m = max(abs(yrob));
if m > 0
    yrob = yrob / m;
end
end

