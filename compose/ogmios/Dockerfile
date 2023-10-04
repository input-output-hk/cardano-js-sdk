ARG CARDANO_NODE_VERSION=8.1.2
ARG OGMIOS_VERSION=f40a8921906fecae4c52ffff34fb011457f9a771
ARG CARDANO_CONFIG_VERSION=65ef979cf69f420efca0a7aaf0412a610bc48097
ARG NETWORK=mainnet
ARG TARGETPLATFORM=linux/amd64

FROM --platform=${TARGETPLATFORM} alpine:3.18 as haskell-builder
ARG TARGETPLATFORM
LABEL name=ogmios
LABEL description="A JSON WebSocket bridge for cardano-node."
RUN apk update && apk add curl git
# Note: `sandbox = false` is for compatibility with Podman, Docker doesn’t require it.
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/v0.11.0 | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --extra-conf "substituters = https://cache.nixos.org https://cache.iog.io" \
  --extra-conf "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" \
  --init none --no-confirm
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
RUN mkdir -p /app
WORKDIR /app
ARG OGMIOS_VERSION
ARG CARDANO_NODE_VERSION
RUN cd /app &&\
  git clone --recursive https://github.com/CardanoSolutions/ogmios.git ogmios-src &&\
  cd ogmios-src &&\
  git fetch --all --tags &&\
  git checkout ${OGMIOS_VERSION}
RUN echo >/app/default.nix $'\n\
  let\n\
    nodeFlake = builtins.getFlake "github:input-output-hk/cardano-node/'"${CARDANO_NODE_VERSION}"$'";\n\
    system = "'"$([ "$TARGETPLATFORM" = "linux/arm64" ] && echo "aarch64-linux" || echo "x86_64-linux")"$'";\n\
    inherit (nodeFlake.legacyPackages.${system}) haskell-nix;\n\
    ogmiosSrc = nodeFlake.inputs.nixpkgs.legacyPackages.${system}.runCommand "ogmios-src" {} (\n\
      "cp -r ${./ogmios-src} $out && chmod -R +w $out "\n\
      + " && find $out -name cabal.project.freeze -delete -o -name package.yaml -delete "\n\
      + " && grep -RF -- -external-libsodium-vrf $out | cut -d: -f1 | sort --uniq | xargs -n1 -- sed -r s/-external-libsodium-vrf//g -i"\n\
    );\n\
    project = haskell-nix.project {\n\
      compiler-nix-name = "ghc8107";\n\
      projectFileName = "cabal.project";\n\
      inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = nodeFlake.inputs.CHaP; };\n\
      src = ogmiosSrc + "/server";\n\
      modules = [ ({ lib, pkgs, ... }: {\n\
        packages.cardano-crypto-praos.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf ] ];\n\
        packages.cardano-crypto-class.components.library.pkgconfig = lib.mkForce [ ([ pkgs.libsodium-vrf pkgs.secp256k1 ]\n\
          ++ (if pkgs ? libblst then [pkgs.libblst] else [])) ];\n\
      }) ];\n\
    };\n\
  in {\n\
    ogmios = project.projectCross.musl64.hsPkgs.ogmios.components.exes.ogmios;\n\
    cardano-node = nodeFlake.legacyPackages.${system}.hydraJobs.musl.cardano-node;\n\
  }\n\
  ' && cat /app/default.nix
RUN nix-build /app/default.nix -A ogmios -o /app/ogmios
# Note: ‘inputoutput/cardano-node’ doesn’t have all commits published, but we want to allow specifying
#       any commit, so we have to build from source.
RUN nix-build /app/default.nix -A cardano-node -o /app/cardano-node
RUN ls -alh /app/ogmios/bin
RUN ls -alh /app/cardano-node/bin
RUN /app/ogmios/bin/ogmios --help
RUN /app/cardano-node/bin/cardano-node --version
ARG CARDANO_CONFIG_VERSION
RUN git clone https://github.com/input-output-hk/cardano-configurations.git /app/cardano-configurations &&\
  cd /app/cardano-configurations &&\
  git fetch --all --tags &&\
  git checkout ${CARDANO_CONFIG_VERSION} &&\
  # Note: remove this when a valid preprod conway genesis is available
  cp -f ./network/sanchonet/genesis/conway.json ./network/preprod/genesis/ &&\
  cat ./network/preprod/genesis/conway.json
RUN sed -r 's/("ConwayGenesisHash":\s*")[^"]+/\15145f03e6bf046fa81c91c408719a99848a33d4b35f29f1b5f1fada7f24e6664/g' -i /app/cardano-configurations/network/preprod/cardano-node/config.json

FROM --platform=${TARGETPLATFORM} alpine:3.18 as cardano-node-ogmios
RUN apk update && apk add bash tini && rm -rf /var/cache/apk/*
COPY --from=haskell-builder /app/ogmios/bin/ogmios /bin/ogmios
COPY --from=haskell-builder /app/cardano-node/bin/cardano-node /bin/cardano-node
RUN cardano-node --version && ogmios --version  # check that they are indeed statically linked
ARG NETWORK
LABEL name=cardano-node-ogmios
LABEL description="A Cardano node, side-by-side with its JSON WebSocket bridge."
COPY --from=haskell-builder /app/cardano-configurations/network/${NETWORK} /config
RUN ls /config && cat /config/genesis/conway.json
RUN mkdir -p /ipc
WORKDIR /root
# Ogmios, cardano-node, ekg, prometheus
EXPOSE 1337/tcp 3000/tcp 12788/tcp 12798/tcp
HEALTHCHECK --interval=10s --timeout=5s --retries=1 CMD /bin/ogmios health-check
STOPSIGNAL SIGINT
COPY ./cardano-node-ogmios.sh cardano-node-ogmios.sh
RUN ["chmod", "+x", "/root/cardano-node-ogmios.sh"]
RUN ln -s /sbin/tini /tini
ENTRYPOINT ["tini", "-g", "--", "/root/cardano-node-ogmios.sh" ]
