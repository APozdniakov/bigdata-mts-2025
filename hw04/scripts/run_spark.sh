#!/usr/bin/env bash
set -eux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/vars.sh"
SSH_KEY="/home/$(whoami)/.ssh/$USER"
HADOOP_SSH_KEY="/home/$(whoami)/.ssh/$HADOOP_USER"

ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "$HIVE_HOME/bin/hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service metastore 1>> /tmp/hm.log 2>> /tmp/hm_e.log &"

python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
python3 run_spark.py
deacivate
