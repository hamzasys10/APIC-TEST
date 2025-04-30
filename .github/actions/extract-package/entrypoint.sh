#!/bin/bash
set -e

CONFIG="$1"
PACKAGE_DIR="$2"

echo "📦 Starting package extraction using: $CONFIG"

apis=$(yq eval '.apis | keys' "$CONFIG" | sed 's/- //g')

for api in $apis; do
  apiName=$(yq eval ".apis[\"$api\"].Name" "$CONFIG")
  org=$(yq eval ".apis[\"$api\"].ORG" "$CONFIG")
  version=$(yq eval ".apis[\"$api\"].Version" "$CONFIG")

  # Determine API type
  type="ExternalAPIs"
  [[ "$org" == *"adibint"* ]] && type="InternalAPIs"

  APIAndVersion="${apiName}_${version}"

  echo "📁 Extracting $apiName ($type) → $APIAndVersion"

  destDir="$PACKAGE_DIR/$type/$APIAndVersion"
  zipPath="$PACKAGE_DIR/$type/$apiName/$APIAndVersion"

  # Simulated downloadPackage logic (replace this with real download if needed)
  echo "⬇️  (Simulated) Downloading: $type/$apiName/$APIAndVersion → $PACKAGE_DIR/$type"
  mkdir -p "$PACKAGE_DIR/$type/$apiName"
  cp "$PACKAGE_DIR/samples/${APIAndVersion}.zip" "$PACKAGE_DIR/$type/$apiName/$APIAndVersion" 2>/dev/null || true

  # Unzip to destination
  if [ -f "$zipPath" ]; then
    echo "📂 Unzipping $zipPath → $destDir"
    mkdir -p "$destDir"
    unzip -o "$zipPath" -d "$destDir"
  else
    echo "❌ Package not found: $zipPath — skipping $apiName"
  fi
done
