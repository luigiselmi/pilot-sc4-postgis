#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE thessaloniki;
    GRANT ALL PRIVILEGES ON DATABASE thessaloniki TO $POSTGRES_USER;
    CREATE EXTENSION hstore;
    CREATE EXTENSION  postgis;
EOSQL
