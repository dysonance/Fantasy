#!/bin/bash

PYTHON_PACKAGE_PATH=$HOME/Library/Python/2.7

# project root directory
PROJECT="$(pwd)"
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
    unzip $SNAPSHOT_DIR/$SNAPSHOT_ZIP -d $SNAPSHOT_DIR
fi

# import the database snapshot to local database
echo "importing snapshot download into local database"
psql -U nfldb nfldb < $SNAPSHOT_DIR/$SNAPSHOT_SQL

# install python packages
echo "setting up python dependencies"
pip2 install --user --upgrade nflgame-redux  # version required for python3 support
pip2 install --user --upgrade ipython pandas numpy matplotlib scipy  # python research libraries

export PATH=$PATH:$HOME/Library/Python/2.7/bin  # put in bash profile to reuse

# setup nfldb configuration environment
if [ ! -d "$HOME/.config/nfldb" ]; then
    mkdir -p $HOME/.config/nfldb
fi
cp $PYTHON_PACKAGE_PATH/share/nfldb/config.ini.sample $HOME/.config/nfldb/config.ini

# one-off database changes to allow updates
# TODO: figure out where else in the schema the team_id needs to be renamed (if anywhere)
psql nfldb -c "INSERT INTO team (team_id, city, Name) VALUES ('LAC', 'Los Angeles', 'Chargers')"
psql nfldb -c "INSERT INTO team (team_id, city, Name) VALUES ('LAR', 'Los Angeles', 'Rams')"
psql nfldb -c "INSERT INTO team (team_id, city, Name) VALUES ('JAX', 'Jacksonville', 'Jaguars')"

# download and incorporate latest database updates
echo "running database updates"
$PYTHON_PACKAGE_PATH/bin/nfldb-update
