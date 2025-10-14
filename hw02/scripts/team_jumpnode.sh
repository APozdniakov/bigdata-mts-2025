#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$1
source "$SCRIPT_DIR/scripts/vars.sh"
SCRIPT_DIR=$1
SSH_KEY="/home/$(whoami)/.ssh/$USER"

ssh-keygen -q -N "" -f "$SSH_KEY"

for HOST in "${HOSTS[@]}"; do
    sshpass -p "$PASSWORD" ssh-copy-id -i "$SSH_KEY" "$USER@$HOST"

    scp -i "$SSH_KEY" "$SCRIPT_DIR/templates/hosts" "$USER@$HOST:/home/$USER/hosts"

    scp -i "$SSH_KEY" "$SCRIPT_DIR/scripts/team_nodes.sh" "$USER@$HOST:/home/$USER"
    ssh -i "$SSH_KEY" "$USER@$HOST" "/bin/bash team_nodes.sh $PASSWORD"
done
