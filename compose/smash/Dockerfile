ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION}

ARG DBSYNC_BINARY_URL="https://update-cardano-mainnet.iohk.io/cardano-db-sync/cardano-db-sync-${CARDANO_DB_SYNC_VERSION:-13.1.0.0}-linux.tar.gz"
ENV NETWORK=${NETWORK:-"mainnet"}

RUN apt-get update && apt-get install curl -y
RUN curl ${DBSYNC_BINARY_URL} --output /tmp/dbsync-binary.tar.gz &&\
  tar --extract --file /tmp/dbsync-binary.tar.gz --directory /bin ./cardano-smash-server &&\
  rm /tmp/dbsync-binary.tar.gz

COPY packages/cardano-services/config/network/${NETWORK}/cardano-db-sync /config/

COPY compose/placeholder-secrets/smash-admins.txt /config/
COPY compose/smash/init.sh /bin
RUN chmod 755 /bin/init.sh

ENTRYPOINT ["init.sh"]
