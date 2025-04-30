#!/bin/bash
set -e

CONFIG_FILE="$1"
BUILD_PATH="$2"

echo "🔍 Parsing YAML config: $CONFIG_FILE"
apis=$(yq eval '.apis | keys | .[]' "$CONFIG_FILE")

for api in $apis; do
  deploy=$(yq eval ".apis[\"$api\"].Deploy" "$CONFIG_FILE")
  if [[ "$deploy" != "true" ]]; then
    echo "⏭️ Skipping $api (Deploy=false)"
    continue
  fi

  apiName=$(yq eval ".apis[\"$api\"].Name" "$CONFIG_FILE")
  version=$(yq eval ".apis[\"$api\"].Version" "$CONFIG_FILE")
  org=$(yq eval ".apis[\"$api\"].ORG" "$CONFIG_FILE")

  # Determine path type
  if [[ "$org" == *"adibint"* ]]; then
    path="InternalAPIs"
  else
    path="ExternalAPIs"
  fi

  filesPath="$GITHUB_WORKSPACE/$BUILD_PATH/APIs/$path/$apiName"
  zipName="${apiName}_${version}.zip"
  zipPath="$GITHUB_WORKSPACE/$BUILD_PATH/APIs/$path/$zipName"

  echo "📁 Zipping: $filesPath → $zipPath"
  cd "$filesPath"
  zip -r "$zipPath" . > /dev/null

  echo "📦 Uploading to Artifactory..."

  if [[ "$path" == "ExternalAPIs" ]]; then
    curl -u "${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD}" -T "$zipPath" \
      "https://your-artifactory-server/artifactory/APIC/v10/External/${apiName}/${zipName}"
  else
    curl -u "${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD}" -T "$zipPath" \
      "https://your-artifactory-server/artifactory/APIC/v10/Internal/${apiName}/${zipName}"
  fi

  echo "✅ Uploaded and cleaning up"
  rm -f "$zipPath"
done
