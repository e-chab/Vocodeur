function y = Overdrive(x, Fs)
% Effet Overdrive : ajoute une saturation douce au signal audio
% x : signal d'entrée (mono ou stéréo)
% Fs : fréquence d'échantillonnage
%
% L'overdrive amplifie le signal et le "clipse" progressivement, ajoutant des harmoniques et du caractère.
% Typique des guitares électriques saturées ou des sons rock/blues.

%% Initialisation
% Nombre de lignes de l'entr�e :
N = length(x);
if size(x,2) == 1
    y = zeros(N,1); % Mono
else
    y = zeros(N,2); % Stéréo
end
% Seuil :
threshold = 1/5; 

%% Application de l'overdrive
for i=1:1:N
    
    % Signal inferieur au seuil en valeur absolue :
    if abs(x(i))< threshold 
        y(i,:) = 2 * x(i);
        
    % Signal entre seuil et 2*seuil : saturation progressive
    elseif abs(x(i))< 2 * threshold
        y(i,:) = sign(x(i)) * (1-((2-abs(x(i))*3).^2)/3); 
        
    % Signal superieur à 2 fois la valeur du seuil en valeur absolue :
    else
        y(i,:) = sign(x(i));
    end
    
end

% Normalisation du signal de sortie
if max(abs(y(:))) > 0
    y = y / max(abs(y(:)));
end
end