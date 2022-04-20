#!/bin/bash

# THIS IS A DRAFT.
# IT IS ABSOLUTELY NOT READY TO BE USED BY THE PUBLIC.
# Play with it as you please, and feel free to contribute.


apt-get update -y
apt-get install -y \
    python3 \
    python3-pip

apt install -y python3.8-venv
python3 -m venv mindsdb
source mindsdb/bin/activate

pip install --upgrade --prefer-binary --no-cache-dir pip
pip install --no-cache-dir mindsdb
pip freeze

apt-get install -y \
    mariadb-client

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


python3 -m mindsdb $ARG_CONFIG_FILE_PATH $ARG_APIS



# NOTES

# The Docker image places the config file here:
# /root/mindsdb_config.json

# http,mysql,mongodb

# to connect:
# mysql -h127.0.0.1 -P47335 -umindsdb
