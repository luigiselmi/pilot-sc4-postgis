#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE thessaloniki;
    GRANT ALL PRIVILEGES ON DATABASE thessaloniki TO $POSTGRES_USER;
    CREATE EXTENSION hstore;
    CREATE EXTENSION  postgis;
EOSQL

psql -U postgres thessaloniki < bde_pilot_thessaloniki_dump 
psql -U postgres -d thessaloniki -f CREATE_ways_spatial.sql
psql -U postgres -d thessaloniki -f CREATE_fn_mapmatch.sql



