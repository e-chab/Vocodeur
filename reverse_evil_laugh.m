% Script MATLAB pour l'effet reverse sur Evil_laugh_elise.wav
% Génère une figure organisée (forme d'onde, spectre, spectrogramme)

[x, fs] = audioread('Evil_laugh_elise.wav');
if size(x,2) > 1
    x = mean(x,2); % Convertit en mono si stéréo
end

y = flipud(x); % Reverse

t = (0:length(x)-1)/fs;

figure('Color','k');
ax1 = subplot(3,1,1);
plot(t, x, 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2, 'DisplayName', 'Original'); hold on;
plot(t, y, 'Color', [1 0 1], 'LineWidth', 1.2, 'DisplayName', 'Reverse');
plot(t, x + y, 'Color', [1 0 1], 'LineWidth', 1.0, 'DisplayName', 'Superposition');
lgd1 = legend('Location','northeast');
set(lgd1,'Color','w','TextColor','k','FontSize',12);
set(gca,'Color','k','XColor','w','YColor','w','FontSize',12);
xlabel('Temps (s)','Color','w','FontSize',14); ylabel('Amplitude','Color','w','FontSize',14);
title('Reverse - superposition temporelle','Color','w','FontSize',16);

% Spectre fréquentiel
ax2 = subplot(3,1,2);
Nfft = 2^nextpow2(length(x));
f = fs*(0:(Nfft/2))/Nfft/1000; % kHz
Xf = fft(x + y, Nfft);
plot(f, abs(Xf(1:Nfft/2+1)), 'Color', [1 0 1], 'LineWidth', 1.5, 'DisplayName', 'Superposition');
lgd2 = legend('Location','northeast');
set(lgd2,'Color','w','TextColor','k','FontSize',12);
set(gca,'Color','k','XColor','w','YColor','w','FontSize',12);
xlabel('Fréquence (kHz)','Color','w','FontSize',14); ylabel('|X(f)|','Color','w','FontSize',14);
title('Superposition fréquentielle','Color','w','FontSize',16);

% Spectrogramme
ax3 = subplot(3,1,3);
signal = x + y;
win = round(0.05*fs); % 50 ms
step = round(win*0.2); % 80% recouvrement
nfft = max(256, 2^nextpow2(win));
frames = floor((length(signal)-win)/step)+1;
S = zeros(nfft/2+1, frames);
for k = 1:frames
    idx = (1:win) + (k-1)*step;
    w = 0.5 - 0.5*cos(2*pi*(0:win-1)'/(win-1)); % Fenêtre Hanning manuelle
    seg = signal(idx) .* w;
    X = fft(seg, nfft);
    S(:,k) = abs(X(1:nfft/2+1));
end
time = ((0:frames-1)*step)/fs;
freq = (0:nfft/2)*fs/nfft/1000; % kHz
imagesc(time, freq, 20*log10(S));
axis xy;
set(gca,'Color','k','XColor','w','YColor','w','FontSize',12);
xlabel('Temps (s)','Color','w','FontSize',14); ylabel('Fréquence (kHz)','Color','w','FontSize',14);
title('Spectrogramme du signal traité','Color','w','FontSize',16);
cb = colorbar;
cb.Color = 'w';
cb.FontSize = 12;
exportgraphics(gcf, 'C:\Users\yoane\Downloads\Evil_laugh_reverse_all.png');
close(gcf);