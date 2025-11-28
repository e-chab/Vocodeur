%% Script de Test et Visualisation des Effets Audio
% Ce script génère des figures pour chaque effet audio demandé,
% en appliquant l'effet sur un fichier audio spécifique et en
% visualisant le résultat (forme d'onde, spectre, spectrogramme).

clear; clc; close all;

% --- Configuration ---
% Ajoute le dossier courant au path pour que MATLAB trouve les fonctions d'effets
addpath(pwd);

% Structure définissant chaque tâche de test
% {nom_effet, fichier_audio, type_plot, {params_effet}, {params_plot}}
tasks = {
    {'Flanger',       'extrait_accords_lents.wav',   'superimposed', {}, {}}, ...
    {'Reverse',       'Pink_Floyd.wav',              'superimposed', {}, {}}, ...
    {'Tremolo',       'Evil_laugh_elise.wav',        'superimposed', {5, 0.7, 'sin'}, {'Bleu Foncé', 'Bleu Clair'}}, ...
    {'Vibrato',       'Evil_laugh_elise.wav',        'spectrum',     {}, {}}, ...
    {'Overdrive',     'Matt_Rach.wav',               'superimposed', {}, {}}, ...
    {'Distort_soft',  'Matt_Rach.wav',               'superimposed', {}, {}}, ...
    {'Distort_hard',  'Matt_Rach.wav',               'superimposed', {}, {}}, ...
    {'Fuzz',          'Matt_Rach.wav',               'superimposed', {}, {}}, ...
    {'Granularize',   'extrait_pop_melodie.wav',     'superimposed_spectrum', {}, {}}, ...
    {'Wah-wah',       'extrait_accords_lents.wav',   'spectrogram',  {}, {}}, ...
    {'Auto_wah',      'extrait_accords_lents.wav',   'spectrogram',  {}, {}}, ...
    {'Phaser',        'extrait_classique_arpege.wav','superimposed', {}, {}}, ...
    {'Autotune',      'Halleluia.wav',               'superimposed_spectrogram', {}, {}}, ...
    {'Bitcrusher',    'Halleluia.wav',               'superimposed', {6}, {}}, ...
    {'Bruit_blanc',   'Diner.wav',                   'superimposed_spectrogram', {}, {}}, ...
    {'Transforme_vers_ma_voix', 'Evil_laugh.wav',    'superimposed', {'Evil_laugh_elise.wav'}, {}} ...
};

% --- Boucle Principale ---
for i = 1:numel(tasks)
    task = tasks{i};
    effectName = task{1};
    audioFile = task{2};
    plotType = task{3};
    effectParams = task{4};
    plotParams = task{5};

    fprintf('Traitement de l''effet: %s sur %s...\n', effectName, audioFile);

    % --- Chargement de l'audio ---
    if ~exist(audioFile, 'file')
        warning('Fichier audio non trouvé: %s. Tâche ignorée.', audioFile);
        continue;
    end
    [x, Fs] = audioread(audioFile);
    x = x(:, 1); % Force mono pour la simplicité

    % --- Application de l'effet ---
    try
        effectFunc = str2func(effectName);
        y = effectFunc(x, Fs, effectParams{:});
    catch ME
        warning('Erreur lors de l''application de l''effet %s: %s. Tâche ignorée.', effectName, ME.message);
        continue;
    end

    % --- Génération des plots ---
    switch plotType
        case 'superimposed'
            plot_superimposed(x, y, Fs, effectName, plotParams);
        case 'spectrum'
            plot_spectrum(x, y, Fs, effectName);
        case 'spectrogram'
            plot_spectrogram(x, y, Fs, effectName);
        case 'superimposed_spectrum'
            plot_superimposed(x, y, Fs, effectName, plotParams);
            plot_spectrum(x, y, Fs, effectName);
        case 'superimposed_spectrogram'
            plot_superimposed(x, y, Fs, effectName, plotParams);
            plot_spectrogram(x, y, Fs, effectName);
    end
    drawnow; % Force l'affichage des figures
end

fprintf('Toutes les tâches de visualisation sont terminées.\n');


% --- Fonctions d'Aide pour les Plots ---

function plot_superimposed(x, y, Fs, effectName, plotParams)
    % Affiche les signaux avant et après superposés
    figure('Name', ['Effet: ' effectName ' - Signal']);
    t = (0:length(x)-1) / Fs;
    
    color1 = 'b'; % Bleu par défaut
    color2 = 'r'; % Rouge par défaut
    legend1 = 'Avant';
    legend2 = 'Après';

    if ~isempty(plotParams)
        if length(plotParams) >= 2
            color1 = get_color_code(plotParams{1});
            color2 = get_color_code(plotParams{2});
            legend1 = plotParams{1};
            legend2 = plotParams{2};
        end
    end

    plot(t, x, 'Color', color1, 'DisplayName', legend1);
    hold on;
    % S'assure que y a la même longueur que x pour le plot
    if length(y) ~= length(x)
        t_y = (0:length(y)-1) / Fs;
        plot(t_y, y, 'Color', color2, 'DisplayName', legend2);
    else
        plot(t, y, 'Color', color2, 'DisplayName', legend2);
    end
    hold off;
    grid on;
    legend;
    xlabel('Temps (s)');
    ylabel('Amplitude');
    title(['Superposition des signaux Avant/Après - Effet: ' effectName]);
end

function plot_spectrum(x, y, Fs, effectName)
    % Affiche les spectres de puissance avant et après
    figure('Name', ['Effet: ' effectName ' - Spectre']);
    
    % Spectre avant
    subplot(2, 1, 1);
    [pxx, f] = pwelch(x, [], [], [], Fs);
    plot(f, 10*log10(pxx));
    grid on;
    title('Spectre du signal Avant');
    xlabel('Fréquence (Hz)');
    ylabel('Puissance (dB/Hz)');
    
    % Spectre après
    subplot(2, 1, 2);
    [pyy, f] = pwelch(y, [], [], [], Fs);
    plot(f, 10*log10(pyy));
    grid on;
    title(['Spectre du signal Après - Effet: ' effectName]);
    xlabel('Fréquence (Hz)');
    ylabel('Puissance (dB/Hz)');
end

function plot_spectrogram(x, y, Fs, effectName)
    % Affiche les spectrogrammes avant et après
    figure('Name', ['Effet: ' effectName ' - Spectrogramme']);
    win = hamming(512);
    noverlap = 256;
    nfft = 1024;

    % Spectrogramme avant
    subplot(2, 1, 1);
    spectrogram(x, win, noverlap, nfft, Fs, 'yaxis');
    title('Spectrogramme du signal Avant');
    
    % Spectrogramme après
    subplot(2, 1, 2);
    spectrogram(y, win, noverlap, nfft, Fs, 'yaxis');
    title(['Spectrogramme du signal Après - Effet: ' effectName]);
end

function colorCode = get_color_code(colorName)
    % Traduit un nom de couleur en code MATLAB
    switch lower(colorName)
        case 'bleu foncé'
            colorCode = [0, 0, 0.5];
        case 'bleu clair'
            colorCode = [0.5, 0.7, 1];
        otherwise
            colorCode = colorName; % Au cas où un code comme 'b' ou 'r' est passé
    end
end
