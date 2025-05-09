#!/bin/bash
set -e


SERVER="$1"

echo "Logging out from server: $SERVER"
#/home/ucdadmin/apic-v10-5.2-sit/apic logout --server $SERVER