# The image created with this Dockerfile starts an instance of postgis with the road network of 
# Thessaloniki and a function to extract the map matched candidates from a set of GPS records
# 1) In order to build an image using this docker file, run the following docker command
# $  docker build -t bde2020/pilot-sc4-postgis:v0.0.1 .
# 2) Run a container using the command
# $ docker run --name postgis -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-postgis:v0.0.1

FROM postgres:9.4

MAINTAINER Luigi Selmi <luigiselmi@gmail.com>

# Install the PostGis extension
RUN apt-get update \
    && apt-get install -y postgresql-contrib-9.4 \
    && apt-get install -y postgresql-9.4-postgis-scripts 

# Create the thessaloniki database and enable the postgis extensions
ADD init-thessaloniki-db.sh docker-entrypoint-initdb.d/init-thessaloniki-db.sh 

# Copy the OSM data with the thessaloniki road network
ADD osm_roads_greece.sql.gz .
RUN gunzip osm_roads_greece.sql.gz 

# Copy the SQL script for the map-match
ADD CREATE_fn_mapmatch.sql .

# Import the data
ADD import-road-network-data.sh .
RUN ["sh", "import-road-network-data.sh"]
