#!/bin/bash

# THIS IS A DRAFT.
# IT IS ABSOLUTELY NOT READY TO BE USED BY THE PUBLIC.
# Play with it as you please, and feel free to contribute.


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

if [ ! -z "$MINDSDB_VERSION" ];
then
    ARG_MINDSDB_VERSION="==$MINDSDB_VERSION"
fi

pip install --upgrade --prefer-binary --no-cache-dir pip
pip install --no-cache-dir mindsdb$ARG_MINDSDB_VERSION
pip freeze

apt-get install -y \
    mariadb-client

# set vm.swappiness specified value and persist it
sysctl vm.swappiness=$SYS_SWAPPINESS
echo $SYS_SWAPPINESS > /proc/sys/vm/swappiness
echo "vm.swappiness=$SYS_SWAPPINESS" >> /etc/sysctl.conf

ARG_CONFIG_FILE_PATH=
if [ ! -z "$CONFIG_FILE_PATH" ];
then
    ARG_CONFIG_FILE_PATH="--config=$CONFIG_FILE_PATH"
fi

ARG_APIS=
if [ ! -z "$APIS" ];
then
    ARG_APIS="--config=$APIS"
fi


# TODO: We should install this command as a service.
# Running it in this way is useless, it's just a placeholder.
python3 -m mindsdb $ARG_CONFIG_FILE_PATH $ARG_APIS



# NOTES

# The Docker image places the config file here:
# /root/mindsdb_config.json

# http,mysql,mongodb

# to connect:
# mysql -h127.0.0.1 -P47335 -umindsdb
