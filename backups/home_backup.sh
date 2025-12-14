#!/bin/bash

# Run timed rsync backups using rsnapshot, executed via cron

# Parameters
# --- $1 = Time schedule ('hourly' | 'daily' | 'weekly' | 'monthly')

USER=thomas
export HOME=/home/thomas
export XDG_RUNTIME_DIR=/run/user/1000
source /home/thomas/.env

SCHEDULE=$1
# SLACK_NOTIFIER="${HOME}/repos/utilities/slack_notifier.sh"
RCHAT_NOTIFIER="${HOME}/repos/utilities/rocketchat_notifier.sh"

if mountpoint -q /media/samsung-T3; then
	ERROR=$(sudo /usr/bin/rsnapshot -c /etc/rsnapshot.conf "$SCHEDULE" 2>&1)
	STATUS=$?
	if [ $STATUS -ne 0 ]; then
		$RCHAT_NOTIFIER "backups" "error" "${SCHEDULE} /home backup failed: ${ERROR}"
	else
		if [ $SCHEDULE != "hourly" ]; then
			$RCHAT_NOTIFIER "backups" "success" "${SCHEDULE} /home backup completed"
		fi
	fi
else
	$RCHAT_NOTIFIER "backups" "error" \
		"${SCHEDULE} /home backup failed: disk not mounted"
fi
