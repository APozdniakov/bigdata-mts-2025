#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$1
source "$SCRIPT_DIR/scripts/vars.sh"
SSH_KEY="/home/$(whoami)/.ssh/$HADOOP_USER"

ssh -i "$SSH_KEY" "$HADOOP_USER@$NN" "$HADOOP_HOME/bin/hdfs namenode -format -force"

ssh -i "$SSH_KEY" "$HADOOP_USER@$NN" "$HADOOP_HOME/bin/hdfs --daemon start namenode"
ssh -i "$SSH_KEY" "$HADOOP_USER@$SNN" "$HADOOP_HOME/bin/hdfs --daemon start secondarynamenode"

for HOST in "${HOSTS[@]}"; do
    ssh -i "$SSH_KEY" "$HADOOP_USER@$HOST" "$HADOOP_HOME/bin/hdfs --daemon start datanode"
done
