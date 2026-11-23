#!/bin/bash
set -euo pipefail

#Stop the webserver for the app (systemctl)
systemctl stop eolas-app

# Stop the API server (systemctl)
systemctl stop eolas-api

# Regenerate the database

cd db
./eolas-db --source="../entries/" --target="."

systemctl start eolas-app
systemctl start eolas-api
