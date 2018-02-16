# The image created with this Dockerfile starts an instance of Rserve and imports R scripts to connect to PostGis
# and map-match the location of a taxi to a road segment. 
# 1) In order to build an image using this docker file, run the following docker command
# $  docker build -t bde2020/pilot-sc4-rserve:v0.1.0 .
# 2) Run a container using the command
# $ docker run --name map-match --network pilot-sc4-net -p 6311:6311 -e POSTGRES_PASSWORD=password -d bde2020/pilot-sc4-rserve:v0.1.0

FROM ubuntu

MAINTAINER Luigi Selmi <luigiselmi@gmail.com>

# Install  network tools (ifconfig, netstat, ping, ip)
RUN apt-get update && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y iproute2

# Install vi for editing
RUN apt-get update && \
    apt-get install -y vim 

# Install R
RUN apt-get update \
    && apt-get install -y r-base r-base-dev \
    && apt-get install -y libpq-dev libssl-dev

# Copy R packages to connect to PostgreSQL
ADD https://cran.r-project.org/src/contrib/Archive/RPostgreSQL/RPostgreSQL_0.4-1.tar.gz .
ADD https://cran.r-project.org/src/contrib/Archive/DBI/DBI_0.5-1.tar.gz .
RUN ["R","CMD","INSTALL","DBI_0.5-1.tar.gz"]
RUN ["R","CMD","INSTALL","RPostgreSQL_0.4-1.tar.gz"]

# Copy the R scripts for the map matching 
ADD mapmatchfunctions_v2.R .

# Copy a script and a data file to test the  installation
ADD taxi-gps-sample.csv .
ADD test_mapmatch.R . 

# Add Rserve for the communication Java - R
ADD start_rserve.sh .
ADD Rserve.conf .
ADD package/ package/

# Install the Rserve package for R
RUN ["R", "CMD", "INSTALL", "package/Rserve_1.8-5.tar.gz"]
  
# Start Rserve (no daemon)
CMD ["sh","start_rserve.sh"]
