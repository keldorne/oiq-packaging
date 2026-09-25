# Packaging OIQ (Xavier Delerce - leblogaudiologie.com)

Empaquetage de l'app OIQ (R/Shiny + Python via reticulate) en installeurs
autonomes, sans prerequis sur la machine cible. Le code source de Xavier
(`upstream/`) n'est jamais modifie ; tout le packaging vit dans ce depot.

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
