#!/bin/bash

NFLDB_VERSION="1.0.0a4"
SNAPSHOT_YEAR=2019
SNAPSHOT_URL=https://github.com/derek-adair/nfldb/releases/download/$NFLDB_VERSION/nfldb$SNAPSHOT_YEAR.sql.zip

shopt -s expand_aliases
. ~/Base/config/environment.sh

# set up the user and database
echo "initializing database"
psql postgres -c "CREATE USER nfldb;"
psql postgres -c "CREATE DATABASE nfldb OWNER nfldb;"
psql -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;" nfldb

# import the database snapshot to local database
echo "downloading database snapshot"
wget $SNAPSHOT_URL &&
    unzip nfldb$SNAPSHOT_YEAR.sql.zip &&
    rm nfldb$SNAPSHOT_YEAR.sql.zip &&
    mv nfldb$SNAPSHOT_YEAR.sql data/

psql postgres -c 'DROP DATABASE nfldb;'
psql postgres -c "CREATE DATABASE nfldb;"
psql nfldb -c 'CREATE EXTENSION fuzzystrmatch;'

# NOTE: weird user/owner bug lines in sql dump need to be deleted
sed -i -e "s/.*XANEURLENTLEMOIRTAGETAGE.*//g" nfldb.sql
echo "importing snapshot download into local database"
psql nfldb < nfldb.sql
./util/backup.sh

# setup python environment
echo "setting up python dependencies"
python3 -m venv venv
venv/bin/pip install -r data/dep/python.txt
if [ ! -d "$HOME/.config/nfldb" ]; then mkdir -p $HOME/.config/nfldb; fi
cp venv/share/nfldb/config.ini.sample $HOME/.config/nfldb/config.ini

# one-off database changes to allow updates
# TODO: figure out where else in the schema the team_id needs to be renamed (if anywhere)
psql nfldb -c "INSERT INTO team (team_id, city, Name) VALUES ('LAC', 'Los Angeles', 'Chargers')"
psql nfldb -c "INSERT INTO team (team_id, city, Name) VALUES ('LAR', 'Los Angeles', 'Rams')"
psql nfldb -c "INSERT INTO team (team_id, city, Name) VALUES ('JAX', 'Jacksonville', 'Jaguars')"
psql nfldb -c "INSERT INTO team (team_id, city, Name) VALUES ('LV', 'Las Vegas', 'Raiders')"

# download and incorporate latest database updates
echo "running database updates"
venv/bin/nfldb-update
