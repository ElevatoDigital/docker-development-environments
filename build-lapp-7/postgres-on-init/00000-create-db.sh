#!/bin/bash

DBNAME=development
DBUSER=development
DUMPFILE="/docker-entrypoint-initdb.d/import-dump"

echo "Restoring DB using $file"
psql -U postgres --dbname=postgres -c "CREATE USER $DBUSER;"
psql -U postgres --dbname=postgres -c "CREATE DATABASE $DBNAME;"
psql -U postgres --dbname=postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DBNAME TO $DBUSER;"
psql -U postgres --dbname=$DBNAME < "$DUMPFILE" || exit 1
