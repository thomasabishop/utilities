#!/bin/bash

# Send error and success notifications to Slack channels and play sound

# Env vars:
# ---	Webhook URLs for given channel, eg $SLACK_WEBHOOK_TEST, $SLACK_WEBHOOK_EOLAS
# --- sourced from `.env` file in Zsh path

# Parameters:
# --- $1 = Slack channel,
# --- $2 = type 'error' | 'success'
# --- $3 = Message
# --- $4 = (Opt) Error details
# --- $5 = (Opt) Error source

# Usage:
# --- ./slack_notifier.sh test 'SUCCESS: ...'
# --- ./slack_notifier.sh test 'ERROR: ... ' 'Error details' 'source'

declare -A CHANNEL_TO_WEBHOOK
CHANNEL_TO_WEBHOOK["test"]=$SLACK_WEBHOOK_TEST
CHANNEL_TO_WEBHOOK["backups"]=$SLACK_WEBHOOK_BACKUPS
CHANNEL_TO_WEBHOOK["eolas"]=$SLACK_WEBHOOK_EOLAS
CHANNEL_TO_WEBHOOK["website"]=$SLACK_WEBHOOK_SYSTEMS_OBSCURE
CHANNEL_TO_WEBHOOK["time-tracking"]=$SLACK_WEBHOOK_TIME_TRACKING

WEBHOOK=${CHANNEL_TO_WEBHOOK[$1]}

ERROR_BLOCKS=$(
	jq -n \
		--arg channel "$1" \
		--arg message "$3" \
		--arg details "$4" \
		--arg source "$5" \
		'{
			channel: $channel,
			blocks: ([
			{
				type: "section",
					text: {
						type: "plain_text",
						text: "🔴 \($message)" 
					}
				},
				{
					type: "section",
					text: {
						type: "mrkdwn",
						text: "```\n\($details)\n```"
					}
				},
				{
					"type": "context",
					"elements": [
						{
							"type": "plain_text",
							text: $source
						}
					]
				}
			])
	}'
)

# Initialise sound playback

mpv --volume=0 --start=0 --length=0.1 "${HOME}/dotfiles/sounds/star-trek-computer-success.mp3" \
	>/dev/null 2>&1
sleep 1

# Process notification
if [ "$2" != "error" ]; then
	curl -X POST \
		-H 'Content-type: application/json' \
		--data '{"text":"🟢 '"$3"'"}' \
		"$WEBHOOK"
	mpv --volume=100 "${HOME}/dotfiles/sounds/star-trek-computer-success.mp3" \
		>/dev/null 2>&1

else
	curl -X POST \
		-H 'Content-type: application/json' \
		--json "$ERROR_BLOCKS" \
		"$WEBHOOK"
	mpv --volume=100 "${HOME}/dotfiles/sounds/star-trek-computer-error.mp3" \
		>/dev/null 2>&1
fi
