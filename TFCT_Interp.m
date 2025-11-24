function y = TFCT_Interp(X,t,Nov)

% y = TFCT_Interp(X, t, hop)   
% Interpolation du vecteur issu de la TFCT
%
% X : matrice issue de la TFCT
% t : vecteur des temps (valeurs réelles) sur lesquels on interpole
% Pour chaque valeur de t (et chaque colonne), on interpole le module du spectre 
% et on détermine la différence de phase entre 2 colonnes successives de X
% 
% y : la sortie est une matrice où chaque colonne correspond à l'interpolation de la colonne correspondante de X
% en préservant le saut de phase d'une colonne à l'autre
%
% programme largement inspiré d'un programme fait à l'université de Columbia


[nl,nc] = size(X);

% calcul de N = Nfft
N = 2*(nl-1);

% if nargin <3
%   % default value
%   Nov = N/2;
% end

% Initialisations
%-------------------
% Le spectre interpolé
y = zeros(nl, length(t));

% Phase initiale
ph = angle(X(:,1)); 

% Déphasage entre chaque échantillon de la TF
dphi = zeros(nl,1);
dphi(2:nl) = (2*pi*Nov)./(N./(1:(N/2)));

% Premier indice de la colonne interpolée à calculer 
% (première colonne de Y). Cet indice sera incrémenté
% dans la boucle
ind_col = 1;

% On ajoute à X une colonne de zéros pour éviter le problème de 
% X(col+1) en fin de boucle
X = [X,zeros(nl,1)];


% Boucle pour l'interpolation
%----------------------------
%Pour chaque valeur de t, on calcul la nouvelle colonne de Y à partir de 2
%colonnes successives de X
for tn = t
  % Indices des 2 colonnes à traiter 
  ind_2col = floor(tn) + [1,2];
  % Isolation des 2 colonnes à traiter
  X2cols = X(:,ind_2col);
  % Calcul des coefficients
  beta = tn - floor(tn);
  alpha = 1 - beta;
  % Calcul de l'interpolation du module de Y
  My = alpha*abs(X2cols(:,1)) + beta*(abs(X2cols(:,2)));
 % Calcul de la nouvelle colonne de Y
  y(:,ind_col) = My .* exp(j*ph);
  % Calcul de la phase pour la prochaine trame
  dp = angle(X2cols(:,2)) - angle(X2cols(:,1)) - dphi;  %déphasage
  dp = dp - 2 * pi * round(dp/(2*pi));   %forcer les variations entre -pi et +pi
  ph = ph + dphi + dp;   %nouvelle phase
  % On incrémente l'indice de la colonne pour la prochaine trame
  ind_col = ind_col+1;
end
