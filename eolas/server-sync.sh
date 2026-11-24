#!/bin/bash
set -euo pipefail
SERVER="root@eolas.home.arpa"
EOLAS_DIR="/home/thomasabishop/eolas/"

## Upload image files to garage:
aws --profile garage s3 sync "${EOLAS_DIR}/img/" s3://eolas/

## Sync entries with server:
rsync -avz $EOLAS_DIR --exclude='README.md' "$SERVER":/root/entries/ && ssh "$SERVER" './regenerate.sh'
