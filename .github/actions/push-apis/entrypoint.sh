#!/bin/bash
set -e

CONFIG_FILE="$1"
BUILD_PATH="$2"
SERVER="api-manager-ui.apicv10dev.adib.co.ae"

echo "📦 Pushing APIs based on: $CONFIG_FILE"

apis=$(yq eval '.apis | keys' "$CONFIG_FILE" | sed 's/- //g')

getApiType() {
  local org="$1"
  if [[ "$org" == *"adibint"* ]]; then
    echo "InternalAPIs"
  else
    echo "ExternalAPIs"
  fi
}


pushApis() {
  local filesPath="$1"
  local org="$2"
  local result=true
  local version="$3"

  echo "📁 Scanning folder: $filesPath"
  if [ ! -d "$filesPath" ]; then
    echo "⚠️ Folder not found: $filesPath"
    return 0
  fi

  for file in "$filesPath"/*.yaml; do
    [[ "$file" == *"catalogProperties"* ]] && continue

    source ~/.bash_profile > /dev/null 2>&1
    cd $filesPath
    echo "🚀 Pushing: $(basename "$file")"
    if /home/ucdadmin/apic-v10-5.2-sit/apic draft-products:create $file --server $SERVER --org $org; then
      echo "✅ Pushed: $file"
     
    else
      echo "❌ >>>Create production for $file failed"
      source ~/.bash_profile > /dev/null 2>&1
      cd $filesPath 
      /home/ucdadmin/apic-v10-5.2-sit/apic draft-products:update --server $SERVER --org $org $apiName:$version $file
      result=false
    fi
  done

  $result || return 1
}

for api in $apis; do
  apiName=$(yq eval ".apis[\"$api\"].Name" "$CONFIG_FILE")
  org=$(yq eval ".apis[\"$api\"].ORG" "$CONFIG_FILE")
  version=$(yq eval ".apis[\"$api\"].Version" "$CONFIG_FILE")

  type=$(getApiType "$org")
  apiAndVersion="${apiName}_${version}"
  filesPath=$GITHUB_WORKSPACE/$BUILD_PATH/APIs/$type/$apiName
  echo $filesPath
  deploy=$(yq eval ".apis[\"$api\"].Deploy" "$CONFIG_FILE")
  if [[ "$deploy" != "true" ]]; then
    echo "⏭️ Skipping $api (Deploy=false)"
    continue
  fi
  echo "📄 Processing: $apiName (type=$type)"
  # if ! pushApis "$filesPath" "$org" "$version"; then
  #   echo "❌ Error: push failed for $apiName"
  # fi
done
