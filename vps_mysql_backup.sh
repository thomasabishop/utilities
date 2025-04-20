#!/bin/bash

# Backup MYSQL dir on VPS

RCHAT_NOTIFIER="${HOME}/repos/utilities/rocketchat_notifier.sh"

TARGET_NAME="VPS: /data/mysql"
LOCAL_DISK_MOUNTPOINT="/media/my-passport"
LOCAL_DIR="${LOCAL_DISK_MOUNTPOINT}/vps_backups/mysql"

# function clean_up() {
# 	# Dismount NAS
# 	echo "INFO Dismounting ${NAS_DEVICE_NAME}."
# 	sudo umount /media/hetzner-storagebox-alpha/

# 	# Turn on VPN
# 	echo "INFO Re-connecting Mullvad VPN."
# 	mullvad connect
# 	exit
# }

# Check source disk is mounted
if mountpoint -q ${LOCAL_DISK_MOUNTPOINT}; then
	echo "INFO Local disk /media/my-passport mounted. Proceeding."
else
	echo "INFO Local disk not mounted. Mounting /media/my-passport."
	sudo mount ${LOCAL_DISK_MOUNTPOINT}
	if mountpoint -q ${LOCAL_MOUNTPOINT}; then
		echo "INFO Mounted /media/my-passport"
	else
		$RCHAT_NOTIFIER "backups" "error" \
			"Could not complete scheduled backup of ${TARGET_NAME}. Local backup disk (/media/my-passport) not mounted."
		clean_up
	fi
fi

rsync -avzP --delete \
	thomas@systemsobcure.net:/data/mysql "${LOCAL_DIR}"

STATUS=$?
if [ $STATUS -eq 0 ]; then
	$RCHAT_NOTIFIER "backups" "success" \
		"Created backup of ${TARGET_NAME}."
	# 23 = partial backup, 24 = some vanished files, both != major failure
elif [ $STATUS -eq 23 ] || [ $STATUS -eq 24 ]; then
	$RCHAT_NOTIFIER "backups" "success" \
		"Created backup of ${TARGET_NAME}. A few files could not be copied."
else
	$RCHAT_NOTIFIER "backups" "error" \
		"Failed to create backup of ${TARGET_NAME}: problem with rsync (exit code $STATUS)."
fi
