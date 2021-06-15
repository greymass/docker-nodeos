FROM ubuntu:18.04

# install required software
RUN apt-get update && apt-get install -y curl git

# setup folder structure
RUN mkdir /eosio
RUN mkdir /eosio/build
RUN mkdir /eosio/downloads

# build nodeos
RUN git clone https://github.com/EOSIO/eos.git /eosio/build
WORKDIR /eosio/build
RUN git checkout $NODEOS_VERSION
RUN git submodule update --init --recursive
RUN ./scripts/eosio_build.sh -y
RUN cp /eosio/build/build/programs/nodeos/nodeos /eosio/nodeos

# configure nodeos
COPY configs/config.ini /eosio/base.ini

# copy startup script
COPY scripts/start.sh /eosio/start.sh
RUN chmod +x /eosio/start.sh

# start nodeos
WORKDIR /eosio
CMD ["/eosio/start.sh"]
