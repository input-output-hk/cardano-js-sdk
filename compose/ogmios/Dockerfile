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
# TODO: We don’t have aarch64-linux GHC in IOG cache yet, but we can use Angermann’s cache to reduce build time:
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ] ; then \
    armSubstituter="https://cache.zw3rk.com" ;\
    armSubstituterKey="loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk=" ;\
  fi && curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/v0.11.0 | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --extra-conf "filter-syscalls = false" \
  --extra-conf "substituters = https://cache.nixos.org https://cache.iog.io ${armSubstituter}" \
  --extra-conf "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= ${armSubstituterKey}" \
  --init none --no-confirm
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
RUN mkdir -p /app
WORKDIR /app
ARG OGMIOS_VERSION
ARG CARDANO_NODE_VERSION
RUN echo >/app/default.nix $'\n\
  let\n\
    system = "'"$([ "$TARGETPLATFORM" = "linux/arm64" ] && echo "aarch64-linux" || echo "x86_64-linux")"$'";\n\
    _nodeFlake = builtins.getFlake "github:input-output-hk/cardano-node/'"${CARDANO_NODE_VERSION}"$'";\n\
    pkgs = _nodeFlake.inputs.nixpkgs.legacyPackages.${system};\n\
    ogmiosSrc = pkgs.stdenvNoCC.mkDerivation (removeAttrs (pkgs.fetchgit {\n\
      url = "https://github.com/CardanoSolutions/ogmios.git";\n\
      rev = "'"${OGMIOS_VERSION}"$'";\n\
      fetchSubmodules = true;\n\
    }).drvAttrs ["outputHashAlgo" "outputHashMode" "outputHash"] // { __noChroot = true; });\n\
    # Note: some versions don’t link statically for AArch64, let’s use dynamically linked bundles:\n\
    nix-bundle-exe = import (fetchTarball "https://github.com/3noch/nix-bundle-exe/archive/3522ae68aa4188f4366ed96b41a5881d6a88af97.zip") { inherit pkgs; };\n\
    enableAArch64 = original: supportedSystemsPath:\n\
      if system == "x86_64-linux" then original\n\
      else if system == "aarch64-linux" then let\n\
        patched = pkgs.runCommandNoCC "patched" {} "cp -r ${original} $out && chmod -R +w $out && echo ${with pkgs; with lib; escapeShellArg (__toJSON [system])} >$out/${supportedSystemsPath}";\n\
      in (import _nodeFlake.inputs.flake-compat {\n\
        src = {\n\
          inherit (patched) outPath;\n\
          inherit (original) rev shortRev lastModified lastModifiedDate;\n\
        };\n\
      }).defaultNix else throw "unsupported system: ${system}";\n\
    nodeFlake = enableAArch64 _nodeFlake "nix/supported-systems.nix";\n\
    inherit (nodeFlake.legacyPackages.${system}) haskell-nix;\n\
    # Note: some Ogmios versions incorrectly set `external-libsodium-vrf`, and some have `cabal.project.freeze`:\n\
    patchedOgmiosSrc = pkgs.runCommandNoCC "ogmios-src" {} (\n\
      "cp -r ${ogmiosSrc} $out && chmod -R +w $out "\n\
      + " && find $out -name cabal.project.freeze -delete -o -name package.yaml -delete "\n\
      + " && grep -RF -- -external-libsodium-vrf $out | cut -d: -f1 | sort --uniq | xargs -n1 -- sed -r s/-external-libsodium-vrf//g -i"\n\
    );\n\
    project = haskell-nix.project {\n\
      compiler-nix-name = "ghc8107";\n\
      projectFileName = "cabal.project";\n\
      inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = nodeFlake.inputs.CHaP; };\n\
      src = patchedOgmiosSrc + "/server";\n\
      modules = [ ({ lib, pkgs, ... }: {\n\
        packages.cardano-crypto-praos.components.library.pkgconfig = lib.mkForce [ [ pkgs.libsodium-vrf ] ];\n\
        packages.cardano-crypto-class.components.library.pkgconfig = lib.mkForce [ ([ pkgs.libsodium-vrf pkgs.secp256k1 ]\n\
          ++ (if pkgs ? libblst then [pkgs.libblst] else [])) ];\n\
      }) ];\n\
    };\n\
  in\n\
  # cardano-node doesn’t build for ARM before 1.35.7:\n\
  assert system != "aarch64-linux" || _nodeFlake.sourceInfo.lastModifiedDate >= "20230328184650";\n\
  {\n\
    cardano-node = nix-bundle-exe nodeFlake.packages.${system}.cardano-node;\n\
    ogmios       = nix-bundle-exe project.hsPkgs.ogmios.components.exes.ogmios;\n\
    ogmiosSrc    = patchedOgmiosSrc;\n\
  }\n\
  ' && cat /app/default.nix
RUN nix-build /app/default.nix -A ogmiosSrc -o /app/ogmios-src
RUN nix-build /app/default.nix -A ogmios -o /app/ogmios
# Note: ‘inputoutput/cardano-node’ doesn’t have all commits published, but we want to allow specifying
#       any commit, so we have to build from source.
RUN nix-build /app/default.nix -A cardano-node -o /app/cardano-node
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
RUN mkdir -p /opt
COPY --from=haskell-builder /app/ogmios       /opt/ogmios
COPY --from=haskell-builder /app/cardano-node /opt/cardano-node
RUN ln -s /opt/ogmios/bin/ogmios /opt/cardano-node/bin/cardano-node /bin/ &&\
  cardano-node --version && ogmios --version  # check that they are not missing any shared objects
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
