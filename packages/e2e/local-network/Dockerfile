ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION} as builder

ENV DEBIAN_FRONTEND=nonintercative

WORKDIR /build
ARG CARDANO_NODE_BUILD_URL=https://github.com/IntersectMBO/cardano-node/releases/download/8.9.2/cardano-node-8.9.2-linux.tar.gz
ARG CARDANO_NODE_BUILD_URL_ARM64=https://github.com/input-output-hk/ogmios-tracker/releases/download/0.1.0/cardano-node-8.9.2-aarch64-linux.tar.gz

RUN apt-get update -y && \
    apt-get install -y wget tar curl && \
    if [ "$(uname -m)" = "aarch64" ] ; then \
      curl -fsSL "$CARDANO_NODE_BUILD_URL_ARM64" >cardano-node.tar.gz ;\
    else \
      curl -fsSL "$CARDANO_NODE_BUILD_URL" >cardano-node.tar.gz ;\
    fi && \
    mkdir -p cardano-node && \
    tar -xzf cardano-node.tar.gz -C cardano-node

FROM ubuntu:${UBUNTU_VERSION}

WORKDIR /root
RUN apt-get update -y && \
  apt-get install -y tzdata ca-certificates jq coreutils curl wget

HEALTHCHECK --interval=5s --timeout=1s --retries=200 --start-period=100ms \
  CMD test -e /root/network-files/run/healthy

STOPSIGNAL SIGINT
COPY --from=builder /build/cardano-node /opt/cardano-node
ARG TINI_VERSION=v0.19.0
RUN mkdir -p ./bin && ln -s /opt/cardano-node/bin/* ./bin/ &&\
    if [ "$(uname -m)" = "aarch64" ] ; then \
      TINI_VARIANT=static-arm64 ;\
    else \
      TINI_VARIANT=static-amd64 ;\
    fi &&\
    curl -fsSL >/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TINI_VARIANT} &&\
    chmod +x /tini

COPY scripts scripts
COPY templates templates
ENTRYPOINT ["/tini", "-g", "--", "/root/scripts/start.sh" ]
