function y = Reverse(x, Fs)
% Fonction inversant l'ordre des lignes pour chaque colonne de x
%
% x : signal d entrée à inverser 
% Fs : frequence d'échantillonnage du signal d'entrée (en Hertz)

%% Inversion de l'ordre des lignes
x = x(:); % S'assure que le signal est en colonne

y = flipud(x); % Inverse le signal

end

