#!/usr/bin/env Rscript
# Test the connection to the database
require("RPostgreSQL")
driver <- dbDriver("PostgreSQL")
connection <- dbConnect(driver,dbname="thessaloniki",host="localhost",port=5432,user="postgres",password="password")
dbExistsTable(connection,"ways_spatial")

# Test the map matching function
source("mapmatchfunctions_v2.R")
loadPackages();
gdata <- read.table("taxi-gps-sample.csv",header=TRUE,sep="\t")
test_matches <- match(gdata,'localhost',5432,"thessaloniki","postgres","password")
