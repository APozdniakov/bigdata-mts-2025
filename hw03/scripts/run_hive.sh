#!/usr/bin/env bash
set -eux

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/vars.sh"
SSH_KEY="/home/$(whoami)/.ssh/$USER"
HADOOP_SSH_KEY="/home/$(whoami)/.ssh/$HADOOP_USER"

ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S apt install -y postgresql-16"

ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S -u postgres psql -c \"CREATE DATABASE metastore;\""
ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S -u postgres psql -c \"CREATE USER hive WITH PASSWORD 'hive';\""
ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;\""
ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S -u postgres psql -c \"ALTER DATABASE metastore OWNER TO hive;\""

scp -i "$SSH_KEY" "$SCRIPT_DIR/../templates/postgresql.conf" "$USER@$DN_01:/home/$USER"
ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S mv /home/$USER/postgresql.conf /etc/postgresql/16/main/postgresql.conf"
ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S chown postgres:postgres /etc/postgresql/16/main/postgresql.conf"

scp -i "$SSH_KEY" "$SCRIPT_DIR/../templates/pg_hba.conf" "$USER@$DN_01:/home/$USER"
ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S mv /home/$USER/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf"
ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S chown postgres:postgres /etc/postgresql/16/main/pg_hba.conf"

ssh -i "$SSH_KEY" "$USER@$DN_01" "echo $PASSWORD | sudo -S systemctl restart postgresql"

ssh -i "$SSH_KEY" "$USER@$NN" "echo $PASSWORD | sudo -S apt install -y postgresql-client-16"

if [ ! -f "$SCRIPT_DIR/../$HIVE_ARCHIVE" ]; then
    wget "$HIVE_URL"
else
    echo ">>> HIVE has been already installed"
fi

scp -i "$HADOOP_SSH_KEY" "$SCRIPT_DIR/../$HIVE_ARCHIVE" "$HADOOP_USER@$NN:/home/$HADOOP_USER"
ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "tar -zxf $HIVE_ARCHIVE"

if [ ! -f "$SCRIPT_DIR/../$PG_JDBC_JAR" ]; then
    wget "$PG_JDBC_URL"
else
    echo ">>> POSTGRES JDBC has been already installed"
fi

scp -i "$HADOOP_SSH_KEY" "$SCRIPT_DIR/../$PG_JDBC_JAR" "$HADOOP_USER@$NN:/home/$HADOOP_USER/$HIVE_DIR/bin/"
scp -i "$HADOOP_SSH_KEY" "$SCRIPT_DIR/../$PG_JDBC_JAR" "$HADOOP_USER@$NN:/home/$HADOOP_USER/$HIVE_DIR/lib/"

scp -i "$HADOOP_SSH_KEY" "$SCRIPT_DIR/../templates/hive-site.xml" "$HADOOP_USER@$NN:/home/$HADOOP_USER/$HIVE_DIR/conf/"
scp -i "$HADOOP_SSH_KEY" "$SCRIPT_DIR/../templates/hive-env.sh"   "$HADOOP_USER@$NN:/home/$HADOOP_USER/$HIVE_DIR/conf/"

ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "hdfs dfs -mkdir -p  /user/hive/warehouse"
ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "hdfs dfs -chmod g+w /user/hive/warehouse"

ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "hdfs dfs -mkdir -p  /tmp"
ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "hdfs dfs -chmod g+w /tmp"

ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "hdfs dfs -mkdir -p  /input"
ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "hdfs dfs -chmod g+w /input"

ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "/home/$HADOOP_USER/$HIVE_DIR/bin/schematool -dbType postgres -initSchema"
ssh -i "$HADOOP_SSH_KEY" "$HADOOP_USER@$NN" "/home/$HADOOP_USER/$HIVE_DIR/bin/hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service hiveserver2 1>> /tmp/hs2.log 2>> /tmp/hs2_e.log &"
