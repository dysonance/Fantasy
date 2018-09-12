#!/bin/bash

PYTHON_PACKAGE_PATH=$HOME/Library/Python/2.7

# project root directory
PROJECT="$HOME/gitbase/fantasy"
SNAPSHOT_DIR="$PROJECT/data"
SNAPSHOT_SQL="nfldb.sql"
SNAPSHOT_ZIP="$SNAPSHOT_SQL.zip"
SNAPSHOT_URL="http://burntsushi.net/stuff/nfldb/$SNAPSHOT_ZIP"

# set up the user and database
echo "initializing database"
psql postgres -c "CREATE USER nfldb;"
psql postgres -c "CREATE DATABASE nfldb OWNER nfldb;"
psql -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;" nfldb

# download the database zip file and import
if [ ! -f "$SNAPSHOT_DIR/$SNAPSHOT_SQL" ]; then
    echo "downloading database snapshot"
    wget $SNAPSHOT_URL -O $SNAPSHOT_DIR/$SNAPSHOT_ZIP -o log/download.log
    unzip $SNAPSHOT_LOCAL -d $SNAPSHOT_DIR
fi

# import the database snapshot to local database
echo "importing snapshot download into local database"
psql -U nfldb nfldb < $SNAPSHOT_DIR/$SNAPSHOT_SQL

# install python packages
echo "setting up python dependencies"
pip2 install --user --upgrade --force nfldb
pip2 install --user --upgrade --force nflgame-redux
if [ ! -d "$HOME/.config/nfldb" ]; then
    mkdir -p $HOME/.config/nfldb
fi
cp $PYTHON_PACKAGE_PATH/share/nfldb/config.ini.sample $HOME/.config/nfldb/config.ini

# one-off database changes to allow updates
# TODO: figure out where else in the schema the team_id needs to be renamed (if anywhere)
psql nfldb -c "UPDATE team SET team_id='JAX' WHERE city='Jacksonville' AND name='Jaguars'"
psql nfldb -c "UPDATE team SET team_id='LAR' WHERE city='Los Angeles' AND name='Rams'"
psql nfldb -c "UPDATE team SET team_id='LAC', city='Los Angeles' WHERE city='San Diego' AND name='Chargers'"

# download and incorporate latest database updates
echo "running database updates"
$PYTHON_PACKAGE_PATH/bin/nfldb-update
