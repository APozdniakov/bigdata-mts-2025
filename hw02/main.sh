#!/usr/bin/env bash

set -eux

SCRIPT_DIR=$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")

"$SCRIPT_DIR/scripts/team_jumpnode.sh" "$SCRIPT_DIR"

"$SCRIPT_DIR/scripts/hadoop_jumpnode.sh" "$SCRIPT_DIR"

"$SCRIPT_DIR/scripts/run_hadoop.sh" "$SCRIPT_DIR"
