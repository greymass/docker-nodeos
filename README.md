# Requirements

The usage of this repository makes use of `docker` and `docker-compose`. This root docker container can be orcehstrated into other platforms (Swarm, K8s, etc) as well so long as you understand how to deploy to them.

[A quick guide on setting up docker and docker-compose can be found here](https://support.netfoundry.io/hc/en-us/articles/360057865692-Installing-Docker-and-docker-compose-for-Ubuntu-20-04).

# Get the code

Pull down this repository.

```
git clone https://github.com/greymass/docker-nodeos.git
cd docker-nodeos
```

# Configuration

To configure these containers, you'll first need to copy the example `.env` file into the root of the project. You can then change the variables in this file to impact both the building of the container as well as its startup.

```
cp configs/example.env ./.env
```

This file contains the following parameters:

```
# The git repository of the nodeos (EOSIO) repository to use
NODEOS_REPOSITORY=https://github.com/EOSIO/eos.git

# The branch/tag of nodeos to checkout during the build process
NODEOS_VERSION=v2.1.0

# A snapshot (compressed as tar.gz) to use during the startup of this node
NODEOS_SNAPSHOT=https://snapshots.greymass.network/jungle/latest.tar.gz

# Peers to inject into the nodeos configuration 
NODEOS_PEERS=peer.jungle3.alohaeos.com:9876 jungle.eosn.io:9876 jungle3.eosrio.io:58012
```

The second thing you'll need to configure is the nodeos configuration file itself. Create a copy of this configuration file as outlined below, and it'll be passed to the container for use.

```
cp configs/example.config.ini configs/config.ini
```

This file is your standard nodeos configuration. More information is available on the [official documentation](https://developers.eos.io/manuals/eos/v2.0/nodeos/usage/nodeos-configuration).

# Build the container

During your first run and any time afterwards which you make changes to the configuration files, you'll need to rebuild the containers. Run the following command to kick off the build process.

```
docker-compose build
```

# Run the container

With the containers build, now you just need to run them.

```
docker-compose up -d
```

The nodeos instance within the container will bind to the ports on the host as defined in the `docker-compose.yaml` file. 

# Stop the container

If you need to stop the container:

```
docker-compose down
```