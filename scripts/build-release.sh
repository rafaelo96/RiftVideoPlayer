#!/bin/bash
set -euo pipefail

# Rift Release Build Script
# Prerequisites:
#   - Xcode 15+ with Command Line Tools
#   - Apple Developer Program account ($99/year)
#   - Developer ID Application certificate in Keychain
#   - Developer ID Installer certificate in Keychain
#   - App-specific password for notarization saved in keychain:
#       xcrun notarytool store-credentials "RiftNotary" \
#         --apple-id "your@apple.id" \
#         --team-id "YOUR_TEAM_ID" \
#         --password "app-specific-password"

CONFIG="${1:-release}"
BUILD_DIR=".build"
PRODUCT="Rift"
APP_BUNDLE="$PRODUCT.app"
DMG_PATH="$PRODUCT.dmg"
GIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
VERSION="1.0.0-dev.$GIT_COUNT"

echo "=== Building $PRODUCT v$VERSION+$GIT_HASH ($CONFIG) ==="

# 1. Build
echo "--- Building ---"
swift build -c "$CONFIG"

# 2. Prepare app bundle
echo "--- Preparing bundle ---"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$CONFIG/$PRODUCT" "$APP_BUNDLE/Contents/MacOS/"
cp -R Sources/Rift/Resources/* "$APP_BUNDLE/Contents/Resources/" 2>/dev/null || true
cp -R "$BUILD_DIR/$CONFIG/${PRODUCT}_Rift.bundle" "$APP_BUNDLE/Contents/Resources/" 2>/dev/null || echo "Warning: ${PRODUCT}_Rift.bundle not found"
cp Sources/Rift/Info.plist "$APP_BUNDLE/Contents/"
plutil -replace CFBundleShortVersionString -string "$VERSION" "$APP_BUNDLE/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$GIT_COUNT" "$APP_BUNDLE/Contents/Info.plist"

# 3. Sign (requires Apple Developer Program)
if [ "${SKIP_SIGN:-false}" != "true" ]; then
    TEAM_ID="${APPLE_TEAM_ID:-}"
    if [ -z "$TEAM_ID" ]; then
        echo "Warning: APPLE_TEAM_ID not set. Skipping code signing."
    else
        echo "--- Signing ---"
        codesign --force --options runtime \
            --sign "Developer ID Application: $TEAM_ID" \
            --deep "$APP_BUNDLE"
    fi
fi

# 4. Create DMG
echo "--- Creating DMG ---"
mkdir -p "$(dirname "$APP_BUNDLE")"
hdiutil create -volname "$PRODUCT" -srcfolder "$APP_BUNDLE" \
    -ov -format UDZO "$DMG_PATH"

# 5. Notarize (requires Apple Developer Program)
if [ "${SKIP_NOTARIZE:-false}" != "true" ]; then
    NOTARY_PROFILE="${NOTARY_PROFILE:-RiftNotary}"
    echo "--- Notarizing ---"
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait --timeout 30m

    echo "--- Stapling ---"
    xcrun stapler staple "$DMG_PATH"
fi

echo "=== Done: $PRODUCT v$VERSION+$GIT_HASH ==="
