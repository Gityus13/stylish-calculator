#!/bin/bash
set -e
APP_NAME="StylishCalc"
BUNDLE="$APP_NAME.app"

echo "🔨 Compiling..."
swiftc CalcApp/AppDelegate.swift CalcApp/CalculatorView.swift \
  -o "$APP_NAME" \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macos12.0

echo "📦 Creating .app bundle..."
rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS"
mkdir -p "$BUNDLE/Contents/Resources"
cp "$APP_NAME" "$BUNDLE/Contents/MacOS/"
cp CalcApp/Info.plist "$BUNDLE/Contents/"

echo "💿 Creating DMG..."
hdiutil create -volname "$APP_NAME" \
  -srcfolder "$BUNDLE" \
  -ov -format UDZO \
  "$APP_NAME.dmg"

echo ""
echo "✅ Done! SHA256:"
shasum -a 256 "$APP_NAME.dmg"