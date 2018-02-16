# The image created with this Dockerfile starts an instance of PostGis with the road network of 
# Thessaloniki 
# 1) In order to build an image using this docker file, run the following docker command
# $  docker build -t bde2020/pilot-sc4-postgis:v0.1.0 .
# 2) Run a container using the command
# $ docker run --name postgres --network pilot-sc4-net -p 5432:5432 -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-postgis:v0.1.0

FROM postgres:9.4

MAINTAINER Luigi Selmi <luigiselmi@gmail.com>

# Install vi for editing
RUN apt-get update && \
    apt-get install -y vim

# Install the PostGis extension
RUN apt-get update \
    && apt-get install -y postgresql-contrib-9.4 \
    && apt-get install -y postgresql-9.4-postgis-scripts 

# Copy the SQL scripts for the map-match
ADD CREATE_fn_mapmatch.sql .
ADD CREATE_ways_spatial.sql .

# Copy the OSM data (dump) with the thessaloniki road network
ADD bde_pilot_thessaloniki_dump.gz .
RUN gunzip bde_pilot_thessaloniki_dump.gz 

# Create the thessaloniki database, enable the postgis extensions, import the OSM data
ADD init-thessaloniki-db.sh docker-entrypoint-initdb.d/init-thessaloniki-db.sh
