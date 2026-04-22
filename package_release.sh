#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="今日印钞.app"
VERSION="${1:-1.0.0}"
DIST_DIR="$ROOT_DIR/dist"
ZIP_NAME="today-money-printer-v${VERSION}-macos.zip"
APP_PATH="$ROOT_DIR/$APP_NAME"
ZIP_PATH="$DIST_DIR/$ZIP_NAME"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing app bundle: $APP_PATH"
  echo "Run ./build_app.sh first."
  exit 1
fi

mkdir -p "$DIST_DIR"
rm -f "$ZIP_PATH"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Release package created:"
echo "$ZIP_PATH"
