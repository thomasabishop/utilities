#!/bin/bash
# Copy backups of databases on VPS to local machine

# Parameters
# --- $1 = Service name, e.g. "forgejo"
# --- $2 = Database location on VPS, e.g. "thomas@systemsobscure.net:/home/thomas/backups/forgejo/*.sql.gz"
# --- $3 = Backup location path on VPS, e.g. "/vps_backups/mysql/forgejo/"

source /home/thomas/.env

LOCAL_MOUNTPOINT="/media/my-passport"
RCHAT_NOTIFIER="${HOME}/repos/utilities/rocketchat_notifier.sh"

mountpoint -q ${LOCAL_MOUNTPOINT}

if [ $? -eq 1 ]; then
	$RCHAT_NOTIFIER "backups" "error" \
		"Could not transfer $1 DB backup from VPS. Local backup disk (/media/my-passport) not mounted."
	exit
fi

scp "thomas@systemsobscure.net:${2}" "${LOCAL_MOUNTPOINT}/${3}"

if [ $? -eq 0 ]; then
	BACKUP_FILE=$(ls -t "${LOCAL_MOUNTPOINT}/${3}" | head -1)
	$RCHAT_NOTIFIER "backups" "success" "Copied $1 DB backup from VPS. File: ${BACKUP_FILE}"
else
	$RCHAT_NOTIFIER "backups" "error" \
		"Could not transfer $1 DB backup from VPS."
fi
