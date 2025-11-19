#!/usr/bin/env bash
set -eux

# Текущий каталог /home/hadoop/scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/vars.sh"

ssh -i "/home/hadoop/.ssh/$HADOOP_USER" "$HADOOP_USER@$NN" \
    "$HIVE_HOME/bin/hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service metastore \
     1>> /tmp/hm.log 2>> /tmp/hm_e.log &"

cd "$SCRIPT_DIR"

python3 -m venv .venv
source .venv/bin/activate

pip install -U pip
pip install -r "$HOME/requirements.txt"

python3 "$SCRIPT_DIR/run_spark_prefect.py"

deactivate
