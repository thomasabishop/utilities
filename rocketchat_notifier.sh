#!/bin/bash

# Send error and success notifications to Rocket Chat channels

# Env vars:
# ---	Webhook URLs for given channel, eg $RC_WEBHOOK_TEST
# --- sourced from `.env` file in Zsh path

# Parameters:
# --- $1 = Channel,
# --- $2 = type 'error' | 'success'
# --- $3 = Message

# Usage:
# --- ./rocketchat_notifier.sh test 'success' 'Message goes here.'
# --- ./rocketcaht_notifier.sh test 'error' 'Message goes here.'

declare -A CHANNEL_TO_WEBHOOK
CHANNEL_TO_WEBHOOK["test"]=$RC_WEBHOOK_TEST
CHANNEL_TO_WEBHOOK["backups"]=$RC_WEBHOOK_BACKUPS
CHANNEL_TO_WEBHOOK["time_tracking"]=$RC_WEBHOOK_TIME_TRACKING

#CHANNEL_TO_WEBHOOK["eolas"]=$SLACK_WEBHOOK_EOLAS
#CHANNEL_TO_WEBHOOK["website"]=$SLACK_WEBHOOK_SYSTEMS_OBSCURE

WEBHOOK=${CHANNEL_TO_WEBHOOK[$1]}

if [ "$2" != "error" ]; then
	curl -X POST \
		-H 'Content-type: application/json' \
		--data "{\"text\":\"INFO \", \"attachments\": [{\"color\": \"#008000\", \"text\": \"$3\"}]}" \
		"$WEBHOOK" >/dev/null 2>&1
else
	curl -X POST \
		-H 'Content-type: application/json' \
		--data "{\"text\":\"ERROR \", \"attachments\": [{\"color\": \"#FF0000\", \"text\": \"$3\"}]}" \
		"$WEBHOOK"
fi
