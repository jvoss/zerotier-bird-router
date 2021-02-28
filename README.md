ZeroTier BIRD Router in Docker
==============================

![Docker image](https://github.com/jvoss/zerotier-bird-router/actions/workflows/docker-image.yml/badge.svg)

This docker container runs the [ZeroTier](https://www.zerotier.com/) client and 
[BIRD 2.0](https://bird.network.cz/) routing daemon. This is useful for running 
a BGP router attached to ZeroTier network.

The image is built on Alpine Linux to keep deployment size minimal.

For a Zerotier only client in docker see 
[zerotier-docker](https://github.com/zyclonite/zerotier-docker) which served as
the inspriation for the included ZeroTier client.

## Installation

### From Docker Hub

1) Pull image from Docker Hub

    `docker pull jpvoss/zerotier-bird-router`

### Building an image

1) Clone to local machine

    `git clone https://github.com/jvoss/zerotier-bird-router.git`

2) Build the image

  * Option A: Included versions of ZeroTier and BIRD2

    `docker build -t zerotier-bird-router .`

  * Option B: Specific versions of ZeroTier and/or BIRD2

    `docker build -t zerotier-bird-router . --build-arg BIRD_VERSION=2.0.7 ZEROTIER_VERSION=1.6.4`

### Docker Compose

See example [docker-compose.yml](docker-compose.yml) for details.

## Configuration

### ZeroTier

ZeroTier configuration can be accessed via CLI interactively with the container
or by issuing commands to to the container:

Interactive shell:
```
docker exec -it <CONTAINER> /bin/sh
zerotier-cli listpeers
```

From Host:
```
docker exec <CONTAINER> zerotier-cli listpeers
```

Configuration persistence across restart is maintained by mounting a volume to:
`/var/lib/zerotier-one` (See [Running](#running))

### BIRD2

BIRD2 is installed in `/opt/bird` and configuration should be mounted to 
`/opt/bird/etc` prior to starting the container.

See the [BIRD](https://bird.network.cz/?get_doc&f=bird.html&v=20) project
documentation for more details.

Interactive shell:
```
docker exec -it <CONTAINER> birdc
```

Commands from Host:
```
docker exec <CONTAINER> birdc show protocols
```

## Running

Special permissions (`NET_ADMIN`) and access to `/dev/nut/tun` are required
to allow Zerotier to create tunnel interfaces:

Docker >1.2.0:

```
  docker run --device=/dev/net/tun --cap-add=NET_ADMIN \
         -v <peristed zerotier configuration volume>:/var/lib/zerotier-one \
         -v <peristed BIRD configuration volume>:/opt/bird/etc \
         jvoss/zerotier-route-server
```
