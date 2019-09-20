#!/bin/bash

# see deployment script for installation
export PATH=$PATH:$HOME/Library/Python/2.7/bin
nfldb-update

# use `py` shortcut for preferred python version
shopt -s expand_aliases

# scrape data from web
py src/scrape.py

# update database
psql nfldb -f tools/functions.sql
psql nfldb -f tools/views.sql

# update visualizations
R -q -e "source('src/receivers.r')"
R -q -e "source('src/runningbacks.r')"
R -q -e "source('src/defense.r')"
