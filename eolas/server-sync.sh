#!/bin/bash
set -euo pipefail
SERVER="root@eolas.home.arpa"

rsync -avz --stats /home/thomasabishop/eolas/ "$SERVER":/root/data/ && ssh "$SERVER" './regenerate.sh'
