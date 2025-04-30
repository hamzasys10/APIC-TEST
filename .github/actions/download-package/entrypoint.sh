#!/bin/bash
set -e

PRODUCT_PATH="$1"
FILE_NAME="$2"
TARGET_DIR="$3"
ARTIFACTORY_URL="${4:-https://jfrog.adib.co.ae/artifactory}"
REPO="${5:-APIC}"
USER="$6"
TOKEN="$7"

echo "📦 Downloading: $FILE_NAME from $PRODUCT_PATH"
echo "➡️ Artifactory URL: $ARTIFACTORY_URL"
echo "➡️ Repo: $REPO"
echo "➡️ Target: $TARGET_DIR"

# Build full URL
DOWNLOAD_URL="$ARTIFACTORY_URL/$REPO/$PRODUCT_PATH/$FILE_NAME"
echo "🌐 Download URL: $DOWNLOAD_URL"

# Make sure target directory exists
mkdir -p "$TARGET_DIR"

# Download using curl
curl -fSL -u "$USER:$TOKEN" "$DOWNLOAD_URL" -o "$TARGET_DIR/$FILE_NAME"

echo "✅ Downloaded to: $TARGET_DIR/$FILE_NAME"
