#!/usr/bin/env bash

# Grab latest snapshot
echo "downloading snapshot from $NODEOS_SNAPSHOT"
cd /eosio/downloads
case "$NODEOS_SNAPSHOT" in
*.tar.gz | *.tgz ) 
        curl -s -o /eosio/downloads/snapshot.tar.gz $NODEOS_SNAPSHOT
        tar -xvf /eosio/downloads/snapshot.tar.gz
        rm /eosio/downloads/snapshot.tar.gz
        mv /eosio/downloads/*.bin /eosio/downloads/snapshot.bin        
        ;;
*.zst )
        curl -s -o /eosio/downloads/snapshot.zst $NODEOS_SNAPSHOT
        apt install zstd
        zstd -d /eosio/downloads/snapshot.zst
        rm /eosio/downloads/snapshot.zst
        mv /eosio/downloads/snapshot /eosio/downloads/snapshot.bin
        ;;
*)
        echo "Unknown snapshot format!"
        exit 1
        ;;
esac
echo "snapshot downloaded and extracted!"

# Creating p2p portion of the config
echo "generating p2p information for config..."
for peer in $NODEOS_PEERS
do
    echo p2p-peer-address = $peer  >> /eosio/peers.ini
done

# Combine all configs to final version
cat /eosio/peers.ini /eosio/base.ini >> /eosio/config.ini
echo "config.ini generation complete!"

# Start based on snapshot
echo "starting nodeos..."
cd /eosio
/eosio/nodeos --data-dir=/ramdisk --config-dir=. --snapshot=/eosio/downloads/snapshot.bin