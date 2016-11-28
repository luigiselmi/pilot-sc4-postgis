#!/bin/bash

psql -U postgres thessaloniki < bde_pilot_thessaloniki_dump 
psql -U postgres -d thessaloniki -f CREATE_ways_spatial.sql
psql -U postgres -d thessaloniki -f CREATE_fn_mapmatch.sql
