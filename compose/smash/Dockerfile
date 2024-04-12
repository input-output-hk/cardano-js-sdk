ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION}

ARG DBSYNC_BINARY_URL="https://update-cardano-mainnet.iohk.io/cardano-db-sync/cardano-db-sync-${CARDANO_DB_SYNC_VERSION:-13.1.0.0}-linux.tar.gz"
ARG DBSYNC_BINARY_URL_ARM64="https://github.com/input-output-hk/ogmios-tracker/releases/download/0.1.0/cardano-db-sync-13.1.0.0-aarch64-linux.tar.gz"
ENV NETWORK=${NETWORK:-"mainnet"}

RUN apt-get update && apt-get install curl -y

RUN set -x ; if [ "$(uname -m)" = "aarch64" ] ; then \
      curl -sfL "${DBSYNC_BINARY_URL_ARM64}" --output /tmp/dbsync-binary.tar.gz &&\
      mkdir -p /opt/cardano-db-sync &&\
      tar -xzf /tmp/dbsync-binary.tar.gz -C /opt/cardano-db-sync &&\
      rm /tmp/dbsync-binary.tar.gz &&\
      ln -sf /opt/cardano-db-sync/bin/* /bin/ ;\
    else \
      curl -sfL "${DBSYNC_BINARY_URL}" --output /tmp/dbsync-binary.tar.gz &&\
      tar --extract --file /tmp/dbsync-binary.tar.gz --directory /bin ./cardano-smash-server &&\
      rm /tmp/dbsync-binary.tar.gz ;\
    fi

COPY packages/cardano-services/config/network/${NETWORK}/cardano-db-sync /config/

COPY compose/placeholder-secrets/smash-admins.txt /config/
COPY compose/smash/init.sh /bin
RUN chmod 755 /bin/init.sh

ENTRYPOINT ["init.sh"]
