ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION} as builder

ENV DEBIAN_FRONTEND=nonintercative

WORKDIR /build
ARG CARDANO_NODE_BUILD_URL=https://github.com/IntersectMBO/cardano-node/releases/download/9.0.0/cardano-node-9.0.0-linux.tar.gz
ARG CARDANO_CLI_BUILD_URL=https://github.com/IntersectMBO/cardano-cli/releases/download/cardano-cli-9.0.0.1/cardano-cli-9.0.0.1-x86_64-linux.tar.gz
ARG CARDANO_NODE_BUILD_URL_ARM64=https://github.com/input-output-hk/ogmios-tracker/releases/download/0.1.0/cardano-node-9.0.0-aarch64-linux.tar.gz

# Use local cardano-cli until it is available in the official release
COPY cardano-cli-x86_64-linux.zip cardano-cli-x86_64-linux.zip

RUN set -x && \
  apt-get update -y && \
  apt-get install -y wget tar curl unzip && \
  if [ "$(uname -m)" = "aarch64" ] ; then \
    curl -fsSL "$CARDANO_NODE_BUILD_URL_ARM64" >cardano-node.tar.gz ;\
    else \
    curl -fsSL "$CARDANO_NODE_BUILD_URL" >cardano-node.tar.gz ;\
  fi && \
  mkdir -p cardano-node && \
  tar -xzf cardano-node.tar.gz -C cardano-node && \
  if [ "$(uname -m)" = "x86_64" ] ; then \
    echo "======== Check if we want a custom cardano-cli ========" &&\
    if [ -f cardano-cli-x86_64-linux.zip ] ; then \
      echo "======== Using local cardano-cli ========" && \
      unzip cardano-cli-x86_64-linux.zip ;\
    elif [ -n "$CARDANO_CLI_BUILD_URL" ] ; then \
      echo "======== Using released cardano-cli ========" && \
      curl -fsSL "$CARDANO_CLI_BUILD_URL" >cardano-cli.tar.gz && \
      tar -xzf cardano-cli.tar.gz ;\
    fi && \
    if [ -f cardano-cli-x86_64-linux ] ; then \
      echo "======== Using a custom Cardano Node cardano-cli ========" && \
      chown $(stat -c "%u:%g" cardano-node/bin/cardano-cli) cardano-cli-x86_64-linux && \
      chmod +x cardano-cli-x86_64-linux && \
      mv cardano-cli-x86_64-linux cardano-node/bin/cardano-cli ;\
    fi ;\
  fi


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
