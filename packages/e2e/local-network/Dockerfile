FROM debian:11-slim as builder

WORKDIR /build
ARG CARDANO_NODE_BUILD_URL=https://hydra.iohk.io/build/13065769/download/1/cardano-node-1.34.1-linux.tar.gz
RUN apt-get update -y && \
  apt-get install -y wget tar && \
  wget $CARDANO_NODE_BUILD_URL -O cardano-node.tar.gz && \
  mkdir -p bin && \
  tar -xzf cardano-node.tar.gz -C bin

FROM debian:11-slim

WORKDIR /root
RUN apt-get update -y && \
  apt-get install -y tzdata ca-certificates
COPY --from=builder /build/bin ./bin
COPY . .
CMD ["./scripts/start.sh"]
