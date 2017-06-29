# Set the base image to Ubuntu
FROM ubuntu:16.04

MAINTAINER Jeremy Magland

RUN apt-get update

# Install qt5
RUN apt-get install -y software-properties-common
RUN apt-add-repository ppa:ubuntu-sdk-team/ppa
RUN apt-get update
RUN apt-get install -y qtdeclarative5-dev
RUN apt-get install -y qt5-default qtbase5-dev qtscript5-dev make g++

# Install fftw3, nodejs, npm, and wget
RUN apt-get install -y libfftw3-dev nodejs npm wget

# Copy the source code, example and configuration file
COPY ./mountainlab /work/mountainlab
COPY ./fi_ss /work/fi_ss
COPY ./mountainlab.user.json /work/mountainlab/mountainlab.user.json

# Sometimes docker will not add the symlink files, so we need to do this:
RUN cd /work/mountainlab && git checkout .

# Set the path
ENV PATH="/work/mountainlab/bin:${PATH}"

# Compile the source code
RUN cd /work/mountainlab && ./compile_components.sh mlcommon prv mda mdaconvert mountainprocess mountainsort3 mountainsort mountainsort2

# Download an example dataset and run processing
CMD cd /work/fi_ss/analyses/manuscript/synthetic && prv-download datasets/K15/raw.mda.prv --server=river raw && kron-run ms3 K15 --_nodaemon
