#!/bin/bash

# Copy backup of Forgejo database on VPS to local device

LOCAL_MOUNTPOINT="/media/my-passport"
RCHAT_NOTIFIER="${HOME}/repos/utilities/rocketchat_notifier.sh"

mountpoint -q ${LOCAL_MOUNTPOINT}

if [ $? -eq 1 ]; then
	$RCHAT_NOTIFIER "backups" "error" \
		"Could not transfer Forgejo DB backup from VPS. Local backup disk (/media/my-passport) not mounted."
	exit
fi

scp 'thomas@systemsobscure.net:/home/thomas/backups/forgejo/*.sql.gz' "${LOCAL_MOUNTPOINT}/vps_backups/mysql/forgejo/"

if [ $? -eq 0 ]; then
	BACKUP_FILE=$(ls -t "${LOCAL_MOUNTPOINT}/vps_backups/mysql/forgejo" | head -1)
	$RCHAT_NOTIFIER "backups" "success" "Copied Forgejo DB backup from VPS. File: ${BACKUP_FILE}"
else
	$RCHAT_NOTIFIER "backups" "error" \
		"Could not transfer Forgejo DB backup from VPS."
fi
