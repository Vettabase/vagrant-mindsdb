#!/bin/bash

# THIS IS A DRAFT.
# IT IS ABSOLUTELY NOT READY TO BE USED BY THE PUBLIC.
# Play with it as you please, and feel free to contribute.


# Compose arguments
# =================

ARG_MINDSDB_VERSION=
if [ ! -z "$MINDSDB_VERSION" ];
then
    ARG_MINDSDB_VERSION="==$MINDSDB_VERSION"
fi

SYS_PIP_VERSION=
if [ ! -z "$SYS_PIP_VERSION" ];
then
    ARG_SYS_PIP_VERSION="==$SYS_PIP_VERSION"
fi

ARG_CONFIG_FILE_PATH=
#ARG_CONFIG_FILE_PATH='--config=/home/vagrant/assets/config.json'
if [ ! -z "$CONFIG_FILE_PATH" ];
then
    ARG_CONFIG_FILE_PATH="--config=$CONFIG_FILE_PATH"
fi

ARG_APIS=
if [ ! -z "$MINDSDB_APIS" ];
then
    ARG_APIS="--api=$MINDSDB_APIS"
fi



# Main
# ====


apt-get update -y
apt-get install -y \
    python3 \
    python3-pip

if [ -z "$SKIP_PYTHON_ALIAS" ];
then
    apt-get install python-is-python3
fi

apt install -y python3.8-venv
python3 -m venv mindsdb
source mindsdb/bin/activate

if [ -z "$SYS_PIP_VERSION" ];
then
    pip install --upgrade --prefer-binary --no-cache-dir pip
else
    python -m pip install pip==$SYS_PIP_VERSION
fi
pip install --no-cache-dir mindsdb$ARG_MINDSDB_VERSION
pip freeze

apt-get install -y \
    mariadb-client \
    vim

# set vm.swappiness specified value and persist it
sysctl vm.swappiness=$SYS_SWAPPINESS
echo $SYS_SWAPPINESS > /proc/sys/vm/swappiness
echo "vm.swappiness=$SYS_SWAPPINESS" >> /etc/sysctl.conf

# generate a .my.cnf to connect MindsDB
MYCNF=/home/vagrant/.my.cnf
echo '[client]'         >  $MYCNF
echo                    >> $MYCNF
echo 'host=127.0.0.1'   >> $MYCNF
echo 'port=47335'       >> $MYCNF
echo 'user=mindsdb'     >> $MYCNF
echo 'password='        >> $MYCNF
echo                    >> $MYCNF


# TODO: We should install this command as a service.
# Running it in this way is useless, it's just a placeholder.
PYTHONUNBUFFERED=1 python3 -m mindsdb $ARG_CONFIG_FILE_PATH $ARG_APIS



# NOTES

# The Docker image places the config file here:
# /root/mindsdb_config.json

# http,mysql,mongodb

# to connect:
# mysql -h127.0.0.1 -P47335 -umindsdb
