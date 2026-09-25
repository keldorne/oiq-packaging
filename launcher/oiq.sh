#!/usr/bin/env bash
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
export RETICULATE_VIRTUALENV_ROOT="$HERE/venvroot"
export NUMBA_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oiq/numba"
export R_BROWSER="${R_BROWSER:-xdg-open}"
mkdir -p "$NUMBA_CACHE_DIR" "$RETICULATE_VIRTUALENV_ROOT"

if [ ! -x "$RETICULATE_VIRTUALENV_ROOT/oiq-py/bin/python" ]; then
  echo "[OIQ] Premier lancement : creation de l'environnement Python 'oiq-py'..."
  "$HERE/env/bin/python" -m venv --system-site-packages "$RETICULATE_VIRTUALENV_ROOT/oiq-py"
fi

cd "$HERE/app"
exec "$HERE/env/bin/Rscript" -e "shiny::runApp('app.R', launch.browser=TRUE)"
