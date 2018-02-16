# R script to map match the position (long,lat) of taxies to links in a area (Thessaloniki) taken from OpenStreetMap.  
# This script define the functions that will be available to a client that connects to a Rserve. 
# The order in which the functions must be called is as follows
# loadPackages()
# matches<-match(gdata, pg_host, pg_port, pg_dbname, pg_user, pg_password, par_ncand, par_maxdistancemeters)
# printMatches(matches)

## Imports and load packages that might not be available by default in R ##
loadPackages <- function() {
  # There are specific packages that should be installed. Here we check if a package is installed, if not,
  # we install them. 
  
  if("RPostgreSQL" %in% rownames(installed.packages()) == FALSE) {install.packages("RPostgreSQL")}
  
  # loading libs:
  library(RPostgreSQL)
}

## Proximity & Candidates ##
match <- function(gdata,pg_host,pg_port,pg_dbname,pg_user,pg_password,par_ncand = 1,par_maxdistancemeters = 10) {
  #start timer
  t1 <- Sys.time();
  
  #number of link candidates to return
  #defaults to 1 but we could change it accordingly
  nCand<-par_ncand
  
  
  #maximum allowed distance in meters between GPS signal and the matched OSM link 
  #defaults to 10 meters but we could change it accordingly
  buffer_meters <-par_maxdistancemeters
  
  #create a temp table name to use
  tempTableName <- c(1:1) # initialize vector
  for (i in 1:1)
  {
    tempTableName[i] <- paste(sample(c(letters),8, replace=TRUE),collapse="")
  }

  #we will use 2 temp tables with prefix naming inside postgresql
  #tempDataTAbleName will contain the untouched input
  tempDataTableName = paste("temp_gps_data",tempTableName, sep="_")
  #tempProcTableName will contain the input plus the geography and geometry fields plus the appropriate indexes
  tempProcTableName = paste("temp_gps_proc",tempTableName, sep="_")
  
  #db credentials and connection
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, host = pg_host, dbname = pg_dbname, user = pg_user, password = pg_password, port = pg_port)
  
  #write the current GPS dataset into a temp table named tempDataTableName
  dbWriteTable(con,tempDataTableName,gdata, overwrite = TRUE, row.names = FALSE,  is.temp = TRUE)
  
  #Call the prepared fn_mapmatch plpgsql function to:
  #1) Transfer GPS dataset into our indexed table and create geom and geog fields on the fly. 
  #2) Execute the required SQL commands to match GPS to OSM roads
  strSQLquery = paste("SELECT * FROM fn_mapmatch('",tempDataTableName,"','",tempProcTableName,"',",buffer_meters,",", nCand,");",sep="")
  dfTemp = dbGetQuery(con, strSQLquery) 
  
  #stop timer
  t2 <- Sys.time()
  totalTime <- difftime(t2,t1, units="secs")
  
  #
  # Free all resources
  #
  # disconnect from database
  on.exit(dbDisconnect(con))
  
  # Return a data frame that contains the results
  dfTemp
}