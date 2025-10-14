#!/usr/bin/env bash
set -eux

PASSWORD=$1

echo "$PASSWORD" | sudo -S bash -c "id -u hadoop &> /dev/null || useradd -m -s /bin/bash hadoop"
echo "$PASSWORD" | sudo -S bash -c "echo \"hadoop:$PASSWORD\" | chpasswd"

echo "$PASSWORD" | sudo -S mv /home/team/hosts /etc/hosts
