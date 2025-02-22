#!/bin/bash

THIS_FILE=${0}
SLACK_NOTIFIER="${HOME}/repos/utilities/slack_notifier.sh"
FILE_NAME=$(date +%Y-%m-%d_%H:%M:%S-%Z)
BAK=$(ls -dt "/media/crucial/music/"*"music_lib_bak"* | head -n 1)
TEMP="/media/crucial/music/temp"

# Create new backup via Rsync for existing between music ssd and existing bak
# file

sudo rsync -rtv --progress --delete --no-perms --exclude='.Trash*' /media/samsung-T7/ "$BAK"
STATUS=$?
if [ $STATUS -ne 0 ]; then
	$SLACK_NOTIFIER "backups" "error" \
		"Error creating music library backup:" "problem with rsync." \
		"$THIS_FILE"
	exit
fi

# Rename the backup file with timestamp

mv "$BAK" "$TEMP"
STATUS_1=$?
mv "$TEMP" "/media/crucial/music/music_lib_bak-$FILE_NAME"
STATUS_2=$?
if [ $STATUS_1 -ne 0 ] || [ $STATUS_2 -ne 0 ]; then
	$SLACK_NOTIFIER "backups" "error" \
		"Error creating music library backup:" "problem copying backup." \
		"$THIS_FILE"
	exit
else
	$SLACK_NOTIFIER "backups" "success" \
		"Successfully created music library backup: /media/crucial/music/music_lib_bak-$FILE_NAME"
fi
