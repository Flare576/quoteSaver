#!/bin/bash

# Simple QuoteSaver Build Script (without Xcode)
# This script builds the QuoteSaver screensaver using only command line tools

set -e

echo "Building QuoteSaver screensaver (simple method)..."

# Create the bundle structure
BUNDLE_DIR="QuoteSaver.saver"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Creating bundle structure..."
rm -rf "$BUNDLE_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy Info.plist
cp Info.plist "$CONTENTS_DIR/"

# Compile Swift files
echo "Compiling Swift code..."
swiftc -emit-library -o "$MACOS_DIR/QuoteSaver" \
    -framework ScreenSaver \
    -framework Cocoa \
    -framework Foundation \
    -target x86_64-apple-macos10.15 \
    QuoteSaverView.swift ConfigureSheet.swift

if [ $? -eq 0 ]; then
    echo "Build complete! QuoteSaver.saver is ready for installation."
    echo ""
    echo "To install:"
    echo "1. Double-click QuoteSaver.saver to install"
    echo "2. Or copy it to ~/Library/Screen Savers/"
    echo "3. Then go to System Preferences > Desktop & Screen Saver > Screen Saver"
    echo "4. Select 'Quote Saver' from the list"
    echo "5. Click 'Screen Saver Options...' to configure the quote file path"
else
    echo "Build failed. You may need to install Xcode."
    exit 1
fi