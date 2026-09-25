@echo off
setlocal
set "HERE=%~dp0"
set "RETICULATE_VIRTUALENV_ROOT=%HERE%venvroot"
set "NUMBA_CACHE_DIR=%LOCALAPPDATA%\oiq\numba"
if not exist "%NUMBA_CACHE_DIR%" mkdir "%NUMBA_CACHE_DIR%"
if not exist "%RETICULATE_VIRTUALENV_ROOT%" mkdir "%RETICULATE_VIRTUALENV_ROOT%"

if not exist "%RETICULATE_VIRTUALENV_ROOT%\oiq-py\Scripts\python.exe" (
  echo [OIQ] Premier lancement : creation de l'environnement Python 'oiq-py'...
  "%HERE%env\python.exe" -m venv --system-site-packages "%RETICULATE_VIRTUALENV_ROOT%\oiq-py"
)

cd /d "%HERE%app"
"%HERE%env\Scripts\Rscript.exe" -e "shiny::runApp('app.R', launch.browser=TRUE)"
