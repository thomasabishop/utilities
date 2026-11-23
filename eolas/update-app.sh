#!/bin/bash
set -euo pipefail

APP_DIR="${HOME}/repos/eolas-app"
SERVER="root@eolas.home.arpa"

cd "$APP_DIR"
npm run build

ssh "$SERVER" 'rm -rf /root/app/* && mkdir -p /root/app'
scp -r "$APP_DIR"/dist/. "$SERVER":/root/app/

ssh "$SERVER" 'systemctl restart eolas-app.service'
