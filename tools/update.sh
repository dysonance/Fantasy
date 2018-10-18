#!/bin/bash

./tools/nfldb-update
psql nfldb -f tools/functions.sql
psql nfldb -f tools/views.sql
