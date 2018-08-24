#!/bin/bash

# project root directory
export PROJECT="$HOME/gitbase/fantasy"
export SNAPSHOT_DIR="$PROJECT/data"
export SNAPSHOT_SQL="nfldb.sql"
export SNAPSHOT_ZIP="$SNAPSHOT_SQL.zip"
export SNAPSHOT_URL="http://burntsushi.net/stuff/nfldb/$SNAPSHOT_ZIP"

# set up the user and database
echo "initializing database"
psql postgres -c "CREATE USER nfldb;"
psql postgres -c "CREATE DATABASE nfldb;"
#psql postgres -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;" nfldb

# download the database zip file and import
echo "downloading database snapshot"
wget $SNAPSHOT_URL -O $SNAPSHOT_DIR/$SNAPSHOT_ZIP -o log/download.log
unzip $SNAPSHOT_LOCAL -d $SNAPSHOT_DIR

# import the database snapshot to local database
echo "importing snapshot download into local database"
psql -U nfldb nfldb < $SNAPSHOT_DIR/$SNAPSHOT_SQL

# install python packages
echo "setting up python dependencies"
pip3 install nfldb
pip3 install ConfigParser
mkdir -p $HOME/.config/nfldb
cp /usr/local/share/nfldb/config.ini.sample $HOME/.config/nfldb/config.ini
