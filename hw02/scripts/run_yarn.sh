#!/usr/bin/env bash
set -eux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/vars.sh"
SSH_KEY="/home/$(whoami)/.ssh/$HADOOP_USER"

scp -i "$SSH_KEY" "$SCRIPT_DIR/../templates/yarn-site.xml" "hadoop@$NN:$HADOOP_HOME/etc/hadoop/"
scp -i "$SSH_KEY" "$SCRIPT_DIR/../templates/mapred-site.xml" "hadoop@$NN:$HADOOP_HOME/etc/hadoop/"

ssh -i "$SSH_KEY" "hadoop@$NN" "/home/hadoop/hadoop-3.4.0/bin/hdfs dfs -mkdir -p /mr_history/done /mr_history/tmp 2>/dev/null || true && /home/hadoop/hadoop-3.4.0/bin/hdfs dfs -chmod -R 777 /mr_history"


# Запускаем RM на NameNode
ssh -i "$SSH_KEY" "hadoop@$NN" "$HADOOP_HOME/bin/yarn --daemon start resourcemanager"

# Запускаем NM на всех узлах
echo $SCRIPT_DIR 
for HOST in "192.168.1.95" "192.168.1.96" "192.168.1.97"; do
    scp -i "$SSH_KEY" "$SCRIPT_DIR/../templates/yarn-site.xml" "hadoop@$HOST:$HADOOP_HOME/etc/hadoop/"
    scp -i "$SSH_KEY" "$SCRIPT_DIR/../templates/mapred-site.xml" "hadoop@$HOST:$HADOOP_HOME/etc/hadoop/"
    ssh -i "$SSH_KEY" "hadoop@$HOST" "$HADOOP_HOME/bin/yarn --daemon start nodemanager"
done

ssh -i "$SSH_KEY" "hadoop@$NN" "$HADOOP_HOME/bin/mapred --daemon start historyserver"

