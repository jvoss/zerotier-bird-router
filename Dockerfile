# Download, build and install a Zerotier client and BIRD BGP routing daemon
# Credit for Zerotier client: https://github.com/zyclonite/zerotier-docker

ARG ALPINE_VERSION=latest
ARG BIRD_VERSION=2.0.7
ARG ZEROTIER_VERSION=1.6.4

FROM alpine:${ALPINE_VERSION} AS builder

# Download and build ZeroTier
RUN apk add --update alpine-sdk linux-headers \
    && git clone --quiet https://github.com/zerotier/ZeroTierOne.git /src/zt \
    && git -C /src/zt reset --quiet --hard ${ZEROTIER_VERSION} \
    && cd /src/zt \
    && make -f make-linux.mk

# Download and build BIRD Internet Routing Daemon
RUN apk add autoconf bison build-base flex ncurses-dev perl readline-dev \
    && git clone --quiet https://gitlab.nic.cz/labs/bird.git /src/bird \
    && git -C /src/bird reset --quiet --hard `echo ${BIRD_VERSION} | sed 's/v//g'` \
    && cd /src/bird \
    && autoreconf \
    && ./configure --prefix /opt/bird \
    && make \
    && make install    

FROM alpine:${ALPINE_VERSION}

LABEL maintainer="jvoss@onvox.net"
LABEL description="ZeroTier BGP Route Server"

RUN apk add --update --no-cache libc6-compat libstdc++ readline ncurses

EXPOSE 9993/udp

COPY --from=builder /src/zt/zerotier-one /usr/sbin/
COPY --from=builder /opt/bird /opt/bird
COPY entrypoint.sh /

RUN mkdir -p /var/lib/zerotier-one; \
    ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool; \
    ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-cli; \
    adduser --system bird; \
    chown -R bird:root /opt/bird

ENV PATH="${PATH}:/opt/bird/sbin"

ENTRYPOINT [ "/entrypoint.sh" ]
