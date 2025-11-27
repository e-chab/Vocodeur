classdef MixeurDJApp < matlab.apps.AppBase
    % Interface "mixeur/DJ" permettant de charger des extraits,
    % ajuster vitesse/pitch, appliquer un effet avancé et lancer la lecture.

    properties (Access = public)
        UIFigure            matlab.ui.Figure
        TitleLabel          matlab.ui.control.Label
        FileListBoxLabel    matlab.ui.control.Label
        FileListBox         matlab.ui.control.ListBox
        AddFileButton       matlab.ui.control.Button
        DeleteFileButton    matlab.ui.control.Button
        DeleteAllButton     matlab.ui.control.Button
        PlayButton          matlab.ui.control.Button
        StopButton          matlab.ui.control.Button
        StatusLabel         matlab.ui.control.Label
        SpeedSliderLabel    matlab.ui.control.Label
        SpeedSlider         matlab.ui.control.Slider
        SpeedValueLabel     matlab.ui.control.Label
        PitchSliderLabel    matlab.ui.control.Label
        PitchSlider         matlab.ui.control.Slider
        PitchValueLabel     matlab.ui.control.Label
        EffectPanel         matlab.ui.container.Panel
        WaveformAxes        matlab.ui.control.UIAxes
        SpectrumAxes        matlab.ui.control.UIAxes
        AnimationAxes       matlab.ui.control.UIAxes
        LiveAxes            matlab.ui.control.UIAxes
    end
    properties (Access = private)
        fileEntries struct
        effectCatalog struct
        effectButtons matlab.ui.control.Button
        selectedEffect string = "Aucun"
        player
        currentSignal double
        currentFs double
        speedValue double = 1
        pitchValue double = 1
        robotCarrier double = 500
        animationTimer timer
        liveTimer timer
        discAngle double = 0
        notePhase double = 0
        playbackBuffer double
        playbackFs double = 0
    end
    methods (Access = private)

        function initCatalog(app)
            app.effectCatalog = [
                struct('name','Aucun','description','Signal original','fn',@(sig,Fs) sig)
                struct('name','Robotize','description','Voix robotisée','fn',@(sig,Fs) Rob(sig,app.robotCarrier,Fs))
                struct('name','Chorus','description','Largeur stéréo','fn',@(sig,Fs) Chorus(sig,Fs,1,0.35,0.4))
                struct('name','Auto-wah','description','Filtre wah piloté','fn',@(sig,Fs) Auto_wah(sig,Fs,300,2000,0.15))
                struct('name','Tremolo','description','Modulation volume','fn',@(sig,Fs) Tremolo(sig,Fs,4,0.8))
                struct('name','Vibrato','description','Modulation pitch subtile','fn',@(sig,Fs) Vibrato(sig,Fs,6,0.003))
                struct('name','Flanger','description','Jet d''avion','fn',@(sig,Fs) Flanger(sig,Fs))
                struct('name','Phaser','description','Balayage de phase','fn',@(sig,Fs) Phaser(sig,Fs,0.5,0.8))
                struct('name','Bruit blanc','description','Ajout de bruit blanc','fn',@(sig,Fs) Bruit_blanc(sig,Fs))
                struct('name','Transforme vers ma voix','description','Approche timbre cible','fn',@(sig,Fs) Transforme_vers_ma_voix(sig,Fs,'Evil_laugh_elise.wav'))
                struct('name','Granularize','description','Texture granulaire','fn',@(sig,Fs) Granularize(sig,Fs))
                struct('name','Overdrive','description','Saturation douce','fn',@(sig,Fs) Overdrive(sig,Fs))
                struct('name','Distort hard','description','Distorsion dure','fn',@(sig,Fs) Distort_hard(sig,Fs))
                struct('name','Distort soft','description','Distorsion douce','fn',@(sig,Fs) Distort_soft(sig,Fs))
                struct('name','Stereo Move','description','Balayage gauche-droite','fn',@(sig,Fs) Stereo_mov(sig,Fs))
                struct('name','Bitcrusher','description','Bitcrusher','fn',@(sig,Fs) Bitcrusher(sig,6))
                struct('name','Wah-Wah','description','Filtre wah classique','fn',@(sig,Fs) Wah_wah(sig,Fs,1500,1800,700))
            ];
        end

        function initFileList(app)
            scriptDir = fileparts(mfilename('fullpath'));
            defaults = {'Extrait.wav','Diner.wav','Halleluia.wav'};
            entries = struct('label',{},'path',{});
            for k = 1:numel(defaults)
                candidate = fullfile(scriptDir, defaults{k});
                if exist(candidate,'file') == 2
                    entries(end+1) = struct('label',defaults{k},'path',candidate); %#ok<AGROW>
                end
            end
            app.fileEntries = entries;
            refreshFileList(app, 1);
        end

        function refreshFileList(app, selectedIdx)
            if nargin < 2
                selectedIdx = [];
            end
            if isempty(app.fileEntries)
                app.FileListBox.Items = {'<vide>'};
                app.FileListBox.ItemsData = 0;
                app.FileListBox.Value = 0;
                cla(app.WaveformAxes);
                cla(app.SpectrumAxes);
                app.currentSignal = [];
                app.currentFs = 0;
            else
                n = numel(app.fileEntries);
                if isempty(selectedIdx) || selectedIdx < 1 || selectedIdx > n
                    selectedIdx = 1;
                end
                labels = {app.fileEntries.label};
                app.FileListBox.Items = labels;
                app.FileListBox.ItemsData = 1:n;
                app.FileListBox.Value = app.FileListBox.ItemsData(selectedIdx);
                previewSelection(app);
            end
        end

        function previewSelection(app)
            if isempty(app.fileEntries) || app.FileListBox.Value == 0
                cla(app.WaveformAxes);
                cla(app.SpectrumAxes);
                app.currentSignal = [];
                app.currentFs = 0;
                return;
            end
            idx = app.FileListBox.Value;
            try
                [y, Fs] = audioread(app.fileEntries(idx).path);
                if size(y,2) > 1
                    y = mean(y,2);
                end
                app.currentSignal = y;
                app.currentFs = Fs;
                t = (0:numel(y)-1)/Fs;
                plot(app.WaveformAxes, t, y, 'Color',[0.3 0.9 0.8]);
                app.WaveformAxes.Title.String = sprintf('Waveform - %s', app.fileEntries(idx).label);
                Y = abs(fftshift(fft(y)));
                f = linspace(-Fs/2, Fs/2, numel(y));
                plot(app.SpectrumAxes, f/1000, Y, 'Color',[0.9 0.5 0.3]);
                app.SpectrumAxes.Title.String = 'Spectre (kHz)';
                app.StatusLabel.Text = sprintf('Charge %s', app.fileEntries(idx).label);
            catch ME
                app.StatusLabel.Text = sprintf('Erreur: %s', ME.message);
            end
        end

        function addFile(app)
            [file, path] = uigetfile('*.wav','Choisir un fichier audio');
            if isequal(file,0)
                return;
            end
            fullPath = fullfile(path,file);
            app.fileEntries(end+1) = struct('label',file,'path',fullPath);
            refreshFileList(app, numel(app.fileEntries));
        end

        function deleteSelected(app)
            if isempty(app.fileEntries) || app.FileListBox.Value == 0
                return;
            end
            idx = app.FileListBox.Value;
            app.fileEntries(idx) = [];
            if isempty(app.fileEntries)
                refreshFileList(app, []);
            else
                refreshFileList(app, min(idx, numel(app.fileEntries)));
            end
        end

        function deleteAll(app)
            app.fileEntries = struct('label',{},'path',{});
            refreshFileList(app, []);
        end

        function selectEffect(app, idx)
            app.selectedEffect = string(app.effectCatalog(idx).name);
            for k = 1:numel(app.effectButtons)
                if k == idx
                    app.effectButtons(k).BackgroundColor = [0.4 0.7 1];
                else
                    app.effectButtons(k).BackgroundColor = [0.2 0.2 0.2];
                end
            end
            app.StatusLabel.Text = sprintf('Effet selectionne : %s', app.selectedEffect);
        end

        function stopAudio(app, suppressStatus)
            if nargin < 2
                suppressStatus = false;
            end
            if ~isempty(app.player) && isa(app.player,'audioplayer')
                try
                    app.player.StopFcn = [];
                    stop(app.player);
                catch
                end
            end
            app.player = [];
            stopAnimation(app);
            stopLiveWaveform(app);
            resetLiveWaveform(app);
            app.playbackBuffer = [];
            app.playbackFs = 0;
            if ~suppressStatus
                app.StatusLabel.Text = 'Lecture stoppee';
            end
        end

        function handlePlay(app)
            fprintf('[MixeurDJApp] handlePlay invoked\n');
            if (isempty(app.currentSignal) || app.currentFs <= 0) && ...
                    ~isempty(app.fileEntries) && ~isempty(app.FileListBox.Value) && app.FileListBox.Value > 0
                previewSelection(app);
            end
            if isempty(app.currentSignal) || app.currentFs <= 0
                app.StatusLabel.Text = 'Chargez un extrait valide avant lecture';
                fprintf('[MixeurDJApp] abort: aucun signal charge\n');
                return;
            end
            try
                app.StatusLabel.Text = 'Preparation lecture...';
                drawnow limitrate;
                fprintf('[MixeurDJApp] arret de la lecture precedente\n');
                stopAudio(app, true);
                processed = processChain(app, app.currentSignal, app.currentFs);
                if isempty(processed)
                    app.StatusLabel.Text = 'Traitement vide, verifiez l''effet choisi';
                    fprintf('[MixeurDJApp] abort: traitement vide\n');
                    return;
                end
                if any(~isfinite(processed))
                    app.StatusLabel.Text = 'Traitement invalide (NaN/Inf)';
                    fprintf('[MixeurDJApp] abort: traitement NaN/Inf\n');
                    return;
                end
                processed = processed(:);
                app.playbackBuffer = processed;
                app.playbackFs = app.currentFs;
                fprintf('[MixeurDJApp] creation audioplayer (%d echantillons, Fs=%g)\n', numel(processed), app.currentFs);
                app.player = audioplayer(processed, app.currentFs);
                app.player.StopFcn = @(src,evt) onPlaybackFinished(app);
                fprintf('[MixeurDJApp] lancement animation et lecture\n');
                startAnimation(app);
                startLiveWaveform(app);
                play(app.player);
                fprintf('[MixeurDJApp] play() retourne sans erreur\n');
                app.StatusLabel.Text = sprintf('Lecture : %s + %s', app.fileEntries(app.FileListBox.Value).label, app.selectedEffect);
            catch ME
                stopAudio(app, true);
                app.StatusLabel.Text = sprintf('Erreur lecture : %s', ME.message);
                fprintf('MixeurDJApp playback error:\n%s\n', getReport(ME, 'extended', 'hyperlinks', 'off'));
            end
        end

        function onPlaybackFinished(app)
            stopAnimation(app);
            stopLiveWaveform(app);
            app.player = [];
            app.playbackBuffer = [];
            app.playbackFs = 0;
            resetLiveWaveform(app);
            if ~isempty(app.StatusLabel) && isvalid(app.StatusLabel)
                app.StatusLabel.Text = 'Lecture terminee';
            end
        end

        function startAnimation(app)
            if isempty(app.AnimationAxes) || ~isvalid(app.AnimationAxes)
                return;
            end
            if isempty(app.animationTimer) || ~isvalid(app.animationTimer)
                app.animationTimer = timer('ExecutionMode','fixedSpacing', ...
                    'Period',0.05, 'TimerFcn',@(~,~) updateAnimation(app));
            end
            if strcmp(app.animationTimer.Running,'off')
                start(app.animationTimer);
            end
        end

        function stopAnimation(app)
            if ~isempty(app.animationTimer) && isvalid(app.animationTimer) && strcmp(app.animationTimer.Running,'on')
                stop(app.animationTimer);
            end
            if isempty(app.AnimationAxes) || ~isvalid(app.AnimationAxes)
                return;
            end
            app.discAngle = 0;
            app.notePhase = 0;
            redrawAnimation(app, false);
        end

        function updateAnimation(app)
            redrawAnimation(app, true);
        end

        function redrawAnimation(app, advancePhase)
            if nargin < 2
                advancePhase = true;
            end
            if ~isvalid(app)
                return;
            end
            if isempty(app.AnimationAxes) || ~isvalid(app.AnimationAxes)
                return;
            end
            if advancePhase
                app.discAngle = mod(app.discAngle + 0.12, 2*pi);
                app.notePhase = app.notePhase + 0.15;
            end
            ax = app.AnimationAxes;
            cla(ax);
            hold(ax,'on');
            axis(ax,'off');
            th = linspace(0, 2*pi, 160);
            outerR = 0.85;
            fill(ax, outerR*cos(th), outerR*sin(th), [0.1 0.45 0.9], 'FaceAlpha',0.25, 'EdgeColor',[0.2 0.7 1], 'LineWidth',2);
            innerR = 0.25;
            fill(ax, innerR*cos(th), innerR*sin(th), [0.05 0.05 0.08], 'EdgeColor',[0.7 0.8 1], 'LineWidth',1.5);
            spokeAngles = app.discAngle + (0:2)*(2*pi/3);
            for ang = spokeAngles
                plot(ax, [0 outerR*cos(ang)], [0 outerR*sin(ang)], 'Color',[0.95 0.95 1], 'LineWidth',1.2);
            end
            plot(ax, 0.9*cos(app.discAngle), 0.9*sin(app.discAngle), '.', 'Color',[1 0.85 0.4], 'MarkerSize',18);
            noteOffsets = [0 0.8 1.6];
            for k = 1:numel(noteOffsets)
                phase = app.notePhase + noteOffsets(k);
                xCenter = 0.65 + 0.55*cos(0.85*phase);
                yCenter = 0.05 + 0.4*sin(phase);
                noteColor = [0.95 0.75 1];
                plot(ax, xCenter + 0.08*cos(th), yCenter + 0.08*sin(th), 'Color', noteColor, 'LineWidth',1.3);
                plot(ax, [xCenter+0.06 xCenter+0.06], [yCenter yCenter+0.25], 'Color', noteColor, 'LineWidth',1.3);
                plot(ax, xCenter+0.06, yCenter+0.25, 'o', 'Color', noteColor, 'MarkerSize',4, 'MarkerFaceColor', noteColor);
            end
            ax.XLim = [-1.4 1.4];
            ax.YLim = [-1.0 1.0];
            hold(ax,'off');
        end

        function startLiveWaveform(app)
            if isempty(app.LiveAxes) || ~isvalid(app.LiveAxes)
                return;
            end
            if isempty(app.playbackBuffer) || app.playbackFs <= 0
                return;
            end
            if isempty(app.liveTimer) || ~isvalid(app.liveTimer)
                app.liveTimer = timer('ExecutionMode','fixedSpacing', ...
                    'Period',0.05, 'TimerFcn',@(~,~) updateLiveWaveform(app));
            end
            if strcmp(app.liveTimer.Running,'off')
                start(app.liveTimer);
            end
        end

        function stopLiveWaveform(app, resetPlot)
            if nargin < 2
                resetPlot = true;
            end
            if ~isempty(app.liveTimer) && isvalid(app.liveTimer) && strcmp(app.liveTimer.Running,'on')
                stop(app.liveTimer);
            end
            if resetPlot
                resetLiveWaveform(app);
            end
        end

        function updateLiveWaveform(app, playerObj)
            if nargin < 2 || isempty(playerObj)
                playerObj = app.player;
            end
            if isempty(playerObj) || ~isa(playerObj,'audioplayer')
                return;
            end
            if isempty(app.playbackBuffer) || app.playbackFs <= 0
                return;
            end
            if isempty(app.LiveAxes) || ~isvalid(app.LiveAxes)
                return;
            end
            idx = playerObj.CurrentSample;
            if idx <= 0
                idx = 1;
            end
            numSamples = numel(app.playbackBuffer);
            winSamples = max(512, round(app.playbackFs * 0.4));
            startIdx = max(1, idx - winSamples + 1);
            stopIdx = min(numSamples, idx);
            window = app.playbackBuffer(startIdx:stopIdx);
            if isempty(window)
                return;
            end
            window = window ./ max(1e-6, max(abs(window))); % normalize for visibility
            t = ((startIdx:stopIdx) - idx) ./ app.playbackFs;
            ax = app.LiveAxes;
            cla(ax);
            hold(ax,'on');
            plot(ax, t, window, 'Color',[0.95 0.5 0.7], 'LineWidth',1.3);
            plot(ax, [-0.4 0], [0 0], 'Color',[0.5 0.5 0.6],'LineStyle','--');
            hold(ax,'off');
            ax.XLim = [-0.4 0];
            ax.YLim = [-1.1 1.1];
            ax.Title.String = 'Live waveform';
            ax.XLabel.String = 'Temps (s, retard)';
            ax.YLabel.String = 'Amplitude norm.';
            drawnow limitrate nocallbacks;
        end

        function resetLiveWaveform(app)
            if isempty(app.LiveAxes) || ~isvalid(app.LiveAxes)
                return;
            end
            ax = app.LiveAxes;
            cla(ax);
            ax.XLim = [-0.4 0];
            ax.YLim = [-1.1 1.1];
            ax.Title.String = 'Live waveform';
            ax.XLabel.String = 'Temps (s, retard)';
            ax.YLabel.String = 'Amplitude norm.';
            hold(ax,'on');
            plot(ax, [-0.4 0], [0 0], 'Color',[0.4 0.4 0.5],'LineStyle','--');
            hold(ax,'off');
        end

        function y = processChain(app, sig, Fs)
            y = sig;
            if abs(app.speedValue - 1) > 1e-3
                y = PVoc(y, app.speedValue, 1024, 1024);
            end
            if abs(app.pitchValue - 1) > 1e-3
                y = PVoc(y, app.pitchValue, 256, 256);
                y = localResampleApp(y, app.pitchValue, 1);
            end
            idx = find(strcmp({app.effectCatalog.name}, app.selectedEffect),1);
            if isempty(idx) || idx == 1
                return;
            end
            try
                y = app.effectCatalog(idx).fn(y, Fs);
            catch ME
                warning('Erreur effet %s : %s', app.selectedEffect, ME.message);
            end
        end

        function createEffectButtons(app)
            numEffects = numel(app.effectCatalog);
            cols = 3;
            rows = ceil(numEffects/cols);
            btnWidth = 120; btnHeight = 35;
            spacingX = 10; spacingY = 10;
            startX = 20; startY = rows*(btnHeight+spacingY);
            app.effectButtons = matlab.ui.control.Button.empty;
            for k = 1:numEffects
                row = floor((k-1)/cols);
                col = mod((k-1), cols);
                btn = uibutton(app.EffectPanel,'push');
                btn.Position = [startX + col*(btnWidth+spacingX), startY - row*(btnHeight+spacingY), btnWidth, btnHeight];
                btn.Text = app.effectCatalog(k).name;
                btn.BackgroundColor = [0.2 0.2 0.2];
                btn.FontColor = [0.95 0.95 0.95];
                btn.ButtonPushedFcn = @(src,evt) selectEffect(app, k);
                app.effectButtons(k) = btn;
            end
            selectEffect(app,1);
        end

        function createComponents(app)
            app.UIFigure = uifigure('Name','VOXCOD Mixdesk');
            app.UIFigure.Position = [100 100 1280 700];
            app.UIFigure.Color = [0.12 0.12 0.16];

            app.TitleLabel = uilabel(app.UIFigure,'Text','VOXCOD');
            app.TitleLabel.FontSize = 34;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.Position = [30 650 320 40];
            app.TitleLabel.FontColor = [0.85 0.85 0.95];

            app.FileListBoxLabel = uilabel(app.UIFigure,'Text','Bibliothèque d''extraits');
            app.FileListBoxLabel.FontWeight = 'bold';
            app.FileListBoxLabel.FontColor = [0.8 0.8 0.9];
            app.FileListBoxLabel.Position = [30 610 220 22];

            app.FileListBox = uilistbox(app.UIFigure);
            app.FileListBox.Position = [30 360 260 255];
            app.FileListBox.ValueChangedFcn = @(src,evt) previewSelection(app);

            app.AddFileButton = uibutton(app.UIFigure,'push','Text','Add wav file');
            app.AddFileButton.Position = [30 310 120 35];
            app.AddFileButton.ButtonPushedFcn = @(src,evt) addFile(app);

            app.DeleteFileButton = uibutton(app.UIFigure,'push','Text','Delete');
            app.DeleteFileButton.Position = [170 310 120 35];
            app.DeleteFileButton.ButtonPushedFcn = @(src,evt) deleteSelected(app);

            app.DeleteAllButton = uibutton(app.UIFigure,'push','Text','Delete all');
            app.DeleteAllButton.Position = [30 265 260 35];
            app.DeleteAllButton.ButtonPushedFcn = @(src,evt) deleteAll(app);

            app.PlayButton = uibutton(app.UIFigure,'push','Text','Play','BackgroundColor',[0.2 0.5 0.2],'FontColor',[1 1 1]);
            app.PlayButton.Position = [30 205 120 45];
            app.PlayButton.ButtonPushedFcn = @(src,evt) handlePlay(app);

            app.StopButton = uibutton(app.UIFigure,'push','Text','Stop','BackgroundColor',[0.6 0.2 0.2],'FontColor',[1 1 1]);
            app.StopButton.Position = [170 205 120 45];
            app.StopButton.ButtonPushedFcn = @(src,evt) stopAudio(app);

            speedPanel = uipanel(app.UIFigure,'Title','Set Speed','FontWeight','bold', ...
                'ForegroundColor',[0.85 0.85 0.95],'BackgroundColor',[0.16 0.16 0.2]);
            speedPanel.Position = [320 610 380 60];
            app.SpeedSlider = uislider(speedPanel,'Limits',[0.5 1.8],'Value',1);
            app.SpeedSlider.Position = [15 30 260 3];
            app.SpeedSlider.ValueChangedFcn = @(src,evt) updateSpeed(app, src.Value);
            app.SpeedValueLabel = uilabel(speedPanel,'Text','1.00x','FontWeight','bold','FontColor',[0.9 0.9 1]);
            app.SpeedValueLabel.Position = [290 18 70 22];

            pitchPanel = uipanel(app.UIFigure,'Title','Set Pitch','FontWeight','bold', ...
                'ForegroundColor',[0.85 0.85 0.95],'BackgroundColor',[0.16 0.16 0.2]);
            pitchPanel.Position = [320 545 380 60];
            app.PitchSlider = uislider(pitchPanel,'Limits',[0.5 1.8],'Value',1);
            app.PitchSlider.Position = [15 30 260 3];
            app.PitchSlider.ValueChangedFcn = @(src,evt) updatePitch(app, src.Value);
            app.PitchValueLabel = uilabel(pitchPanel,'Text','1.00x','FontWeight','bold','FontColor',[0.9 0.9 1]);
            app.PitchValueLabel.Position = [290 18 70 22];

            app.EffectPanel = uipanel(app.UIFigure,'Title','Launch an effect','FontSize',16);
            app.EffectPanel.Position = [720 320 520 360];
            app.EffectPanel.BackgroundColor = [0.18 0.18 0.24];
            app.EffectPanel.ForegroundColor = [0.85 0.85 1];

            app.WaveformAxes = uiaxes(app.UIFigure);
            app.WaveformAxes.Position = [330 360 360 170];
            app.WaveformAxes.Color = [0.05 0.05 0.08];
            app.WaveformAxes.XColor = [0.8 0.8 0.8];
            app.WaveformAxes.YColor = [0.8 0.8 0.8];

            app.SpectrumAxes = uiaxes(app.UIFigure);
            app.SpectrumAxes.Position = [330 60 360 190];
            app.SpectrumAxes.Color = [0.05 0.05 0.08];
            app.SpectrumAxes.XColor = [0.8 0.8 0.8];
            app.SpectrumAxes.YColor = [0.8 0.8 0.8];

            app.AnimationAxes = uiaxes(app.UIFigure);
            app.AnimationAxes.Position = [720 60 520 230];
            app.AnimationAxes.Color = [0.05 0.05 0.08];
            app.AnimationAxes.XColor = [0.8 0.8 0.8];
            app.AnimationAxes.YColor = [0.8 0.8 0.8];
            app.AnimationAxes.Visible = 'on';
            axis(app.AnimationAxes,'off');
            app.AnimationAxes.XLim = [-1.7 1.7];
            app.AnimationAxes.YLim = [-1.0 1.0];
            app.discAngle = 0;
            app.notePhase = 0;
            redrawAnimation(app, false);

            app.LiveAxes = uiaxes(app.UIFigure);
            app.LiveAxes.Position = [330 262 360 80];
            app.LiveAxes.Color = [0.05 0.05 0.08];
            app.LiveAxes.XColor = [0.8 0.8 0.8];
            app.LiveAxes.YColor = [0.8 0.8 0.8];
            resetLiveWaveform(app);

            app.StatusLabel = uilabel(app.UIFigure,'Text','Pret a mixer');
            app.StatusLabel.Position = [30 20 1210 24];
            app.StatusLabel.FontColor = [0.9 0.9 0.9];
        end

        function updateSpeed(app, value)
            app.speedValue = value;
            app.SpeedValueLabel.Text = sprintf('%.2fx', value);
            app.StatusLabel.Text = sprintf('Vitesse reglee sur %.2fx', value);
        end

        function updatePitch(app, value)
            app.pitchValue = value;
            app.PitchValueLabel.Text = sprintf('%.2fx', value);
            app.StatusLabel.Text = sprintf('Pitch regle sur %.2fx', value);
        end
    end

    methods (Access = public)

        function app = MixeurDJApp
            scriptDir = fileparts(mfilename('fullpath'));
            addpath(scriptDir);

            createComponents(app);
            initCatalog(app);
            createEffectButtons(app);
            initFileList(app);
        end

        function delete(app)
            stopAnimation(app);
            if ~isempty(app.animationTimer)
                if isvalid(app.animationTimer)
                    delete(app.animationTimer);
                end
                app.animationTimer = [];
            end
            stopLiveWaveform(app, false);
            if ~isempty(app.liveTimer)
                if isvalid(app.liveTimer)
                    delete(app.liveTimer);
                end
                app.liveTimer = [];
            end
        end
    end
end

function yout = localResampleApp(y, p, q)
    y = y(:);
    if isempty(y)
        yout = y;
        return;
    end
    if p <= 0 || q <= 0
        error('Facteurs de re-echantillonnage invalides.');
    end
    n = numel(y);
    tOriginal = 0:(n-1);
    nOut = max(1, floor((n-1)*p/q) + 1);
    tTarget = (0:(nOut-1)) * q / p;
    tTarget(end) = min(tTarget(end), tOriginal(end));
    yout = interp1(tOriginal, y, tTarget, 'linear');
    yout = yout(:);
end
