# district-deployments

This project contains docker images and docker-compose scripts for deploying districts to different environments.

## Requirements

You need [Docker](https://www.docker.com/) installed.

```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo apt-key add -

export LSB_ETC_LSB_RELEASE=/etc/upstream-release/lsb-release

V=$(lsb_release -cs)

sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${V} stable"

sudo apt-get update -y

sudo apt-get install -y docker-ce
```

Add your user to the docker group. Added user can run docker command without sudo command:
```bash
sudo gpasswd -a "${USER}" docker
```

Test the installation:
```bash
docker run hello-world
```

You also need docker-compose:
``` bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod a+x /usr/local/bin/docker-compose
```

## Usage

- [QA enviroment](#qa)
  - [parity]()
    - [parity](#parity)
    - [ropsten](#parity-ropsten)
  - [ipfs](#ipfs)
    - [daemon](#ipfs-daemon)
          - [update scripts](#update-scripts)
    - [api](#ipfs-api)
    - [gateway](#)
  - [memefactory](#memfactory)
    - [server](#memfactory-server)
    - [api](#memefactory-api)
    - [ui](#memefactory-ui)
- [base](#base)

## <a name="qa"> QA enviroment </a>

Start the services (but parity) in the QA environment:

``` bash
cd qa/
docker-compose -f docker-compose.yml \
               -f memefactory/docker-compose.yml up -d
```

## <a> parity services </a>

Parity service is currently a systemd service instead of docker service because of weird behavior when running inside a docker container.

### <a name="parity"> parity </a>

For starting, stopping, status checking of parity service you can use

```bash
sudo systemctl status parity
sudo systemctl stop parity
sudo systemctl start parity
```

It will run `/home/ubuntu/run_parity.sh`

Service configuration file is `/etc/systemd/system/parity.service`

It will expose parity's JSON rpc on port 8545.

## <a name="ipfs"> ipfs services </a>

### <a name="ipfs-daemon"> ipfs daemon </a>

This service provides the ipfs daemon.
No ports are exposed to the host, and the containers that wish to have access to ipfs should join the `ipfs-net` network.

*NOTE*

[IPNS](https://docs.ipfs.io/guides/concepts/ipns/) is used for storing all static content, allowing for seemless updates without changing any configuration.

Private keys are used to keep track of the content published under the same IPNS hashes (peer ids), and they are stored in a `data` volume shared between container and the host.

In order to publish new content you need to generate new key:

```bash
ipfs key gen --type=rsa --size=2048 <my-district-qa>
```

and store it in the host directory `/home/$USER/ipfs-docker/`.

You should also add an executable [update script](https://github.com/district0x/deployments/blob/master/qa/ipfs/daemon/update-memefactory-ui.sh) to the image of this container, which publishes the new content under the corresponding peer-id:

```bash
docker exec -it qa_ipfs-daemon <update-my-district>
```

#### <a name="update-scripts"> update scripts </a>

* updating MemeFactory static content served by the UI [container](#memefactory-ui):

```bash
docker exec -it qa_ipfs-daemon update-memefactory-ui
```

### <a name="ipfs-api"> ipfs api </a>

This container exposes IPFS http API on port 5001 to the host.

### <a name="ipfs-gateway"> ipfs gateway </a>

This container exposes IPFS read-only gateway on port 8080 to the host.

## <a name="memefactory"> memefactory services </a>

These containers define all the services needed for running the [MemeFactory](http://memefactory.io) district.

### <a name="memfactory-server"> memefactory server </a>

This service is the server component of MemeFactory, which serves as cache for Blockchain events, it also runs a graphql endpoint.
No ports are exposed to the host, and the containers that wish to have direct access should join the `memefactory-net` network.

### <a name="memefactory-api"> memfactory api </a>

This container exposes the graphql API of MemeFactory on host's port 6300.

### <a name="memefactory-ui"> memefactory ui </a>

This container serves the content published under the memefactory-qa peer-id on the host's port 80.
See [ipfs-daemon](#ipfs-daemon) container for updating this content.

## <a name="base"> base image </a>

Base image for docker district0x services availiable on [dockerhub](https://hub.docker.com/r/district0x/base/).
Contains all dependencies needed for running and building districts service components.
Consult the image file for details of whats availiable.
