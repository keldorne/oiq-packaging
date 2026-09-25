# Packaging OIQ (Xavier Delerce - leblogaudiologie.com)

Empaquetage de l'app OIQ (R/Shiny + Python via reticulate) en installeurs
autonomes, sans prerequis sur la machine cible. Le code source de Xavier
(`upstream/`) n'est jamais modifie ; tout le packaging vit dans ce depot.

Empaquetage realise par Kevin Perreaut ([@keldorne](https://github.com/keldorne)).

## A quoi sert OIQ

OIQ compare, a partir d'enregistrements audio, l'intelligibilite et la
qualite de la parole en sortie d'une aide auditive par rapport a une
reference normo-entendante, a travers plusieurs rapports signal/bruit
(RSB). Il calcule des indices objectifs (HASPI, HASQI, HAAQI, STOI, ESTOI,
SIIB, PESQ) qui previennent le besoin de tests perceptifs longs avec des
sujets humains.

Deux familles de metriques, a ne pas confondre :
- **HASPI / HASQI / HAAQI** integrent l'audiogramme choisi dans l'app : ce
  sont elles qui "simulent" la performance pour un profil auditif donne.
- **STOI / ESTOI / SIIB / PESQ** comparent uniquement les deux signaux
  (avant/apres l'aide), independamment de tout audiogramme : elles jugent
  la fidelite du traitement du signal par l'aide elle-meme.

### Exemple simplifie : comparer deux aides auditives

1. **Acquisition** : pour chaque aide (A et B), enregistrer un `.wav`
   stereo suivant le protocole OIQ (clap de synchro, puis parole seule,
   puis bruit seul a plusieurs RSB) - canal gauche = reference sans aide,
   canal droit = sortie de l'aide. Enregistrer une fois un `.wav` de
   calibration a 94 dB SPL.
2. **Dans l'app** : charger la calibration, puis le signal de l'aide A
   comme "Signal a analyser" (Condition 1), et le signal de l'aide B
   comme "2e signal a analyser" (Condition 2). Choisir l'audiogramme du
   patient simule (bibliotheque de profils ou saisie personnalisee).
3. **Lancer l'analyse** : cocher les metriques voulues (HASPI/HASQI/HAAQI
   sont lentes, ~1 min/RSB/coeur ; STOI/ESTOI/SIIB/PESQ sont quasi
   instantanees) et choisir le nombre de coeurs.
4. **Lire les resultats** : les courbes de la condition B se superposent
   en bleu sur celles de la condition A, RSB par RSB - la aide dont les
   courbes sont le plus haut (sur HASPI/STOI = intelligibilite,
   HASQI/HAAQI/PESQ = qualite) est objectivement la plus performante,
   pour l'audiogramme choisi et le bruit teste. Tableau + exports PNG/xlsx
   sont ecrits a cote du fichier signal analyse.

## Construction locale

```bash
# Linux -> OIQ-Linux-x64.run
bash ci/build-linux.sh

# Windows (PowerShell, avec micromamba + Inno Setup sur le PATH)
pwsh ci/build-windows.ps1
```

## CI

`.github/workflows/build.yml` reconstruit les deux installeurs sur des
runners GitHub heberges (`ubuntu-22.04` et `windows-latest`) a chaque tag
`v*` ou manuellement (`workflow_dispatch`). Une release GitHub en brouillon
est creee avec les deux artefacts - rien n'est publie publiquement sans
action manuelle supplementaire.

## Points d'architecture

- Le venv `oiq-py` (requis par `use_virtualenv("oiq-py", required=TRUE)`
  dans le code de Xavier) est cree au **premier lancement**, pas au
  packaging, car `conda-pack`/Inno Setup relocalisent l'environnement vers
  un chemin d'installation arbitraire.
- `R_BROWSER=xdg-open` est force par le lanceur Linux pour eviter un crash
  de `shiny::runApp(launch.browser=TRUE)` sur les systemes sans navigateur
  par defaut detectable.
- Les dependances CUDA/torch tirees par `pyclarity` sont retirees apres
  l'installation des paquets Python (non utilisees au runtime), ce qui
  ramene l'environnement de ~7.3 Go a ~2.2 Go.
