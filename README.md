Pilot SC4 PostGis with OSM data
=====================
The Dockerfile builds a Docker image with PostGis and R. It contains also the R scripts with the definition of the functions for the 
map matching. The map matching algorithm is used to match the location of a vehicle given as a (longitude, latitude) pair
 to a street. The road network data, extracted from OpenStreetMap, is also added to the image. The area covered is the 
city of Thessaloniki. The map matching is based on some SQL scripts and on a R script. The scripts are provided by 
[CERTH-HIT](http://www.imet.gr/).

##Requirements

This component requires a Docker engine installed in the host where it is run.

##Build
A docker image can be built with the command

    $ docker build -t bde2020/pilot-sc4-postgis:v0.1.0 .

##Install and run
Start a docker container with PostGis setting the password of the POSTGRES_USER=postgres (e.g. "password")

    $ docker run --name postgis -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-postgis:v0.1.0

##Usage
You can connect to the PostGis container starting a new docker container with PostgreSQL running the psql client

    $ docker run -it --rm --link postgis:psql postgres:9.4 psql -h postgis -U postgres

You can also use the exec command with Docker to run a test script for the map matching

    $ docker exec -it postgis bash

From the container run the script

    # Rscript test_mapmatch.R

The script matches some records of taxies and returns the OSM identifiers of the matched 
road segments and the distance between the vehicle and the road segment.
 
##License
TBD
