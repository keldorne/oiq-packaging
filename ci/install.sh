#!/usr/bin/env bash
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${OIQ_INSTALL_DIR:-$HOME/.local/share/oiq}"

echo "== Installation OIQ dans $DEST =="
mkdir -p "$DEST"
cp -r "$HERE/env" "$DEST/"
cp -r "$HERE/app" "$DEST/"
cp "$HERE/oiq.sh" "$DEST/"
chmod +x "$DEST/oiq.sh"

echo "== Finalisation de l'environnement (conda-unpack) =="
"$DEST/env/bin/conda-unpack"

APPS_DIR="$HOME/.local/share/applications"
mkdir -p "$APPS_DIR"
cat > "$APPS_DIR/oiq.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=OIQ - Objective Intelligibility & Quality
Comment=App OIQ (Xavier Delerce - leblogaudiologie.com)
Exec=$DEST/oiq.sh
Icon=audio-x-generic
Terminal=false
Categories=Audio;Science;
EOF

echo ""
echo "Installation terminee."
echo "Lancer l'app : $DEST/oiq.sh"
echo "Un raccourci a ete ajoute au menu des applications."
