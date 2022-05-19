#!/bin/bash

# THIS IS A DRAFT.
# IT IS ABSOLUTELY NOT READY TO BE USED BY THE PUBLIC.
# Play with it as you please, and feel free to contribute.


# Compose arguments
# =================

# MindsDB version to install via PIP
ARG_MINDSDB_VERSION=
if [ ! -z "$MINDSDB_VERSION" ];
then
    ARG_MINDSDB_VERSION="==$MINDSDB_VERSION"
fi

# PIP version to install from a Linux repository
SYS_PIP_VERSION=
if [ ! -z "$SYS_PIP_VERSION" ];
then
    ARG_SYS_PIP_VERSION="==$SYS_PIP_VERSION"
fi

# MindsDB --config parameter
ARG_CONFIG_FILE_PATH=
#ARG_CONFIG_FILE_PATH='--config=/home/vagrant/assets/config.json'
if [ ! -z "$CONFIG_FILE_PATH" ];
then
    ARG_CONFIG_FILE_PATH="--config=$CONFIG_FILE_PATH"
fi

# MindsDB --api parameter
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
pip install --no-cache-dir --default-timeout 30 mindsdb$ARG_MINDSDB_VERSION
pip freeze

apt-get install -y \
    mariadb-client \
    vim

# if SYS_SWAPPINESS is set,
# set vm.swappiness specified value and persist it
if [ ! -z "$SYS_SWAPPINESS" ];
then
    sysctl vm.swappiness=$SYS_SWAPPINESS
    echo $SYS_SWAPPINESS > /proc/sys/vm/swappiness
    echo "vm.swappiness=$SYS_SWAPPINESS" >> /etc/sysctl.conf
fi

# generate a .my.cnf to connect MindsDB
MYCNF=/home/vagrant/.my.cnf
echo '[client]'         >  $MYCNF
echo                    >> $MYCNF
echo 'host=127.0.0.1'   >> $MYCNF
echo 'port=47335'       >> $MYCNF
echo 'user=mindsdb'     >> $MYCNF
echo 'password='        >> $MYCNF
echo                    >> $MYCNF


# Utility scripts used by systemd and humans

MINDSDB_SCRIPT_DIR=/usr/local/bin/mindsdb
mkdir -p $MINDSDB_SCRIPT_DIR


# mindsdb-start.sh

MINDSDB_START=$MINDSDB_SCRIPT_DIR/mindsdb-start.sh
touch $MINDSDB_START
chown  root  $MINDSDB_START
chgrp  root  $MINDSDB_START
chmod  744   $MINDSDB_START

echo '#!/bin/bash'                  >  $MINDSDB_START
echo 'cd /home/vagrant'             >> $MINDSDB_START
echo 'source mindsdb/bin/activate'  >> $MINDSDB_START
echo "PYTHONUNBUFFERED=1 python3 -m mindsdb $ARG_CONFIG_FILE_PATH $ARG_APIS" \
    >>  $MINDSDB_START


# mindsdb-stop.sh

MINDSDB_STOP=$MINDSDB_SCRIPT_DIR/mindsdb-stop.sh
touch $MINDSDB_STOP
chown  root  $MINDSDB_STOP
chgrp  root  $MINDSDB_STOP
chmod  744   $MINDSDB_STOP

echo '#!/bin/bash' \
    >   $MINDSDB_STOP
echo 'kill -15 $( systemctl show --property MainPID mindsdb |cut -d"=" -f2 )' \
    >>  $MINDSDB_STOP


# let's move the file when it's finished to avoid polluting
# systemd directories
SERVICE_CONF=/tmp/mindsdb.service
touch  $SERVICE_CONF
chown  root  $SERVICE_CONF
chgrp  root  $SERVICE_CONF
chmod  644   $SERVICE_CONF

echo '[Unit]'                      >  $SERVICE_CONF
echo 'Description=MindsDB In-Database Marchine Learning' \
                                   >> $SERVICE_CONF
echo ''                            >> $SERVICE_CONF
echo '[Service]'                   >> $SERVICE_CONF
echo 'Type=simple'                 >> $SERVICE_CONF
echo 'Restart=on-failure'          >> $SERVICE_CONF
echo 'TimeoutStartSec=10min'       >> $SERVICE_CONF
echo 'RestartSec=1'                >> $SERVICE_CONF
echo 'User=root'                   >> $SERVICE_CONF
echo 'Group=root'                  >> $SERVICE_CONF
echo "ExecStart=$MINDSDB_START"    >> $SERVICE_CONF
echo "ExecStop=$MINDSDB_STOP"      >> $SERVICE_CONF
echo ''                            >> $SERVICE_CONF
echo '[Install]'                   >> $SERVICE_CONF
echo 'WantedBy=multi-user.target'  >> $SERVICE_CONF
echo ''                            >> $SERVICE_CONF

mv $SERVICE_CONF /etc/systemd/system/mindsdb.service

systemctl daemon-reload
systemctl start mindsdb


# NOTES

# to connect:
# mysql -h127.0.0.1 -P47335 -umindsdb
