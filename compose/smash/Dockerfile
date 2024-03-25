ARG ALPINE_VERSION=3.14

FROM alpine:${ALPINE_VERSION} AS nix-builder

RUN apk add --no-cache curl
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/v0.11.0 | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --extra-conf "substituters = https://cache.nixos.org https://cache.iog.io" \
  --extra-conf "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" \
  --init none --no-confirm

# build the binary
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && \
    nix build github:input-output-hk/cardano-db-sync/${CARDANO_DB_SYNC_VERSION:-13.1.0.0}#static/cardano-smash-server


FROM alpine:${ALPINE_VERSION} AS smash-runtime

# curl used for Docker healthcheck
RUN apk add --no-cache curl

# copy the static linked binary from the build step
COPY --from=nix-builder /nix/store/r0gnc88dcsx4njcg8bz7fs8diqnpg5yr-cardano-smash-server-exe-cardano-smash-server-x86_64-unknown-linux-musl-${CARDANO_DB_SYNC_VERSION:-13.1.0.0}/bin/cardano-smash-server \
     /bin/cardano-smash-server

COPY compose/placeholder-secrets/smash-admins.txt /smash-config/
COPY compose/smash/init.sh /bin

RUN chmod 755 /bin/init.sh

ENTRYPOINT ["/bin/init.sh"]

