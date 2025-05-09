#!/bin/bash
set -e

CONFIG="$1"
BUILD_PATH="$2"
SERVER="api-manager-ui.apicv10dev.adib.co.ae"


echo "📖 Reading API config from: $CONFIG"

# apis=$(yq eval '.apis | keys' "$CONFIG" | sed 's/- //g')

getApiType() {
  [[ "$1" == *"adibint"* ]] && echo "InternalAPIs" || echo "ExternalAPIs"
}


generateProductMapFile(){

PRODUCT_LIST="$1"
PREVIOUS_API="$2"
DIR_PATH="$3"




URL=""  # will hold the substring after CUSTOM_KEY

# Iterate each line of PRODUCT_LIST
while IFS= read -r line; do

# Build the custom key: PREVIOUS_API + [state:published], then strip ALL whitespace
CUSTOM_KEY="${PREVIOUS_API}[state:published]"
CUSTOM_KEY="$(echo "$CUSTOM_KEY" | tr -d '[:space:]')"
  # Remove _all_ whitespace (spaces, tabs, etc.)
  clean_line="$(echo "$line" | tr -d '[:space:]')"

  # If the cleaned line contains our key, grab what comes _after_ it
  if [[ "$clean_line" == *"$CUSTOM_KEY"* ]]; then
    URL="${clean_line#*"$CUSTOM_KEY"}"
    break
  fi
done <<< "$PRODUCT_LIST"

echo "🔍 Found product URL: $URL"

# Normalize the YAML filename
# (remove any trailing slash on DIR_PATH, then append productsmap.yaml)
YAML_FILE="${DIR_PATH%/}/productsmap.yaml"

# Verify yq is available
if ! command -v yq &> /dev/null; then
  echo "❌ yq not found. Please install mikefarah yq v4+"
  exit 1
fi

# Update (or create) the .product_url field in your YAML
yq eval --inplace ".product_url = \"$URL\"" "$YAML_FILE"

echo "✅ Updated $YAML_FILE with product_url: $URL"

}


cat $CONFIG
ls
apis=$(yq eval '.apis | keys | .[]' "deployment-config/sit-deployment-config.yaml")
for api in $apis; do

  deploy=$(yq eval ".apis[\"$api\"].Deploy" "$CONFIG")
  if [[ "$deploy" != "true" ]]; then
    echo "⏭️ Skipping $api (Deploy=false)"
    continue
  fi
  name=$(yq eval ".apis[\"$api\"].Name" "$CONFIG")
  org=$(yq eval ".apis[\"$api\"].ORG" "$CONFIG")
  cat=$(yq eval ".apis[\"$api\"].CAT" "$CONFIG")
  version=$(yq eval ".apis[\"$api\"].Version" "$CONFIG")
  prevVersion=$(yq eval ".apis[\"$api\"].PreviousVersion" "$CONFIG")

  type=$(getApiType "$org")
  namever="${name}_${version}"
  filesPath="$GITHUB_WORKSPACE/$BUILD_PATH/APIs/$path/$apiName"
  productFile="$filesPath/$name.yaml"

  echo "📦 Publishing product: $productFile"

  if [[ ! -f "$productFile" ]]; then
    echo "⚠️ File not found: $productFile"
    continue
  fi
   
  # source ~/.bash_profile > /dev/null 2>&1
  # if /home/ucdadmin/apic-v10-5.2-sit/apic products:publish $productFile --server $SERVER --org $org --catalog $org --migrate_subscriptions; then
  #   echo "✅ Published $name"
  # else
  #   echo "❌ Failed to publish $name"
  # fi



  if [[ "$prevVersion" != "" ]]; then

      echo $prevVersion
      # PRODUCT_LIST=$(cd "$GITHUB_WORKSPACE/$BUILD_PATH/APIs/$path" \
      # && /home/ucdadmin/apic-v10-5.2-sit/apic products:list \
      #  --server "$SERVER" \
      #  --org "$org" \
      #  --catalog "$cat" \
      #  --scope catalog "$name"
      # )

  #  PRODUCT_LIST=$(echo "$PRODUCT_LIST" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  #  echo "Captured PRODUCT_LIST:"
  #  echo "$PRODUCT_LIST"

  #  generateProductMapFile "$PRODUCT_LIST"  "$name:$prevVersion"  "$GITHUB_WORKSPACE/$BUILD_PATH/deployment-config/"
   

  #  COMMAND_OUTPUT=$(
  # /home/ucdadmin/apic-v10-5.2-sit/apic products:replace \
  #   --server "$SERVER" \
  #   --org    "$org" \
  #   --catalog "$cat" \
  #   --scope  "catalog $name:$prevVersion" \
  #   "$GITHUB_WORKSPACE/$BUILD_PATH/deployment-config/productsmap.yaml"
  # )

  #   COMMAND_OUTPUT=$(echo "$COMMAND_OUTPUT" \
  # | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    echo "🚀 Replace output: $COMMAND_OUTPUT"
   

  fi
done




#Functions 
