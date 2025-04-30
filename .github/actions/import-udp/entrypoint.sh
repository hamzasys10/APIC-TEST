#!/bin/bash
set -e

CONFIG="$1"
PACKAGE_DIR="$2"
SERVER="api-manager-ui.apicv10dev.adib.co.ae"
GITHUB_WORKSPACE="$3"

echo "📖 Reading API config from: $CONFIG"
apis=$(yq eval '.apis | keys' "$CONFIG" | sed 's/- //g')



for api in $apis; do
  apiName=$(yq eval ".apis[\"$api\"].Name" "$CONFIG")
  org=$(yq eval ".apis[\"$api\"].ORG" "$CONFIG")
  cat=$(yq eval ".apis[\"$api\"].CAT" "$CONFIG")
  version=$(yq eval ".apis[\"$api\"].Version" "$CONFIG")
  deploy_status=$(yq eval ".apis[\"$api\"].Deploy" "$CONFIG")
  
  

 if [["$deploy_status"]]; then
  type="ExternalAPIs"
  [[ "$org" == *"adibint"* ]] && type="InternalAPIs"

  filesPath="$GITUB_WORKSPACE/$PACKAGE_DIR/APIs/$type/$apiName"
  udpDir="$filesPath/UDP"

  echo "📦 Looking for UDP policies for $apiName at: $udpDir"

  if [ ! -d "$udpDir" ]; then
    echo "⚠️  No UDP directory found — skipping $apiName"
    continue
  fi


  # for zip in "$udpDir"/*.zip; do
  #   [ -f "$zip" ] || continue
  #   udpName=$(basename "$zip" .zip)
  #  # cd $udpDir
  #   #source ~/.bash_profile > /dev/null 2>&1
    
  #   echo "📂 Unzipping $zip → $udpDir/$udpName"

  #  # unzip -o "$zip" -d "$udpDir/$udpName"
  # #  chmod -R 777 "$udpDir/$udpName"

  #  # cd "$udpDir/$udpName"

  #   echo "🚀 Publishing policy for $apiName"
  #   # /home/ucdadmin/apic-v10-5.2-sit/apic policies:publish \
  #   #   --server "$SERVER" \
  #   #   --organization "$org" \
  #   #   --catalog "$cat"
  # done
 fi
 done
