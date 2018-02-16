Pilot SC4 Map-Matching
=====================
This repository provides the components to set up the map-matching service. It is based on PostGis and on Rserve. Both are
provided as docker images. Rserve allows the communication between a Java application and R, the statistical framework. It
includes some Rscripts that implement functions that are called remotely by the Java application. The R scripts send request 
to the PostGis container that computes the map-matching. The map matching algorithm is used to match the location of a vehicle given as a (longitude, latitude) pair
 to a road segment. The road network data, extracted from OpenStreetMap, is added to the PostGis image. The area covered is 
the city of Thessaloniki. The R and SQL scripts are provided by [CERTH-HIT](http://www.imet.gr/).
 

## Requirements
Docker engine is required to build the images and run the containers. A docker network, e.g. "pilot-sc4-net", must be created to allow the 
communication between the containers using their names

    $ docker network create pilot-sc4-net

## PostGis
A docker image with Postgres and PostGis can be built with the command

    $ docker build -t bde2020/pilot-sc4-postgis:v0.1.0 .

### Install and run PostGis
Start a docker container with PostGis, name it e.g. "postgres", setting the password of the POSTGRES_USER=postgres 
(e.g. "password")

    $ docker run --name postgres --network pilot-sc4-net -p 5432:5432 -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-postgis:v0.1.0

## Rserve
Rserve allows the use of R scripts and functions from Java through a TCP/IP connection. The server can be configured
setting some parameters in the Rserve.conf file. The parameters set are a source R file with the functions that will be
called from Java, the port and the remote connection enabled. A docker image of the Rserve can be built with the command

    $ docker build -t bde2020/pilot-sc4-rserve:v0.1.0 . 


In order to start the container execute the command

    $ docker run --name map-match --network pilot-sc4-net -p 6311:6311 -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-rserve:v0.1.0

## Usage
Both services can be started using docker-compose

    $ docker-compose up -d

## Test the Rserve and PostGis docker containers
You can open a shell in the Rserve container with the command

    $ docker exec -it map-match bash

From the Rserve container run the script

    # Rscript test_mapmatch.R

The script communicates with the PostGis container to map-match records of taxis with road segments and returns the OSM identifiers 
of the matched road segments and the distance between the vehicle and the road segment.


## License
Apache 2.0
