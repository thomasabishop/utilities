#!/bin/bash

BLUE='\033[0;34m'
NO_COLOR='\033[0m'

echo -e "${BLUE}INFO Syncing music library to DAP SD card...${NO_COLOR}"
"${HOME}/repos/utilities/music_sync/transfer_to_DAP.sh"

sleep 3

echo -e "${BLUE}INFO Backing up music library to additional external drive...${NO_COLOR}"
"${HOME}/repos/utilities/music_sync/backup_music_library.sh"

# /home/thomas/repos/utilities/music_sync/backup_music_library.sh

echo -e "${BLUE}INFO Backup completed...${NO_COLOR}"
