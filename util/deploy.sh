#!/bin/bash

PYTHON_PACKAGE_PATH=$HOME/Library/Python/2.7
SNAPSHOT_URL="http://burntsushi.net/stuff/nfldb/nfldb.sql.zip"

shopt -s expand_aliases
. ~/Base/config/profile.sh

# set up the user and database
echo "initializing database"
psql postgres -c "CREATE USER nfldb;"
psql postgres -c "CREATE DATABASE nfldb OWNER nfldb;"
psql -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;" nfldb

# download the database zip file and import
if [ ! -f "data/nfldb.sql" ]; then
    echo "downloading database snapshot"
    wget $SNAPSHOT_URL -O data/nfldb.sql.zip -o log/download.log
    unzip data/nfldb.sql.zip -d data
fi

# import the database snapshot to local database
echo "importing snapshot download into local database"
psql -U nfldb nfldb < data/nfldb.sql

# install python packages
# NOTE: binaries install to ~/Library/Python/2.7/bin
echo "setting up python dependencies"
pip2 install --user --upgrade nfldb nflgame nflgame-redux requests bs4
pip2 install --user --upgrade ipython pandas numpy matplotlib scipy requests bs4 openpyxl
ipi install --upgrade ipython pandas numpy matplotlib scipy requests bs4 openpyxl
export PATH=$PATH:$HOME/Library/Python/2.7/bin

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
