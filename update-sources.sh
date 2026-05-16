#!/usr/bin/env bash
# Regeneriert cargo-sources.json und node-sources-frontend.json
# Ausführen nach jedem Release aus dem quark-Repo-Verzeichnis:
#   cd ../quark && ../de.quark.app/update-sources.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUARK_DIR="$(pwd)"

if [[ ! -f "$QUARK_DIR/src-tauri/Cargo.lock" ]]; then
  echo "Fehler: Muss aus dem quark-Repo-Verzeichnis aufgerufen werden." >&2
  exit 1
fi

pip3 install tomlkit flatpak-node-generator --break-system-packages -q

curl -sLo /tmp/flatpak-cargo-generator.py \
  'https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/master/cargo/flatpak-cargo-generator.py'

echo "=== Cargo-Sources generieren ==="
python3 /tmp/flatpak-cargo-generator.py \
  "$QUARK_DIR/src-tauri/Cargo.lock" \
  -o "$SCRIPT_DIR/cargo-sources.json"

echo "=== Node-Sources (frontend) generieren ==="
flatpak-node-generator npm \
  "$QUARK_DIR/src/frontend/package-lock.json" \
  -o "$SCRIPT_DIR/node-sources-frontend.json"

echo "Fertig. Bitte cargo-sources.json und node-sources-frontend.json committen."
