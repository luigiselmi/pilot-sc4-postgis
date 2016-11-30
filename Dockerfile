# The image created with this Dockerfile starts an instance of postgis with the road network of 
# Thessaloniki and a function to extract the map matched candidates from a set of GPS records
# 1) In order to build an image using this docker file, run the following docker command
# $  docker build -t bde2020/pilot-sc4-postgis:v0.0.1 .
# 2) Run a container using the command
# $ docker run --name postgis -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-postgis:v0.0.1

FROM postgres:9.4

MAINTAINER Luigi Selmi <luigiselmi@gmail.com>

# Install vi for editing
RUN apt-get update && \
    apt-get install -y vim

# Install the PostGis extension
RUN apt-get update \
    && apt-get install -y postgresql-contrib-9.4 \
    && apt-get install -y postgresql-9.4-postgis-scripts 

# Install R
RUN apt-get update \
    && apt-get install -y r-base r-base-dev \
    && apt-get install -y libpq-dev

# Copy R packages to connect to PostgreSQL
ADD https://cran.r-project.org/src/contrib/RPostgreSQL_0.4-1.tar.gz .
ADD https://cran.r-project.org/src/contrib/DBI_0.5-1.tar.gz .
RUN ["R","CMD","INSTALL","DBI_0.5-1.tar.gz"]
RUN ["R","CMD","INSTALL","RPostgreSQL_0.4-1.tar.gz"]

# Copy the R scripts for the map matching 
ADD mapmatchfunctions_v2.R .

# Copy a script and a data file to test the  installation
ADD taxi-gps-sample.csv .
ADD test_mapmatch.R .

# Copy the SQL scripts for the map-match
ADD CREATE_fn_mapmatch.sql .
ADD CREATE_ways_spatial.sql .

# Create the thessaloniki database, enable the postgis extensions, import the OSM data
ADD init-thessaloniki-db.sh docker-entrypoint-initdb.d/init-thessaloniki-db.sh 

# Copy the OSM data (dump) with the thessaloniki road network
ADD bde_pilot_thessaloniki_dump.gz .
RUN gunzip bde_pilot_thessaloniki_dump.gz 



