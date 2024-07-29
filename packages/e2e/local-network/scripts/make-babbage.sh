#!/usr/bin/env bash

set -e
# Unofficial bash strict mode.
# See: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -u
set -o pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root_path="$(cd "$here/.." && pwd)"
cd "$root_path"

export PATH=$PWD/bin:$PATH

source ./scripts/nodes-configuration.sh

# We need this when running in Docker Desktop on macOS. `sed -i` doesn’t work well with VOLUMEs
# there, unless it can create its temporary files outside of a VOLUME, which requires $TMPDIR.
export TMPDIR="${TMPDIR:-/tmp}"
export TMP="${TMP:-/tmp}"

UNAME=$(uname -s)

# Normal `sed -i` is a bit stubborn, and really wants to create its temporary files in the
# directory of the target file. It is not a true in-place edit, and often braks permissions.
# Let’s use this wrapper instead.
sed_i() {
    local tmpfile=$(mktemp)
    local sed_bin=sed
    if [ "$UNAME" == "Darwin" ] ; then sed_bin=gsed ; fi
    if $sed_bin "$@" >"$tmpfile"; then
        cat "$tmpfile" >"${@: -1}" # Replace the last argument file (in-place file) with tmpfile content
        rm "$tmpfile"
    else
        echo "sed failed." >&2
        rm "$tmpfile"
        return 1
    fi
}

case $(uname) in
Darwin) date='gdate' ;;
*) date='date' ;;
esac
timeISO=$($date -d "now + 30 seconds" -u +"%Y-%m-%dT%H:%M:%SZ")
timeUnix=$($date -d "now + 30 seconds" -u +%s)

sprocket() {
  if [ "$UNAME" == "Windows_NT" ]; then
    # Named pipes names on Windows must have the structure: "\\.\pipe\PipeName"
    # See https://docs.microsoft.com/en-us/windows/win32/ipc/pipe-names
    echo -n '\\.\pipe\'
    echo "$1" | sed 's|/|\\|g'
  else
    echo "$1"
  fi
}

UNAME=$(uname -s) DATE=
case $UNAME in
Darwin) DATE="gdate" ;;
Linux) DATE="date" ;;
MINGW64_NT*)
  UNAME="Windows_NT"
  DATE="date"
  ;;
esac

NETWORK_MAGIC=888
SECURITY_PARAM=10
INIT_SUPPLY=10020000012
MAX_SUPPLY=45000000000000000
START_TIME="$(${DATE} -d "now + 30 seconds" +%s)"
ROOT=network-files

if test -d "${ROOT}/byron-gen-command"; then
  echo "Existing \"${ROOT}/byron-gen-command\" directory will be deleted"
  rm -rf "${ROOT}/byron-gen-command"
fi

mkdir -p "${ROOT}"

cat >"${ROOT}/byron.genesis.spec.json" <<EOF
{
  "heavyDelThd":     "300000000000",
  "maxBlockSize":    "2000000",
  "maxTxSize":       "4096",
  "maxHeaderSize":   "2000000",
  "maxProposalSize": "700",
  "mpcThd": "20000000000000",
  "scriptVersion": 0,
  "slotDuration": "1000",
  "softforkRule": {
    "initThd": "900000000000000",
    "minThd": "600000000000000",
    "thdDecrement": "50000000000000"
  },
  "txFeePolicy": {
    "multiplier": "43946000000",
    "summand": "155381000000000"
  },
  "unlockStakeEpoch": "18446744073709551615",
  "updateImplicit": "10000",
  "updateProposalThd": "100000000000000",
  "updateVoteThd": "1000000000000"
}
EOF

cardano-cli byron genesis genesis \
  --protocol-magic ${NETWORK_MAGIC} \
  --start-time "${START_TIME}" \
  --k "${SECURITY_PARAM}" \
  --n-poor-addresses 0 \
  --n-delegate-addresses "${NUM_SP_NODES}" \
  --total-balance ${INIT_SUPPLY} \
  --delegate-share 1 \
  --avvm-entry-count 0 \
  --avvm-entry-balance 0 \
  --protocol-parameters-file "${ROOT}/byron.genesis.spec.json" \
  --genesis-output-dir "${ROOT}/byron-gen-command"

# Because in Babbage the overlay schedule and decentralization parameter
# are deprecated, we must use the "create-staked" cli command to create
# SPs in the ShelleyGenesis

cp templates/babbage/alonzo-babbage-test-genesis.json "${ROOT}/genesis.alonzo.spec.json"
cp templates/babbage/conway-babbage-test-genesis.json "${ROOT}/genesis.conway.spec.json"
cp templates/babbage/byron-configuration.yaml "${ROOT}/configuration.yaml"

sed_i \
  -e 's/Protocol: RealPBFT/Protocol: Cardano/' \
  -e 's|GenesisFile: genesis.json|ByronGenesisFile: genesis/byron/genesis.json|' \
  -e '/ByronGenesisFile/ aShelleyGenesisFile: genesis/shelley/genesis.json' \
  -e '/ByronGenesisFile/ aAlonzoGenesisFile: genesis/shelley/genesis.alonzo.json' \
  -e '/ByronGenesisFile/ aConwayGenesisFile: genesis/shelley/genesis.conway.json' \
  -e 's/RequiresNoMagic/RequiresMagic/' \
  -e 's/LastKnownBlockVersion-Major: 0/LastKnownBlockVersion-Major: 6/' \
  -e 's/LastKnownBlockVersion-Minor: 2/LastKnownBlockVersion-Minor: 0/' \
  -e "s/minSeverity: Info/minSeverity: ${CARDANO_NODE_LOG_LEVEL}/" \
  -e "s/cardano.node.ChainDB: Notice/cardano.node.ChainDB: ${CARDANO_NODE_CHAINDB_LOG_LEVEL}/" \
  "${ROOT}/configuration.yaml"

echo "" >>"${ROOT}/configuration.yaml"
echo "PBftSignatureThreshold: 0.6" >>"${ROOT}/configuration.yaml"
echo "" >>"${ROOT}/configuration.yaml"

echo "TestShelleyHardForkAtEpoch: 0" >> "${ROOT}/configuration.yaml"
echo "TestAllegraHardForkAtEpoch: 0" >> "${ROOT}/configuration.yaml"
echo "TestMaryHardForkAtEpoch: 0" >> "${ROOT}/configuration.yaml"
echo "TestAlonzoHardForkAtEpoch: 0" >> "${ROOT}/configuration.yaml"
echo "TestBabbageHardForkAtEpoch: 0" >> "${ROOT}/configuration.yaml"
echo "TestConwayHardForkAtEpoch: 0" >> "${ROOT}/configuration.yaml"
echo "ExperimentalHardForksEnabled: True" >> "${ROOT}/configuration.yaml"
echo "ExperimentalProtocolsEnabled: True" >> "${ROOT}/configuration.yaml"

# TODO: Remove once mainnet is hardforked to conway-era and we don't need to run the e2e tests on pre-conway too.
# If we want the network to start in Babbage era we need to configure it to hardfork to Conway very far in the future.
# We also need to update the conway transaction cli commands to babbage cli commands.
if [ -n "$PRE_CONWAY" ]; then
  echo "Updating scripts for pre-conway eras"
  # Start in Babbage era
  sed -i '/TestConwayHardForkAtEpoch/d' ./templates/babbage/node-config.json
  sed -i '/TestConwayHardForkAtEpoch/d' ${ROOT}/configuration.yaml

  # Convert all cardano-cli conway cmds to babbage
  find ./scripts/ -type f -name "*.sh" -exec sed -i 's/cardano-cli conway /cardano-cli babbage /g' {} +

  # Remove cardano-cli conway specific args
  sed -i '/--key-reg-deposit-amt/d' ./scripts/setup-new-delegator-keys.sh
fi

# Copy the cost mode
cardano-cli genesis create-staked --genesis-dir "${ROOT}" \
  --testnet-magic "${NETWORK_MAGIC}" \
  --gen-pools ${NUM_SP_NODES} \
  --supply ${MAX_SUPPLY} \
  --supply-delegated $((MAX_SUPPLY * 2)) \
  --gen-stake-delegs ${NUM_SP_NODES} \
  --gen-utxo-keys ${NUM_SP_NODES}

# create the node directories
for NODE in ${SP_NODES}; do
  mkdir -p "${ROOT}/${NODE}"
done

# Here we move all of the keys etc generated by create-staked
# for the nodes to use

# Move all genesis related files
mkdir -p "${ROOT}/genesis/byron"
mkdir -p "${ROOT}/genesis/shelley"

mv "${ROOT}/byron-gen-command/genesis.json" "${ROOT}/genesis/byron/genesis-wrong.json"
mv "${ROOT}/genesis.alonzo.json" "${ROOT}/genesis/shelley/genesis.alonzo.json"
mv "${ROOT}/genesis.conway.json" "${ROOT}/genesis/shelley/genesis.conway.json"
mv "${ROOT}/genesis.json" "${ROOT}/genesis/shelley/copy-genesis.json"

jq --raw-output ".protocolConsts.protocolMagic = ${NETWORK_MAGIC}" "${ROOT}/genesis/byron/genesis-wrong.json" >"${ROOT}/genesis/byron/genesis.json"

rm "${ROOT}/genesis/byron/genesis-wrong.json"

if [[ "$NETWORK_SPEED" == "fast" ]]; then
  SLOT_LENGTH=0.2
else
  SLOT_LENGTH=1
fi

jq -M "
. + {
  activeSlotsCoeff: 0.1,
  epochLength: 1000,
  maxLovelaceSupply: $((MAX_SUPPLY * 3)),
  securityParam: 10,
  slotLength: ${SLOT_LENGTH},
  updateQuorum: 2
} |
.protocolParams += {
  decentralisationParam: 0.7,
  keyDeposit: 2000000,
  minFeeA: 44,
  minFeeB: 155381,
  minUTxOValue: 1000000,
  poolDeposit: 500000000,
  protocolVersion: { major : 10, minor: 0 },
  rho: 0.1,
  tau: 0.1
}" "${ROOT}/genesis/shelley/copy-genesis.json" > "${ROOT}/genesis/shelley/genesis.json"

rm "${ROOT}/genesis/shelley/copy-genesis.json"

for NODE_ID in ${SP_NODES_ID}; do
  TARGET="${ROOT}/node-sp${NODE_ID}"
  PORT="$(("$NODE_ID" + 3000))"

  mv "${ROOT}/pools/vrf${NODE_ID}.skey" "${TARGET}/vrf.skey"
  mv "${ROOT}/pools/opcert${NODE_ID}.cert" "${TARGET}/opcert.cert"
  mv "${ROOT}/pools/kes${NODE_ID}.skey" "${TARGET}/kes.skey"

  BYRON_KEYS_POSFIX=$(seq -f '%03.f' $(("$NODE_ID" - 1)) $(("$NODE_ID" - 1)))
  #Byron related
  mv "${ROOT}/byron-gen-command/delegate-keys.${BYRON_KEYS_POSFIX}.key" "${TARGET}/byron-delegate.key"
  mv "${ROOT}/byron-gen-command/delegation-cert.${BYRON_KEYS_POSFIX}.json" "${TARGET}/byron-delegation.cert"

  echo "${PORT}" >"${TARGET}/port"

done

# Make topology files
for ID in ${SP_NODES_ID}; do
  port="$(("$ID" + 3001))"

  if [ "$ID" -ge "$(("$NUM_SP_NODES" - 1))" ]; then # Wrap around
    port="$(("$port" - "$(("$NUM_SP_NODES" - 1))"))"
  fi

  secondPort="$(("$port" + 1))"

  cat >"${ROOT}/node-sp${ID}/topology.json" <<EOF
  {
     "Producers": [
       {
         "addr": "127.0.0.1",
         "port": ${port},
         "valency": 1
       }
     , {
         "addr": "127.0.0.1",
         "port": ${secondPort},
         "valency": 1
       }
     ]
   }
EOF

done

for NODE in ${SP_NODES}; do
  (
    echo "#!/usr/bin/env bash"
    echo ""
    echo 'export PATH=$PWD/bin:$PATH'
    echo ""
    echo " while true ; do"
    echo 'cardano-node run \'
    echo "  --config                          '${ROOT}/configuration.yaml' \\"
    echo "  --topology                        '${ROOT}/${NODE}/topology.json' \\"
    echo "  --database-path                   '${ROOT}/${NODE}/db' \\"
    echo "  --socket-path                     '$(sprocket "${ROOT}/${NODE}/node.sock")' \\"
    echo "  --shelley-kes-key                 '${ROOT}/${NODE}/kes.skey' \\"
    echo "  --shelley-vrf-key                 '${ROOT}/${NODE}/vrf.skey' \\"
    echo "  --byron-delegation-certificate    '${ROOT}/${NODE}/byron-delegation.cert' \\"
    echo "  --byron-signing-key               '${ROOT}/${NODE}/byron-delegate.key' \\"
    echo "  --shelley-operational-certificate '${ROOT}/${NODE}/opcert.cert' \\"
    echo "  --port                            $(cat "${ROOT}/${NODE}/port") \\"
    echo "  | tee -a '${ROOT}/${NODE}/node.log'"
    echo "done"
    echo ""
    echo "wait"
  ) >"${ROOT}/${NODE}.sh"

  chmod a+x "${ROOT}/${NODE}.sh"

  echo "${ROOT}/${NODE}.sh"
done

echo "Update start time in genesis files"
sed_i -E "s/\"startTime\": [0-9]+/\"startTime\": ${timeUnix}/" ${ROOT}/genesis/byron/genesis.json
sed_i -E "s/\"systemStart\": \".*\"/\"systemStart\": \"${timeISO}\"/" ${ROOT}/genesis/shelley/genesis.json

byronGenesisHash=$(cardano-cli byron genesis print-genesis-hash --genesis-json ${ROOT}/genesis/byron/genesis.json)
shelleyGenesisHash=$(cardano-cli genesis hash --genesis ${ROOT}/genesis/shelley/genesis.json)
alonzoGenesisHash=$(cardano-cli genesis hash --genesis ${ROOT}/genesis/shelley/genesis.alonzo.json)
conwayGenesisHash=$(cardano-cli genesis hash --genesis ${ROOT}/genesis/shelley/genesis.conway.json)

echo "Byron genesis hash: $byronGenesisHash"
echo "Shelley genesis hash: $shelleyGenesisHash"
echo "Alonzo genesis hash: $alonzoGenesisHash"
echo "Conway genesis hash: $conwayGenesisHash"

sed_i -E "s/ByronGenesisHash: '.*'/ByronGenesisHash: '${byronGenesisHash}'/" ${ROOT}/configuration.yaml
sed_i -E "s/ShelleyGenesisHash: '.*'/ShelleyGenesisHash: '${shelleyGenesisHash}'/" ${ROOT}/configuration.yaml
sed_i -E "s/AlonzoGenesisHash: '.*'/AlonzoGenesisHash: '${alonzoGenesisHash}'/" ${ROOT}/configuration.yaml
sed_i -E "s/ConwayGenesisHash: '.*'/ConwayGenesisHash: '${conwayGenesisHash}'/" ${ROOT}/configuration.yaml

# Create config folder
rm -rf ./config/*
mkdir -p ./config/network/cardano-db-sync/
mkdir -p ./config/network/cardano-node/genesis/
mkdir -p ./config/network/cardano-submit-api/
mkdir -p ./config/network/genesis/

cp ./templates/babbage/db-sync-config.json ./config/network/cardano-db-sync/config.json
cp ./templates/babbage/node-config.json ./config/network/cardano-node/config.json
cp ./templates/babbage/submit-api-config.json ./config/network/cardano-submit-api/config.json

sed_i -E "s/\"ByronGenesisHash\": \".*\"/\"ByronGenesisHash\": \"${byronGenesisHash}\"/" ./config/network/cardano-node/config.json
sed_i -E "s/\"ShelleyGenesisHash\": \".*\"/\"ShelleyGenesisHash\": \"${shelleyGenesisHash}\"/" ./config/network/cardano-node/config.json
sed_i -E "s/\"AlonzoGenesisHash\": \".*\"/\"AlonzoGenesisHash\": \"${alonzoGenesisHash}\"/" ./config/network/cardano-node/config.json
sed_i -E "s/\"ConwayGenesisHash\": \".*\"/\"ConwayGenesisHash\": \"${conwayGenesisHash}\"/" ./config/network/cardano-node/config.json

cp ./templates/babbage/topology.json ./config/network/cardano-node/topology.json
# docker hostname in topology.json isn't working, so need to specify ip of local network
CONTAINER_IP=$(hostname -I | xargs)
sed_i "s/172.17.0.1/$CONTAINER_IP/g" ./config/network/cardano-node/topology.json
# Note: for some reason, the first cardano-node (on port 3001) isn’t immediately responsive to the outside world, so:
sed_i "s/3001/3002/g" ./config/network/cardano-node/topology.json

cp "${ROOT}"/genesis/byron/genesis.json ./config/network/cardano-node/genesis/byron.json
cp "${ROOT}"/genesis/byron/genesis.json ./config/network/genesis/byron.json

cp "${ROOT}"/genesis/shelley/genesis.json ./config/network/cardano-node/genesis/shelley.json
cp "${ROOT}"/genesis/shelley/genesis.json ./config/network/genesis/shelley.json

cp "${ROOT}"/genesis/shelley/genesis.alonzo.json ./config/network/cardano-node/genesis/alonzo.json
cp "${ROOT}"/genesis/shelley/genesis.alonzo.json ./config/network/genesis/alonzo.json

cp "${ROOT}"/genesis/shelley/genesis.conway.json ./config/network/cardano-node/genesis/conway.json
cp "${ROOT}"/genesis/shelley/genesis.conway.json ./config/network/genesis/conway.json

mkdir -p "${ROOT}/run"

echo "#!/usr/bin/env bash" >"${ROOT}/run/all.sh"
echo "" >>"${ROOT}/run/all.sh"
echo "" >>"${ROOT}/run/all.sh"
echo 'export PATH=$PWD/bin:$PATH' >>"${ROOT}/run/all.sh"
echo "" >>"${ROOT}/run/all.sh"

for NODE in ${SP_NODES}; do
  echo "$ROOT/${NODE}.sh &" >>"${ROOT}/run/all.sh"
done
echo "" >>"${ROOT}/run/all.sh"
echo "wait" >>"${ROOT}/run/all.sh"

chmod a+x "${ROOT}/run/all.sh"

wait
