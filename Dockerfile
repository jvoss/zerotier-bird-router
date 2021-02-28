# Download, build and install a Zerotier client and BIRD BGP routing daemon
# Credit for Zerotier client: https://github.com/zyclonite/zerotier-docker

ARG ALPINE_VERSION=latest
ARG ZT_VERSION=1.6.4

FROM alpine:${ALPINE_VERSION} AS builder

# Download and build ZeroTier
RUN apk add --update alpine-sdk linux-headers \
    && git clone --quiet https://github.com/zerotier/ZeroTierOne.git /src \
    && git -C src reset --quiet --hard ${ZT_VERSION} \
    && cd /src \
    && make -f make-linux.mk

# RUN apk add --update --no-cache libc6-compat libstdc++

FROM alpine:${ALPINE_VERSION}

LABEL maintainer="jvoss@onvox.net"
LABEL description="ZeroTier BGP Route Server"

RUN apk add --update --no-cache libc6-compat libstdc++

EXPOSE 9993/udp

COPY --from=builder /src/zerotier-one /usr/sbin/
RUN mkdir -p /var/lib/zerotier-one \
    && ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool \
    && ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-cli

ENTRYPOINT [ "zerotier-one" ]
