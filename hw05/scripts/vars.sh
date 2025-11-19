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
HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"

source "$SCRIPT_DIR/inventory.sh"

HIVE_VERSION="4.0.0-alpha-2"
HIVE_DIR="apache-hive-$HIVE_VERSION-bin"
HIVE_ARCHIVE="$HIVE_DIR.tar.gz"
HIVE_URL="https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/$HIVE_ARCHIVE"
HIVE_HOME="/home/$HADOOP_USER/$HIVE_DIR"

PG_JDBC_VERSION="42.7.4"
PG_JDBC_JAR="postgresql-$PG_JDBC_VERSION.jar"
PG_JDBC_URL="https://jdbc.postgresql.org/download/$PG_JDBC_JAR"
