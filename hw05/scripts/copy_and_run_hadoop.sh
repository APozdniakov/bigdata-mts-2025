#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")

# Подключаем переменные из vars.sh
source "$SCRIPT_DIR/vars.sh"

ssh-copy-id -i ~/.ssh/hadoop.pub hadoop@192.168.1.94

SRC_BASE="/home/team/hdfs"
SRC_SCRIPTS="$SRC_BASE/scripts"

HADOOP_HOME="/home/$HADOOP_USER"
HADOOP_SCRIPTS="$HADOOP_HOME/scripts"

HOST="192.168.1.94"
SSH_KEY="/home/$(whoami)/.ssh/$HADOOP_USER"

# mkdir -p "$HADOOP_SCRIPTS"

# Копируем файлы через scp
scp -i "$SSH_KEY" "$SCRIPT_DIR/run_spark_prefect.sh" "$HADOOP_USER@$HOST:$HADOOP_SCRIPTS"
scp -i "$SSH_KEY" "$SCRIPT_DIR/run_spark_prefect.py" "$HADOOP_USER@$HOST:$HADOOP_SCRIPTS"
scp -i "$SSH_KEY" "$SCRIPT_DIR/vars.sh" "$HADOOP_USER@$HOST:$HADOOP_SCRIPTS"
scp -i "$SSH_KEY" "$SRC_BASE/requirements.txt" "$HADOOP_USER@$HOST:$HADOOP_HOME"
scp -i "$SSH_KEY" "$SCRIPT_DIR/.password" "$HADOOP_USER@$HOST:$HADOOP_SCRIPTS"
scp -i "$SSH_KEY" "$SCRIPT_DIR/inventory.sh" "$HADOOP_USER@$HOST:$HADOOP_SCRIPTS"

# Запускаем скрипт от имени hadoop
sudo -i -u "$HADOOP_USER" bash << EOF
    source "$HADOOP_SCRIPTS/vars.sh"
    bash "$HADOOP_SCRIPTS/run_spark_prefect.sh"
EOF