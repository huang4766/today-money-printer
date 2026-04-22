#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_NAME="今日印钞"
EXECUTABLE_NAME="WageBar"
BUILD_DIR="$ROOT_DIR/.build/release"
APP_DIR="$ROOT_DIR/$BUNDLE_NAME.app"
EXECUTABLE="$BUILD_DIR/$EXECUTABLE_NAME"
MODULE_CACHE_DIR="$ROOT_DIR/.build/module-cache"
CLANG_CACHE_DIR="$ROOT_DIR/.build/clang-module-cache"

mkdir -p "$MODULE_CACHE_DIR" "$CLANG_CACHE_DIR"

env \
  SWIFTPM_MODULECACHE_OVERRIDE="$MODULE_CACHE_DIR" \
  CLANG_MODULE_CACHE_PATH="$CLANG_CACHE_DIR" \
  swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/$EXECUTABLE_NAME"
cp "$ROOT_DIR/Info.plist" "$APP_DIR/Contents/Info.plist"

echo "Built app bundle at: $APP_DIR"
