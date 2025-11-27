function clips = get_demo_clips(scriptDir)
%GET_DEMO_CLIPS Retourne la liste des extraits audio disponibles.
%   clips = GET_DEMO_CLIPS() recherche les fichiers dans le dossier du
%   projet et génère automatiquement les extraits synthétiques si besoin.
%   Chaque élément de la structure retournée contient :
%       .label : nom lisible pour l'interface
%       .file  : nom de fichier
%       .path  : chemin absolu
%
%   Cette fonction est utilisée par Vocodeur.m et MixeurDJApp.m afin de
%   proposer une banque homogène de fichiers de test (voix + extraits
%   synthétiques générés par generate_extrait.m).

if nargin < 1 || isempty(scriptDir)
	scriptDir = fileparts(mfilename('fullpath'));
end

clipCatalog = {
	'Extrait.wav',               'Extrait.wav (parole fournie)';
	'Diner.wav',                 'Diner.wav (voix)';
	'Halleluia.wav',             'Halleluia.wav (chant)';
	'extrait_pop_melodie.wav',   'Pop melodie (synthe)';
	'extrait_basse_groove.wav',  'Basse groove';
	'extrait_accords_lents.wav', 'Accords lents pad';
	'extrait_chiptune.wav',      'Chiptune 8-bit';
	'extrait_beat_electro.wav',  'Beat electro';
	'extrait_jazz_bass.wav',     'Walking bass jazz';
	'extrait_classique_arpege.wav','Arpeges classiques';
	'extrait_ambient.wav',       'Ambient drone';
	'extrait_lofi_loop.wav',     'Boucle lofi';
	'extrait_percusions.wav',    'Percussions world';
	};

generatedNames = clipCatalog(4:end,1);
ensureSyntheticClips(scriptDir, generatedNames);

clips = struct('label',{},'file',{},'path',{});
for k = 1:size(clipCatalog,1)
	filename = clipCatalog{k,1};
	fullPath = fullfile(scriptDir, filename);
	if exist(fullPath,'file') == 2
		clips(end+1) = struct( ...
			'label', clipCatalog{k,2}, ...
			'file', filename, ...
			'path', fullPath); %#ok<AGROW>
	end
end

if isempty(clips)
	warning('Aucun fichier audio disponible dans %s.', scriptDir);
end
end

function ensureSyntheticClips(scriptDir, generatedNames)
if isempty(generatedNames)
	return;
end
missing = false;
for k = 1:numel(generatedNames)
	target = fullfile(scriptDir, generatedNames{k});
	if exist(target,'file') ~= 2
		missing = true;
		break;
	end
end
if ~missing
	return;
end

genFile = fullfile(scriptDir, 'generate_extrait.m');
if exist(genFile,'file') ~= 2
		warning('generate_extrait:missing','generate_extrait.m introuvable : impossible de generer les extraits.');
	return;
end

try
	generate_extrait(scriptDir);
catch ME
	warning('generate_extrait:failure','Failure while running generate\_extrait: %s', ME.message);
end
end
