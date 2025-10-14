#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$1
source "$SCRIPT_DIR/scripts/vars.sh"
SCRIPT_DIR=$1
SSH_KEY="/home/$(whoami)/.ssh/$HADOOP_USER"

wget "$HADOOP_URL"

ssh-keygen -q -N "" -f "$SSH_KEY"

for HOST in "${HOSTS[@]}"; do
    sshpass -p "$PASSWORD" ssh-copy-id -i "/home/$(whoami)/.ssh/$HADOOP_USER" "$HADOOP_USER@$HOST"

    scp -i "$SSH_KEY" "$SCRIPT_DIR/$HADOOP_ARCHIVE" "$HADOOP_USER@$HOST:/home/$HADOOP_USER"

    scp -i "$SSH_KEY" "$SCRIPT_DIR/scripts/hadoop_nodes.sh" "$HADOOP_USER@$HOST:/home/$HADOOP_USER"
    ssh -i "$SSH_KEY" "$HADOOP_USER@$HOST" "/bin/bash hadoop_nodes.sh $PASSWORD"

    scp -i "$SSH_KEY" "$SCRIPT_DIR/templates/hdfs-site.xml" "$HADOOP_USER@$HOST:$HADOOP_HOME/etc/hadoop/"
    scp -i "$SSH_KEY" "$SCRIPT_DIR/templates/core-site.xml" "$HADOOP_USER@$HOST:$HADOOP_HOME/etc/hadoop/"
    scp -i "$SSH_KEY" "$SCRIPT_DIR/templates/hadoop-env.sh" "$HADOOP_USER@$HOST:$HADOOP_HOME/etc/hadoop/hadoop-env.sh"
done
