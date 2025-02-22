#!/bin/bash

# Run timed rsync backups using rsnapshot, executed via cron

# Parameters
# --- $1 = Time schedule ('hourly' | 'daily' | 'weekly' | 'monthly')

#USER=thomas
#export XDG_RUNTIME_DIR=/run/user/1000
#source /home/thomas/.env

SCHEDULE=$1
THIS_FILE=${0}
SLACK_NOTIFIER="${HOME}/repos/utilities/slack_notifier.sh"

if mountpoint -q /media/samsung-T3; then
	ERROR=$(sudo /usr/bin/rsnapshot -c /etc/rsnapshot.conf hourly 2>&1)
	STATUS=$?
	if [ $STATUS -ne 0 ]; then
		$SLACK_NOTIFIER "backups" "error" "${SCHEDULE} /home backup failed" "$ERROR" "$THIS_FILE"
	else
		$SLACK_NOTIFIER "backups" "success" "${SCHEDULE} /home backup completed"
	fi
else
	$SLACK_NOTIFIER "backups" "error" \
		"${SCHEDULE} /home backup failed" "disk not mounted" \
		"$THIS_FILE"
fi
