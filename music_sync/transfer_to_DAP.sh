#!/bin/bash

SOURCE_DIR="/media/samsung-T7"
DEST_DIR="/media/dap"

# Ensure directories exist
if [ ! -d "$SOURCE_DIR" ]; then
	echo "ERROR: Source directory does not exist"
	exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
	echo "ERROR: Destination directory does not exist"
	exit 1
fi

# Sanitise track file names

cd ${SOURCE_DIR} || exit
sudo detox -r ${SOURCE_DIR}

# Transfer to DAP
sudo rsync -rtv --progress --delete --no-perms --exclude='.Trash*' "$SOURCE_DIR/" "$DEST_DIR/"
