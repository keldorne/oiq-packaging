# Test manuel de l'installeur Windows OIQ

Ce dossier guide une session Claude Code lancee **sur une machine Windows**
pour valider l'installeur `.exe` produit par le portage OIQ. Le code source
de Xavier (`upstream/`) n'est jamais modifie ; ce test ne fait que verifier
que le packaging fonctionne sur une vraie machine Windows.

## Contexte

Le depot https://github.com/keldorne/oiq-packaging contient :
- `ci/build-windows.ps1` + `installer/windows/oiq.iss` : script de build
  Windows (conda env + Inno Setup), jamais execute sur une vraie machine
  Windows avant ce test (seulement construit/pense depuis Linux).
- `.github/workflows/build.yml` : la meme chose tourne aussi automatiquement
  sur un runner GitHub `windows-latest` a chaque declenchement.
- `launcher/oiq.bat` : lanceur Windows, equivalent de `launcher/oiq.sh` deja
  valide sous Linux (meme logique : creation du venv Python `oiq-py` au
  premier lancement, car l'environnement est relocalise par Inno Setup).

## Objectif de ce test

Verifier que l'installeur Windows fonctionne reellement, sans prerequis
(pas de R/Python preinstalles) : c'est la contrainte du projet.

## Etape 1 — Recuperer l'installeur

Deux options, prendre la plus simple selon ce qui est disponible :

**Option A (recommandee) : telecharger l'artefact construit par la CI**
```powershell
gh run list --repo keldorne/oiq-packaging --workflow=build.yml --limit 5
gh run download <run-id> --repo keldorne/oiq-packaging -n OIQ-Windows-x64-setup
```

**Option B : construire localement**
Prerequis : micromamba (https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)
et Inno Setup (`choco install innosetup` ou https://jrsoftware.org/isdl.php)
installes et sur le PATH.
```powershell
git clone https://github.com/keldorne/oiq-packaging.git
cd oiq-packaging
pwsh ci\build-windows.ps1
```
Ca produit `OIQ-Windows-x64-setup.exe` a la racine du depot.

## Etape 2 — Installer en conditions reelles

1. Double-clic sur `OIQ-Windows-x64-setup.exe`
2. **Noter** si Windows SmartScreen affiche un avertissement (attendu, car
   pas de signature de code — cf. contrainte projet). Verifier qu'on peut
   quand meme continuer via "Informations complementaires" -> "Executer
   quand meme".
3. Suivre l'assistant (installation par defaut dans `%LOCALAPPDATA%\OIQ`,
   pas besoin de droits administrateur — `PrivilegesRequired=lowest`).
4. Verifier la creation du raccourci menu Demarrer / Bureau.

## Etape 3 — Premier lancement

1. Lancer via le raccourci (ou `%LOCALAPPDATA%\OIQ\oiq.bat`).
2. **Attendu** : un message "[OIQ] Premier lancement : creation de
   l'environnement Python 'oiq-py'..." doit apparaitre brievement (une
   seule fois), PUIS l'app Shiny doit s'ouvrir dans le navigateur par
   defaut.
3. Si ca plante avant l'ouverture du navigateur : noter le message
   d'erreur exact (fenetre console R). Le point sensible connu (deja
   corrige cote Linux) est un eventuel crash sur
   `shiny::runApp(launch.browser=TRUE)` si aucun navigateur par defaut
   n'est detectable — sous Windows ca ne devrait normalement pas arriver
   (contrairement a un Linux minimal), mais a verifier.

## Etape 4 — Test fonctionnel minimal

Utiliser les fichiers d'exemple embarques dans l'app
(`app\engine\Version_Claude\R\a.wav`, `b.wav`, `d.wav` une fois installe,
ou depuis le depot `upstream/App_OIQ_R_parallel/engine/Version_Claude/R/`)
pour verifier qu'un calcul de metrique aboutit sans erreur (ex: STOI/ESTOI,
rapides). Pas besoin de faire une analyse complete 12 RSB pour ce test —
juste confirmer que R + Python + reticulate communiquent bien.

## Etape 5 — Desinstallation propre

Verifier via "Applications installees" (panneau de configuration Windows)
que la desinstallation supprime bien `%LOCALAPPDATA%\OIQ` (voir
`[UninstallDelete]` dans `oiq.iss`) et les raccourcis.

## Rendre compte

A la fin, resumer dans le fil de conversation (pas besoin de fichier a
part) :
- Chaque etape : OK / KO avec le message d'erreur exact si KO
- Capture d'ecran de l'avertissement SmartScreen si present
- Toute anomalie par rapport au comportement attendu decrit ci-dessus

Si un correctif est necessaire dans `ci/build-windows.ps1`,
`installer/windows/oiq.iss` ou `launcher/oiq.bat` : le faire, committer,
pousser sur une branche (pas directement sur `master` sans validation),
et ouvrir une Pull Request decrivant le probleme observe et le correctif.
Ne jamais modifier `upstream/` (code de Xavier).
