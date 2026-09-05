#!/usr/bin/env bash
# Use Xcode 26.5 (Xcode.app) instead of Xcode-26.4.0.app for Flutter/iOS builds.
# Run: source scripts/use_xcode_26_5.sh   OR   eval "$(./scripts/use_xcode_26_5.sh)"
set -euo pipefail

XCODE_26_5="/Applications/Xcode.app/Contents/Developer"
XCODE_26_4="/Applications/Xcode-26.4.0.app/Contents/Developer"

if [[ ! -d "$XCODE_26_5" ]]; then
  echo "Xcode 26.5 not found at /Applications/Xcode.app" >&2
  exit 1
fi

export DEVELOPER_DIR="$XCODE_26_5"
echo "DEVELOPER_DIR=$DEVELOPER_DIR"
xcodebuild -version

current="$(xcode-select -p 2>/dev/null || true)"
if [[ "$current" == "$XCODE_26_4" ]]; then
  echo ""
  echo "System xcode-select still points to Xcode 26.4."
  echo "To fix permanently (recommended), run:"
  echo "  sudo xcode-select -s $XCODE_26_5"
fi
