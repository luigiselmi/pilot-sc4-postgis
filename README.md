Pilot SC4 Map-Matching
=====================
This repository provides the components to set up the map-matching service. It is based on PostGis and on Rserve. Both are
provided as docker images. Rserve allows the communication between a Java application and R, the statistical framework. It
includes some Rscripts that implement functions that are called remotely by the Java application. The R scripts send request 
to the PostGis container that computes the map-matching. The map matching algorithm is used to match the location of a vehicle given as a (longitude, latitude) pair
 to a road segment. The road network data, extracted from OpenStreetMap, is added to the PostGis image. The area covered is 
the city of Thessaloniki. The R and SQL scripts are provided by [CERTH-HIT](http://www.imet.gr/).
 

## Requirements

This component requires Docker engine.

## PostGis
A docker image can be built with the command

    $ docker build -t bde2020/pilot-sc4-postgis:v0.1.0 .

## Install and run
Start a docker container with PostGis, name it e.g. "map-match", setting the password of the POSTGRES_USER=postgres (e.g. "password")

    $ docker run --name map-match -p 6311:6311 -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-postgis:v0.1.0

The port is used by  Rserve

## Usage
You can connect to the PostGis RDBMS in the container starting a new docker container with PostgreSQL running the psql client.

    $ docker run -it --rm --link map-match:psql postgres:9.4 psql -h map-match -U postgres

You can also use the exec command with Docker to run a test script for the map matching

    $ docker exec -it map-match bash

From the container run the script

    # Rscript test_mapmatch.R

The script matches some records of taxis and returns the OSM identifiers of the matched 
road segments and the distance between the vehicle and the road segment.

## Rserve
Rserve allows the use of R scripts and functions from Java through a TCP/IP connection. The server can be configured
setting some parameters in the Rserve.conf file. The parameters set are a source R file with the functions that will be
called from Java, the port and the remote connection enabled. In order to start the Rserve run the following command 

    $ docker exec -d map-match ./start_rserve.sh


## Troubleshooting installing Rserve
In case the build of the docker image fails because of the Rserve installation you can try to install it manually from
within the container running the same command as in the Dockerfile 

    # R CMD INSTALL rserve/Rserve_1.8-5.tar.gz
 
The installation can terminate with a error message but it should work all the same.

## License
Apache 2.0
