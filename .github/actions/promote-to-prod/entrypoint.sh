#!/bin/bash
set -e

CONFIG="$1"
PACKAGE_DIR="$2"
USER="$3"
TOKEN="$4"
ARTIFACTORY_URL="$5"
REPO="$6"
SHOULD_IT_PASS="$7"

[[ "$SHOULD_IT_PASS" == "false" ]] && {
  echo "❌ shouldITPass is false — aborting promotion."
  exit 1
}

echo "✅ shouldITPass is true — starting promotion..."

apis=$(yq eval '.apis | keys' "$CONFIG" | sed 's/- //g')

getApiType() {
  [[ "$1" == *"adibint"* ]] && echo "InternalAPIs" || echo "ExternalAPIs"
}

for api in $apis; do
  name=$(yq eval ".apis[\"$api\"].Name" "$CONFIG")
  org=$(yq eval ".apis[\"$api\"].ORG" "$CONFIG")
  version=$(yq eval ".apis[\"$api\"].Version" "$CONFIG")

  type=$(getApiType "$org")
  namever="${name}_${version}"
  localFile="$PACKAGE_DIR/$type/$namever.zip"
  remotePath="$type/$name/$namever.zip"
  uploadUrl="$ARTIFACTORY_URL/$REPO/$remotePath"

  if [[ ! -f "$localFile" ]]; then
    echo "⚠️ Skipping, not found: $localFile"
    continue
  fi

  echo "🚀 Uploading $localFile to $uploadUrl"
  curl -fSL -u "$USER:$TOKEN" -T "$localFile" "$uploadUrl"
  echo "✅ Promotion done for $namever"
done
