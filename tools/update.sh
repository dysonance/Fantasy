#!/bin/bash

./tools/nfldb-update
psql nfldb -f tools/functions.sql
psql nfldb -f tools/views.sql

R -q -e "source('src/receivers.r')"
R -q -e "source('src/defense.r')"
