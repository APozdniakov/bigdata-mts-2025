#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")

USER=team
PASSWORD=$(cat "$SCRIPT_DIR"/.password)

HOSTS=(
    "192.168.1.95"
    "192.168.1.96"
    "192.168.1.97"
)

for HOST in "${HOSTS[@]}"; do
    ssh "$USER@$HOST" "bash -c 'echo $PASSWORD | sudo -S pkill -u hadoop'"
    ssh "$USER@$HOST" "bash -c 'echo $PASSWORD | sudo -S deluser --remove-home hadoop'"
done
