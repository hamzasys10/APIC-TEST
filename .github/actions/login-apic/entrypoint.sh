#!/bin/bash
set -e


SERVER="$1"
USER="$2"
PASSWORD="$3"

echo "$SERVER"
counter=0
#while true; do
#  ((counter++))
  echo "Login attempt $counter..."
 # source ~/.bash_profile > /dev/null 2>&1
#	/home/ucdadmin/apic-v10-5.2-sit/apic client-creds:set /home/ucdadmin/apic-v10-5.2-sit/credentials-sit.json
#  if /home/ucdadmin/apic-v10-5.2-sit/apic login --server $SERVER --username $USER --password $PASSWORD --realm admin/api-sit-ldap; then
#    echo "✅ Login successful"
#    break
#  elif [[ $counter -ge 10 ]]; then
#    echo "❌ Login failed after 10 attempts"
#    exit 1
#  fi
#  sleep 2
#done
