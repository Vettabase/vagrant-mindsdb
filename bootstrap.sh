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
pip install --prefer-binary --no-cache-dir  mindsdb
pip freeze

apt-get install -y \
    mariadb-client

python -m mindsdb --config=$CONFIG_FILE_PATH --api=$APIs &



# NOTES

# The Docker image places the config file here:
# /root/mindsdb_config.json

# http,mysql,mongodb

# to connect:
# mysql -h127.0.0.1 -P47335 -umindsdb
