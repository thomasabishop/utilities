#!/bin/bash

# Backup Hetzner Storagebox (Alpha) used by VPS for service data.

NAS_DEVICE_NAME="Hetzner Storagebox (Alpha)"
RCHAT_NOTIFIER="${HOME}/repos/utilities/rocketchat_notifier.sh"
SOURCE_MOUNTPOINT="/media/hetzner-storagebox-alpha"
LOCAL_MOUNTPOINT="/media/my-passport"

function clean_up() {
	# Dismount NAS
	echo "INFO Dismounting ${NAS_DEVICE_NAME}."
	sudo umount /media/hetzner-storagebox-alpha/

	# Turn on VPN
	echo "INFO Re-connecting Mullvad VPN."
	mullvad connect
	exit
}

# Turn off VPN
echo "INFO Attempting backup of ${NAS_DEVICE_NAME} NAS device."
echo "INFO Checking VPN status."

mullvad status | grep "Disconnected" 2>&1
STATUS=$?
if [ $STATUS -eq 0 ]; then
	echo "INFO VPN is not connected. Proceeding."
else
	echo "INFO Mullvad VPN is connected. Disconnecting."
	mullvad disconnect
fi

# Check source disk is mounted
if mountpoint -q ${LOCAL_MOUNTPOINT}; then
	echo "INFO Local disk /media/my-passport mounted. Proceeding."
else
	echo "INFO Local disk not mounted. Mounting /media/my-passport."
	sudo mount ${LOCAL_MOUNTPOINT}
	if mountpoint -q ${LOCAL_MOUNTPOINT}; then
		echo "INFO Mounted /media/my-passport"
	else
		$RCHAT_NOTIFIER "backups" "error" \
			"Could not complete scheduled backup of ${NAS_DEVICE_NAME}. Local backup disk (/media/my-passport) not mounted."
		clean_up
	fi
fi

# Mount NAS locally
sudo mount -t cifs -v //u455282.your-storagebox.de/backup /media/hetzner-storagebox-alpha -o \
	credentials=/etc/hetzner-storagebox-alpha-credentials,uid=1000,gid=1000,file_mode=0775,dir_mode=0775,vers=3.0

if mountpoint -q ${SOURCE_MOUNTPOINT}; then
	echo "INFO Mounted ${NAS_DEVICE_NAME} device to /media/hetzner-storagebox-alpha"
else
	$RCHAT_NOTIFIER "backups" "error" \
		"Could not complete scheduled ${NAS_DEVICE_NAME} backup. Source disk (/media/hetzner-storagebox-alpha) not mounted."
	clean_up
fi

# Create backup (ignoring lock files)

echo "INFO Beginning backup."

sudo rsync -avzP --delete --no-perms \
	--exclude="*.lock" \
	--exclude="*.bleve/store/root.bolt" \
	--exclude="mongo/db/mongod.lock" \
	"$SOURCE_MOUNTPOINT/" "$LOCAL_MOUNTPOINT/vps_backups/hetzner_storagebox_alpha"

STATUS=$?
if [ $STATUS -eq 0 ]; then
	$RCHAT_NOTIFIER "backups" "success" \
		"Created backup of ${NAS_DEVICE_NAME}."
	# 23 = partial backup, 24 = some vanished files, both != major failure
elif [ $STATUS -eq 23 ] || [ $STATUS -eq 24 ]; then
	$RCHAT_NOTIFIER "backups" "success" \
		"Created backup of ${NAS_DEVICE_NAME}. A few files could not be copied."
else
	$RCHAT_NOTIFIER "backups" "error" \
		"Failed to create backup of ${NAS_DEVICE_NAME}: problem with rsync (exit code $STATUS)."
fi

clean_up
