#!/bin/bash

set -euo pipefail

# Generate executable of eolas-api service

API_DIR="${HOME}/repos/eolas-api"

cd $API_DIR
npm run build
cd

ssh root@eolas.home.arpa 'systemctl stop eolas-api.service'
scp "${API_DIR}/dist/eolas-api" root@eolas.home.arpa:/root/api/
ssh root@eolas.home.arpa 'systemctl start eolas-api.service'
