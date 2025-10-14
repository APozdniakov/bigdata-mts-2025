#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$1
source "$SCRIPT_DIR/scripts/vars.sh"

SSH_KEY="/home/$(whoami)/.ssh/$HADOOP_USER"

ssh -i "$SSH_KEY" "hadoop@$NN" "$HADOOP_HOME/bin/mapred --daemon stop historyserver" || true

ssh -i "$SSH_KEY" "hadoop@$NN" "$HADOOP_HOME/bin/yarn --daemon stop resourcemanager" || true

for HOST in "192.168.1.95" "192.168.1.96" "192.168.1.97"; do
    echo "Stopping NodeManager on $HOST..."
    ssh -i "$SSH_KEY" "hadoop@$HOST" "$HADOOP_HOME/bin/yarn --daemon stop nodemanager" || true
done

