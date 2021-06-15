#!/usr/bin/env bash

# Grab latest snapshot
echo "Downloading snapshot from $NODEOS_SNAPSHOT"
cd /eosio/downloads
curl -s -o /eosio/downloads/snapshot.tar.gz $NODEOS_SNAPSHOT
tar -xvf /eosio/downloads/snapshot.tar.gz
rm /eosio/downloads/snapshot.tar.gz
mv /eosio/downloads/*.bin /eosio/downloads/snapshot.bin
echo "Snapshot download complete!"

# Append P2P information to configuration
echo "Appending peer information and generating config.ini"
for peer in $NODEOS_PEERS
do
    echo p2p-peer-address = $peer  >> /eosio/peers.ini
done
cat /eosio/peers.ini /eosio/base.ini >> /eosio/config.ini
echo "config.ini generated!"

# Start based on snapshot
echo "starting nodeos..."
cd /eosio
/eosio/nodeos --data-dir=/ramdisk --config-dir=. --snapshot=/eosio/downloads/snapshot.bin