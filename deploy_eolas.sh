#!/bin/bash

source /home/thomas/.env

SOURCE="$(whoami)@$(hostname) ($(hostname -i | awk '{print $1}'))"
EOLAS_DIR="/home/thomas/repos/eolas"
EOLAS_DB_EXECUTABLE="/usr/local/bin/eolas-db/app"

function notify() {
	message=""
	if [ "$1" == 'error' ]; then
		message="🟥 $2"
	else
		message="🟩 $2"
	fi

	curl -s -u thomas:${NTFY_PASSWORD} \
		-H "Tags: $SOURCE" \
		-d "${message} " \
		https://ntfy.systemsobscure.net/eolas
}

echo "TB-INFO Running script deploy_eolas.sh"

cd "$EOLAS_DIR" || exit

${EOLAS_DIR}/scripts/upload_images_to_s3.sh

echo "TB-INFO Uploaded images to S3"

echo "TB-INFO Generating database"
sudo ${EOLAS_DB_EXECUTABLE} --source="${EOLAS_DIR}/zk" --target="/tmp"

db_size=$(stat --printf="%s" /tmp/eolas.db | awk '{printf "%.2f", $1/1000000}')

echo "TB-INFO Stopping eolas-api on VPS"

ssh -T -i /home/thomas/.ssh/deploy_self_host_server deploy@systemsobscure.net <<'EOF'
	sudo systemctl stop eolas-api.service
EOF

sudo scp -i /home/thomas/.ssh/deploy_self_host_server /tmp/eolas.db deploy@systemsobscure.net:/data/sqlite/eolas >/dev/null

echo "TB-INFO scp new database file to VPS"

ssh -T -i /home/thomas/.ssh/deploy_self_host_server deploy@systemsobscure.net <<'EOF'
	sudo systemctl start eolas-api.service
EOF

echo "TB-INFO Restarting eolas-api on VPS"

bucket_info=$(aws --profile garage --endpoint-url https://s3.systemsobscure.net s3 ls --summarize --human-readable s3://eolas/ | tail --lines=2 | tr -ds '\n' " ")

last_commit=$(cd "$EOLAS_DIR" && git rev-parse HEAD)
last_commit_trimmed=$(echo "$last_commit" | cut -b -6)

notify 'success' "eolas deployed at commit ${last_commit_trimmed}.
Database size: ${db_size}MB
Image bucket info: $bucket_info
https://forgejo.systemsobscure.net/thomasabishop/eolas/commit/${last_commit}
" >/dev/null
