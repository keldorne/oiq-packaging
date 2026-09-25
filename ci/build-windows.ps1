# Reproductible : construit OIQ-Windows-x64-setup.exe a partir de zero.
# Prerequis : micromamba et Inno Setup (iscc.exe) sur le PATH (installes par le workflow CI).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$UpstreamUrl = if ($env:UPSTREAM_URL) { $env:UPSTREAM_URL } else { "https://leblogaudiologie.com/wp-content/uploads/2026/09/App_OIQ_R_parallel_diffusion.zip" }
$EnvName = "oiq"
$Build = Join-Path $Root "build"
$Stage = Join-Path $Build "stage"

Remove-Item -Recurse -Force $Build -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $Stage | Out-Null

Write-Host "== 1. Recuperation du code source de Xavier (jamais modifie) =="
$AppSrc = Join-Path $Root "upstream\App_OIQ_R_parallel"
if (-not (Test-Path $AppSrc)) {
    Invoke-WebRequest -Uri $UpstreamUrl -OutFile (Join-Path $Root "upstream.zip")
    Expand-Archive -Path (Join-Path $Root "upstream.zip") -DestinationPath (Join-Path $Root "upstream") -Force
}

Write-Host "== 2. Creation de l'environnement conda (R + Python) =="
micromamba env remove -y -n $EnvName 2>$null
micromamba create -y -n $EnvName -f (Join-Path $Root "environment-windows.yml")

Write-Host "== 3. Installation des paquets Python de Xavier (requirements.txt, non modifie) =="
micromamba run -n $EnvName pip install --no-input -r (Join-Path $AppSrc "requirements.txt")

Write-Host "== 3bis. Correctif Windows : le trio numpy 2.4.6/numba 0.65.1/llvmlite 0.47.0 de Xavier (valide sur sa machine Linux) est casse sur win_amd64 -- 'numba.np.types' absent du wheel Windows de numba 0.65.1, et son propre llvmlite 0.47.0 appelle une fonction depreciee. Retour a un trio numpy/numba/llvmlite mutuellement compatible et valide sur Windows, sans toucher a requirements.txt (upstream) =="
micromamba run -n $EnvName pip install --no-input "numpy==2.2.6" "numba==0.61.2" "llvmlite==0.44.0"

Write-Host "== 4. Suppression du bloat CUDA/torch non necessaire au runtime =="
$nvidiaPkgs = (micromamba run -n $EnvName pip list --format=freeze) | Select-String '^nvidia-' | ForEach-Object { ($_ -split '==')[0] }
micromamba run -n $EnvName pip uninstall -y torch torchaudio triton pytorch-lightning torchmetrics @nvidiaPkgs 2>$null
micromamba run -n $EnvName python -c "import clarity.evaluator.haspi.eb, pystoi, pesq, pysiib, librosa, soundfile; print('imports OK sans torch (y compris le chemin haspi.eb qui charge numba)')"

Write-Host "== 5. Paquets R additionnels requis par app.R (CRAN, non fournis par conda-forge) =="
micromamba run -n $EnvName Rscript -e 'install.packages(c("tuneR","seewave"), repos="https://cloud.r-project.org")'

Write-Host "== 6. conda-pack : relocalisation de l'environnement =="
$EnvPrefix = (micromamba run -n $EnvName python -c "import sys; print(sys.prefix)").Trim()
micromamba run -n $EnvName conda-pack -p $EnvPrefix -o (Join-Path $Build "oiq-env.zip") --format zip --ignore-missing-files --force
Expand-Archive -Path (Join-Path $Build "oiq-env.zip") -DestinationPath (Join-Path $Stage "env") -Force

Write-Host "== 7. Copie de l'app de Xavier (verbatim) et du lanceur =="
New-Item -ItemType Directory -Force -Path (Join-Path $Stage "app") | Out-Null
Copy-Item -Recurse -Force "$AppSrc\*" (Join-Path $Stage "app")
Copy-Item -Force (Join-Path $Root "launcher\oiq.bat") (Join-Path $Stage "oiq.bat")

Write-Host "== 8. Empaquetage Inno Setup =="
$env:OIQ_STAGE_DIR = $Stage
iscc (Join-Path $Root "installer\windows\oiq.iss")

Write-Host "== Termine : $Root\OIQ-Windows-x64-setup.exe =="
