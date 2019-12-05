#!/bin/bash

# see deployment script for installation
PYTHON_PACKAGE_PATH=$HOME/Library/Python/2.7
export PATH=$PATH:$PYTHON_PACKAGE_PATH
nfldb-update

# use `py` shortcut for preferred python version
shopt -s expand_aliases
. ~/Base/config/profile.sh

# scrape data from web
py src/io/web/scrape.py

# update database
psql nfldb -f util/functions.sql
psql nfldb -f util/views.sql

# update visualizations
R -q -e "source('src/calc/receivers.r')"
R -q -e "source('src/calc/runningbacks.r')"
R -q -e "source('src/calc/defense.r')"
