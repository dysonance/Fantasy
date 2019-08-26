#!/bin/bash

# see deployment script for installation
export PATH=$PATH:$HOME/Library/Python/2.7/bin
nfldb-update

./src/scrape.py

psql nfldb -f tools/functions.sql
psql nfldb -f tools/views.sql

R -q -e "source('src/receivers.r')"
R -q -e "source('src/runningbacks.r')"
R -q -e "source('src/defense.r')"
