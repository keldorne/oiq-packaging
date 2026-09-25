#!/usr/bin/env bash
# Reproductible : construit OIQ-Linux-x64.run a partir de zero.
# Prerequis : micromamba installe et sur le PATH.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_URL="${UPSTREAM_URL:-https://leblogaudiologie.com/wp-content/uploads/2026/09/App_OIQ_R_parallel_diffusion.zip}"
ENVNAME="oiq"
BUILD="$ROOT/build"
STAGE="$BUILD/stage"

rm -rf "$BUILD"
mkdir -p "$BUILD" "$STAGE"

echo "== 1. Recuperation du code source de Xavier (jamais modifie) =="
if [ ! -d "$ROOT/upstream/App_OIQ_R_parallel" ]; then
  curl -sSL "$UPSTREAM_URL" -o "$ROOT/upstream.zip"
  mkdir -p "$ROOT/upstream"
  unzip -q -o "$ROOT/upstream.zip" -d "$ROOT/upstream"
fi
APP_SRC="$ROOT/upstream/App_OIQ_R_parallel"

echo "== 2. Creation de l'environnement conda (R + Python) =="
micromamba create -y -n "$ENVNAME" -f "$ROOT/environment.yml"

echo "== 3. Installation des paquets Python de Xavier (requirements.txt, non modifie) =="
micromamba run -n "$ENVNAME" pip install --no-input -r "$APP_SRC/requirements.txt"

echo "== 4. Suppression du bloat CUDA/torch non necessaire au runtime =="
micromamba run -n "$ENVNAME" pip uninstall -y \
  torch torchaudio triton pytorch-lightning torchmetrics \
  $(micromamba run -n "$ENVNAME" pip list --format=freeze | grep -o '^nvidia-[a-z0-9_-]*' || true) \
  2>/dev/null || true
micromamba run -n "$ENVNAME" python -c "import clarity, pystoi, pesq, pysiib, librosa, soundfile; print('imports OK sans torch')"

echo "== 5. Paquets R additionnels requis par app.R (CRAN, non fournis par conda-forge) =="
micromamba run -n "$ENVNAME" Rscript -e 'install.packages(c("tuneR","seewave"), repos="https://cloud.r-project.org")'

echo "== 6. conda-pack : relocalisation de l'environnement =="
micromamba run -n "$ENVNAME" conda-pack -n "$ENVNAME" -o "$BUILD/oiq-env.tar.gz" --ignore-missing-files --force
mkdir -p "$STAGE/env"
tar -xzf "$BUILD/oiq-env.tar.gz" -C "$STAGE/env"

echo "== 7. Copie de l'app de Xavier (verbatim) et du lanceur =="
mkdir -p "$STAGE/app"
cp -r "$APP_SRC/." "$STAGE/app/"
cp "$ROOT/launcher/oiq.sh" "$STAGE/oiq.sh"
chmod +x "$STAGE/oiq.sh"
cp "$ROOT/ci/install.sh" "$STAGE/install.sh"
chmod +x "$STAGE/install.sh"

echo "== 8. Empaquetage makeself =="
MAKESELF="$ROOT/tools/makeself-2.5.0/makeself.sh"
if [ ! -x "$MAKESELF" ]; then
  mkdir -p "$ROOT/tools"
  curl -sSL https://github.com/megastep/makeself/releases/download/release-2.5.0/makeself-2.5.0.run -o "$ROOT/tools/makeself.run"
  bash "$ROOT/tools/makeself.run" --target "$ROOT/tools/makeself-2.5.0" --nox11 --accept
fi
"$MAKESELF" --gzip "$STAGE" "$ROOT/OIQ-Linux-x64.run" "OIQ - Objective Intelligibility & Quality" ./install.sh

echo "== Termine : $ROOT/OIQ-Linux-x64.run =="
