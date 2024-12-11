# Notice

The `master` branch by default on this repository is for [Antelope/Leap@3.1](https://github.com/antelopeio/leap). If you are looking for a version that works with [EOSIO/EOS@2.x](https://github.com/eosio/eos), please check out the [v2.x branch](https://github.com/greymass/docker-nodeos/tree/v2.x) of this repository.

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
cp configs/docker/default.env .env
```

This file contains the following parameters:

```
# The name of the network this environment is for (must be unique on the host machine)
NETWORK_NAME=jungle

# The port to expose the nodeos api(s) on the host machine
NETWORK_PORT_API=8888

# The port to expose the nodeos p2p procotol on the host machine
NETWORK_PORT_P2P=9876

# The git repository of the nodeos (EOSIO) repository to use
NODEOS_REPOSITORY=https://github.com/AntelopeIO/spring.git

# The branch/tag of nodeos to checkout during the build process
NODEOS_VERSION=v1.0.3

# A snapshot (compressed as tar.gz) to use during the startup of this node
NODEOS_SNAPSHOT=https://snapshots.greymass.network/jungle/latest.tar.gz

# Peers to inject into the nodeos configuration 
NODEOS_PEERS=peer.jungle3.alohaeos.com:9876 jungle.eosn.io:9876 jungle3.eosrio.io:58012
```

The second thing you'll need to configure is the nodeos configuration file itself. Create a copy of this configuration file as outlined below, and it'll be passed to the container for use.

```
cp configs/nodeos/example-minimal-api.config.ini configs/config.ini
```

This file is your standard nodeos configuration. More information is available on the [official documentation](https://docs.eosnetwork.com/docs/latest/node-operation/getting-started/).

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

# Additional Predefined Configurations

A number of configurations have been setup for different methods of operation. Listed below are list of these configurations as well as the commands to quickly spin up that instance type.

### API (Minimal)

This is the default configuration shown in the documentation above. This type of configuration launches one or more nodeos processes from a snapshot and load balances API requests between them. They also are configured to only keep 1 days worth of recent blocks and have the account query API enabled.

This API configuration is meant to serve out most requests, with the exception being they won't be able to serve out older blocks (v1/chain/get_block).

```bash
cp configs/docker/default.env .env
cp configs/nodeos/example-minimal-api.config.ini configs/config.ini
```

Once copied, edit these configuration files (if needed).

If you had previously used the `docker-compose.override.yaml` file for another configuration, clear that out.

```bash
git reset --hard docker-compose.override.yaml
```

Then build, and start it up:

```
docker-compose build
docker-compose up
```

### API (Minimal) + nginx

The above configuration can also be used to scale up multiple API instances, which can be load balanced behind nginx. To use this configuration you'll need to copy the example `nginx.conf` into place and make any modifications you may need.

```bash
cp configs/nginx/nginx.conf configs/nginx.conf
```

When starting, you'll just need to pass an extra parameter into the `docker-compose up` command outlined in the previous example.

```bash
docker-compose build
docker-compose --profile nginx up
```

If you'd like to scale up to multiple instances, you'll use the `--scale` option in the `docker-compose up` command.

```bash
docker-compose build
docker-compose --profile nginx up --scale nodeos=2
```

### P2P Relay (Minimal)

This configuration launches a single nodeos instance from a snapshot with only the p2p network enabled. This can be used as a p2p relay for multiple API node instances to prevent excess network chatter. Since it is launched from a snapshot it won't be useful in resyncing blocks to other nodes in the p2p network.

To use this repository to setup one of these instances, copy and modify the configuration for nodeos. Perform these commands from the root directly of the repository:

```bash
cp configs/docker/default.env .env
cp configs/nodeos/example-minimal-p2p.config.ini configs/config.ini
```

Once copied, edit these configuration files (if needed).

Then modify the `docker-compose.override.yaml` file to contain the following information:

```yaml
version: '3.6'
services:
    nodeos:
        extends:
            file: ./configs/docker/nodeos-minimal-p2p.yaml
            service: nodeos
```

Then build, and start it up:

```
docker-compose build
docker-compose up
```

# Reload nginx upstreams

```
docker-compose exec nginx nginx -s reload
```

# Logging

A `logging.json` file can now be added to the `./configs` folder of the project to create a custom nodeos logging configuration.

The file placed in this location will be included during the build process and used as nodeos starts up.

### Remote endpoint for logging.json

With this docker configuration designed to be scalable to multiple instances, a simple `logging.json` copy into the `configs` folder won't be able to identify individual containers.

For this reason, you can now input those values into the `.env` file:

```
# Remote Logging - Endpoint
NODEOS_LOGGING_ENDPOINT=www.your.server.com:12201

# Remote Logging - Operator Name
NODEOS_LOGGING_OPERATOR=operator_name

# Remote Logging - Network Name
NODEOS_LOGGING_NETWORK=jungle4
```

When these values are found in the `.env` file, the initialization process of each container will modify the `logging.json` file to inject values relevant to each container. The resulting output will be similar to:

```
{
    "name": "net",
    "type": "gelf",
    "args": {
        "endpoint": "NODEOS_LOGGING_ENDPOINT",
        "host": "${NETWORK}${HOSTNAME}",
        "_operator": "NODEOS_LOGGING_OPERATOR",
        "_network": "NODEOS_LOGGING_NETWORK"
    },
    "enabled": false
}
```
