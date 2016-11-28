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

# Install R
RUN apt-get update \
    && apt-get install -y r-base r-base-dev

# Create the thessaloniki database and enable the postgis extensions
ADD init-thessaloniki-db.sh docker-entrypoint-initdb.d/init-thessaloniki-db.sh 

# Copy the OSM data (dump) with the thessaloniki road network
ADD bde_pilot_thessaloniki_dump.gz .
RUN gunzip bde_pilot_thessaloniki_dump.gz 

# Copy the SQL scripts for the map-match
ADD CREATE_fn_mapmatch.sql .
ADD CREATE_ways_spatial.sql .

# Import the data 
ADD import-road-network-data.sh .
#CMD ["sh", "import-road-network-data.sh"]


