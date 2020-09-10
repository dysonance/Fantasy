#!/bin/bash

BACKUP_DATE=`date +%Y%m%d`
BACKUP_FILE=data/backups/nfldb_backup_$BACKUP_DATE.sql
echo "backing up nfldb database to $BACKUP_FILE"
pg_dump nfldb > $BACKUP_FILE
