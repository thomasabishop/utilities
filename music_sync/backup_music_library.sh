#!/bin/bash

RCHAT_NOTIFIER="${HOME}/repos/utilities/rocketchat_notifier.sh"
# SLACK_NOTIFIER="${HOME}/repos/utilities/slack_notifier.sh"
FILE_NAME=$(date +%Y-%m-%d_%H:%M:%S-%Z)
BAK=$(ls -dt "/media/crucial/music/"*"music_lib_bak"* | head -n 1)
TEMP="/media/crucial/music/temp"

# Create new backup via Rsync for existing between music ssd and existing bak
# file

sudo rsync -rtv --progress --delete --no-perms --exclude='.Trash*' /media/samsung-T7/ "$BAK"
STATUS=$?
if [ $STATUS -ne 0 ]; then
	$RCHAT_NOTIFIER "backups" "error" \
		"Failed to create music library backup:" "problem with rsync."
	exit
fi

# Rename the backup file with timestamp

mv "$BAK" "$TEMP"
STATUS_1=$?
mv "$TEMP" "/media/crucial/music/music_lib_bak-$FILE_NAME"
STATUS_2=$?
if [ $STATUS_1 -ne 0 ] || [ $STATUS_2 -ne 0 ]; then
	$RCHAT_NOTIFIER "backups" "error" \
		"Failed to create music library backup:" "problem copying backup." \
		exit
else
	$RCHAT_NOTIFIER "backups" "success" \
		"Created music library backup: /media/crucial/music/music_lib_bak-$FILE_NAME"
fi
