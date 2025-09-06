#!/bin/bash

# QuoteSaver Clear Install Script
# This script aggressively clears macOS screensaver caches and reinstalls

set -e

echo "🧹 Clearing macOS screensaver cache..."

# Kill any running screensaver processes (more comprehensive)
echo "  → Killing screensaver processes..."
killall "System Preferences" 2>/dev/null || true
killall "System Settings" 2>/dev/null || true
killall "ScreenSaverEngine" 2>/dev/null || true
killall "legacyScreenSaver" 2>/dev/null || true
killall "legacyScreenSaver-x86_64" 2>/dev/null || true

# Wait for processes to fully terminate
sleep 2

# Remove old installations from multiple locations
echo "  → Removing old screensaver installations..."
rm -rf ~/Library/Screen\ Savers/QuoteSaver.saver 2>/dev/null || true
rm -rf /Library/Screen\ Savers/QuoteSaver.saver 2>/dev/null || true

# Clear screensaver cache directories
echo "  → Clearing screensaver caches..."
rm -rf ~/Library/Caches/com.apple.screensaver* 2>/dev/null || true
rm -rf ~/Library/Caches/com.apple.ScreenSaver* 2>/dev/null || true

# Clear screensaver preferences/cache
echo "  → Clearing screensaver preferences..."
defaults delete com.apple.screensaver 2>/dev/null || true
defaults delete com.apple.ScreenSaver.Engine 2>/dev/null || true
defaults delete com.apple.screensaver.askForPassword 2>/dev/null || true

# Clear any QuoteSaver-specific preferences (all versions)
defaults delete com.opensource.QuoteSaver 2>/dev/null || true
for version in v2 v3 v4 v5 v6 v7 v8 v9; do
    defaults delete com.opensource.QuoteSaver.${version} 2>/dev/null || true
done

# Update bundle version to force macOS to see it as new
echo "  → Incrementing bundle version..."
CURRENT_VERSION=$(date +%s)
sed -i '' "s/com\.opensource\.QuoteSaver\.v[0-9]*/com.opensource.QuoteSaver.v${CURRENT_VERSION}/g" Info.plist

# Clear system font cache (sometimes helps with text rendering issues)
echo "  → Clearing font cache..."
atsutil databases -remove 2>/dev/null || true

echo "🔨 Rebuilding screensaver..."
./simple_build.sh

echo ""
echo "✅ Clear install complete!"
echo ""
echo "📋 Next steps:"
echo "1. Double-click QuoteSaver.saver to install"
echo "2. Open System Preferences → Desktop & Screen Saver"  
echo "3. Look for the newly installed screensaver (check the timestamp in bundle ID)"
echo "4. If still showing old content, try:"
echo "   - Close System Preferences completely and reopen"
echo "   - Log out and back in (faster than full restart)"
echo ""
echo "💡 Bundle ID: com.opensource.QuoteSaver.v${CURRENT_VERSION}"