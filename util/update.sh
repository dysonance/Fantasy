#!/bin/bash

# create backup snapshot before updating
./util/backup.sh

# see deployment script for installation
PYTHON_PACKAGE_PATH=$HOME/Library/Python/2.7
export PATH=$PATH:$PYTHON_PACKAGE_PATH/bin
nfldb-update

# scrape data from web
venv/bin/python src/data/web/scrape.py

# update database (NOTE: sort important since functions must run first)
for f in $(find src/data/db/sync | sort); do
    echo "syncing database: $f"
    psql nfldb -f $f
done

# update visualizations
R -q -e "source('src/calc/receivers.r')"
R -q -e "source('src/calc/runningbacks.r')"
R -q -e "source('src/calc/defense.r')"
