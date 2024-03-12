FROM nixos/nix AS nix-configured
# prepare the base nix image with our nix.conf
# this is done in a separate stage since we want nix.conf picked up in the next stage

RUN nix-channel --update
COPY ./compose/smash/nix/nix.conf /etc/nix/nix.conf

FROM nix-configured as nix-builder

ENV NETWORK=${NETWORK:-"mainnet"}

# checkout the source
RUN git clone --depth 1 --branch ${CARDANO_DB_SYNC_VERSION:-13.1.0.0} \
    https://github.com/IntersectMBO/cardano-db-sync.git
WORKDIR cardano-db-sync

# build the binary
RUN nix build .#cardano-smash-server:exe:cardano-smash-server --accept-flake-config
RUN nix profile install .#cardano-smash-server:exe:cardano-smash-server --impure
RUN nix-store --gc

# prepare the configuration
COPY packages/cardano-services/config/network/${NETWORK}/cardano-db-sync /config/
COPY compose/placeholder-secrets/smash-admins.txt /config/
COPY compose/smash/init.sh /bin

RUN chmod 755 /bin/init.sh

ENTRYPOINT ["/bin/init.sh"]
