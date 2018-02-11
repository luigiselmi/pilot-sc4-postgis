#!/usr/bin/env Rscript
# Test the connection to the database
require("RPostgreSQL")
driver <- dbDriver("PostgreSQL")
connection <- dbConnect(driver,dbname="thessaloniki",host="localhost",port=5432,user="postgres",password="$POSTGRES_PASSWORD")
dbExistsTable(connection,"ways_spatial")

# Test the map matching function
source("mapmatchfunctions_v2.R")
loadPackages();
#gdata <- read.table("taxi-gps-sample.csv",header=TRUE,sep="\t")
gdata <- data.frame(69510,"2013-07-09 07:50:53.000",22.960117,40.604947000000003,2.0,42,253.89999399999999,-1)
names <-c("device_random_id","recorded_timestamp","lon","lat","altitude","speed","orientation","transfer")
colnames(gdata) <- names
test_matches <- match(gdata,'localhost',5432,"thessaloniki","postgres","$POSTGRES_PASSWORD")
print(test_matches)
