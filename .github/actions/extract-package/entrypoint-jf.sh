#!/bin/bash
set -e

CONFIG="$1"
PACKAGE_DIR="$2"
ARTIFACTORY_REPO="apic-packages-uat"  # Replace with your real JFrog repo
ARTIFACTORY_REMOTE_PATH="APIC"        # Root folder in JFrog
JFROG_SERVER_ID="jfrog-preprod"       # Match your Jenkins pipeline

echo "📦 Starting package extraction using: $CONFIG"

# Download logic
downloadPackage() {
  local group="$1"         # Internal/paymentapi
  local filename="$2"      # paymentapi_1.0.0
  local localPath="$3"     # packageUniqueDir/...

  local remote="$ARTIFACTORY_REMOTE_PATH/$group/$filename"
  local destination="$localPath/$group"

  echo "⬇️  Downloading from JFrog: $remote → $destination"

  mkdir -p "$destination"

  # Real JFrog download (uncomment this when JFrog CLI is configured)
  jfrog rt dl "$remote" "$destination/" \
    --server-id="$JFROG_SERVER_ID" \
    --flat=true || {
      echo "❌ JFrog download failed for $remote"
      return 1
    }

  return 0
}

# Loop over APIs
apis=$(yq eval '.apis | keys' "$CONFIG" | sed 's/- //g')

for api in $apis; do
  apiName=$(yq eval ".apis[\"$api\"].Name" "$CONFIG")
  org=$(yq eval ".apis[\"$api\"].ORG" "$CONFIG")
  version=$(yq eval ".apis[\"$api\"].Version" "$CONFIG")

  type="ExternalAPIs"
  [[ "$org" == *"adibint"* ]] && type="InternalAPIs"

  APIAndVersion="${apiName}_${version}"
  group="$type/$apiName"
  destDir="$PACKAGE_DIR/$type/$APIAndVersion"
  zipPath="$PACKAGE_DIR/$group/$APIAndVersion"

  echo "📁 Handling $apiName ($type) → $APIAndVersion"

  # Attempt real download
  if ! downloadPackage "$group" "$APIAndVersion" "$PACKAGE_DIR"; then
    echo "⚠️ Falling back to sample zip for $apiName"
    mkdir -p "$PACKAGE_DIR/$group"
    cp "$PACKAGE_DIR/samples/${APIAndVersion}.zip" "$PACKAGE_DIR/$group/$APIAndVersion" || {
      echo "❌ No fallback package found — skipping $apiName"
      continue
    }
  fi

  # Unzip to destination
  if [ -f "$zipPath" ]; then
    echo "📂 Unzipping $zipPath → $destDir"
    mkdir -p "$destDir"
    unzip -o "$zipPath" -d "$destDir"
  else
    echo "❌ Package not found: $zipPath — skipping $apiName"
  fi
done
