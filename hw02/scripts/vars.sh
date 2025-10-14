#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")

USER=team
PASSWORD=$(cat "$SCRIPT_DIR"/.password)
HADOOP_USER=hadoop

HADOOP_VERSION="3.4.0"
HADOOP_ARCHIVE=hadoop-$HADOOP_VERSION.tar.gz
HADOOP_URL="https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/$HADOOP_ARCHIVE"
HADOOP_INSTALL_DIR="/home/$HADOOP_USER"
HADOOP_HOME="$HADOOP_INSTALL_DIR/hadoop-$HADOOP_VERSION"

source "$SCRIPT_DIR/inventory.sh"
