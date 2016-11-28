#!/bin/bash
set -e

psql --username postgres thessaloniki < osm_roads_greece.sql 
