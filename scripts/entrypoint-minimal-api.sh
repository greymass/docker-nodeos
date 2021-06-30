#!/usr/bin/env bash

# Grab latest snapshot
echo "downloading snapshot from $NODEOS_SNAPSHOT"
cd /eosio/downloads
curl -s -o /eosio/downloads/snapshot.tar.gz $NODEOS_SNAPSHOT
tar -xvf /eosio/downloads/snapshot.tar.gz
rm /eosio/downloads/snapshot.tar.gz
mv /eosio/downloads/*.bin /eosio/downloads/snapshot.bin
echo "snapshot downloaded and extracted!"

# Creating p2p portion of the config
echo "generating p2p information for config..."
for peer in $NODEOS_PEERS
do
    echo p2p-peer-address = $peer  >> /eosio/peers.ini
done

# Creating unix sock name based on container scaling index
IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
INDEX=`dig -x $IP +short | sed 's/.*_\([0-9]*\)\..*/\1/'`
NODEOS_SOCK=/eosio/shared/nodeos/$NETWORK_NAME$INDEX.sock
echo "generating unique unix sock file name ($NODEOS_SOCK)"
echo unix-socket-path = $NODEOS_SOCK >> /eosio/sock.ini
touch $NODEOS_SOCK
chmod 777 $NODEOS_SOCK

# Create nginx upstream entry for this server
echo "server unix:$NODEOS_SOCK fail_timeout=1 max_fails=3 weight=65535;" > /eosio/shared/nginx/$NETWORK_NAME$INDEX.conf

# Combine all configs to final version
cat /eosio/peers.ini /eosio/sock.ini /eosio/base.ini >> /eosio/config.ini
echo "config.ini generation complete!"

# Start based on snapshot
echo "starting nodeos..."
cd /eosio
/eosio/nodeos --data-dir=/ramdisk --config-dir=. --snapshot=/eosio/downloads/snapshot.bin