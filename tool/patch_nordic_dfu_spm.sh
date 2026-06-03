#!/usr/bin/env bash
# nordic_dfu 7.1.2: SPM product must reference package "IOS-DFU-Library", not "NordicDFU".
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OLD='.product(name: "NordicDFU", package: "NordicDFU")'
NEW='.product(name: "NordicDFU", package: "IOS-DFU-Library")'
patched=0

patch_file() {
  local f="$1"
  if [[ ! -f "$f" ]] || ! grep -qF "$OLD" "$f"; then
    return 0
  fi
  sed -i '' "s|$OLD|$NEW|g" "$f"
  echo "Patched: $f"
  patched=$((patched + 1))
}

# Ephemeral symlinks (after flutter pub get)
while IFS= read -r -d '' link; do
  if [[ -L "$link" ]]; then
    real="$(readlink -f "$link" 2>/dev/null || readlink "$link")"
    patch_file "$real/Package.swift"
  fi
  patch_file "$link/Package.swift"
done < <(find "$ROOT/ios/Flutter/ephemeral/Packages/.packages" -name 'nordic_dfu-*' -print0 2>/dev/null)

# Pub cache (source of symlink targets)
if command -v flutter >/dev/null 2>&1; then
  cache="$(cd "$ROOT" && flutter pub cache path 2>/dev/null || true)"
  if [[ -n "$cache" ]]; then
    for f in "$cache"/hosted/pub.dev/nordic_dfu-*/darwin/nordic_dfu/Package.swift; do
      [[ -f "$f" ]] && patch_file "$f"
    done
  fi
fi

if [[ "$patched" -eq 0 ]]; then
  echo "nordic_dfu Package.swift already patched or not found."
else
  echo "Patched $patched nordic_dfu Package.swift file(s)."
fi
