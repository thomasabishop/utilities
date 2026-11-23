#!/bin/bash

# Generate executable of eolas-db service

set -euo pipefail

cd ${HOME}/repos/eolas-db
source venv/bin/activate
pyinstaller --onefile --paths src --name="eolas-db" --distpath /tmp src/app.py

# Transfer to eolas.home.arpa

scp "/tmp/eolas-db" root@eolas.home.arpa:/root/db/
