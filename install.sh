#!/bin/bash
set -euo pipefail

REPO="mnk400/rex"
INSTALL_DIR="/usr/local/bin"

# Get latest release tag
echo "Fetching latest version..."
TAG=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed 's/.*"tag_name": *"//;s/".*//')

if [[ -z "$TAG" ]]; then
    echo "Error: could not determine latest version"
    exit 1
fi

VERSION="${TAG#v}"
ARCHIVE_URL="https://github.com/$REPO/releases/download/$TAG/rex-$VERSION.tar.gz"

echo "Installing rex $VERSION..."

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$ARCHIVE_URL" -o "$TMP/rex.tar.gz"
tar -xzf "$TMP/rex.tar.gz" -C "$TMP"

# Install binary
if [[ -w "$INSTALL_DIR" ]]; then
    cp "$TMP/rex-$VERSION/bin/rex" "$INSTALL_DIR/rex"
    chmod +x "$INSTALL_DIR/rex"
else
    echo "Need sudo to install to $INSTALL_DIR"
    sudo cp "$TMP/rex-$VERSION/bin/rex" "$INSTALL_DIR/rex"
    sudo chmod +x "$INSTALL_DIR/rex"
fi

echo "Installed rex $VERSION to $INSTALL_DIR/rex"
