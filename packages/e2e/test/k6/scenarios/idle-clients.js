/* eslint-disable no-console */
// K6 doesn't support numeric separators style
/* eslint-disable unicorn/numeric-separators-style */

/* eslint-disable func-style */
import { check, sleep } from 'k6';
import http from 'k6/http';

/**
 * # Script overall description:
 *
 * ## Purpose
 * Measure the load of the back-end services given a number of wallets in idle state.
 * Idle state is defined as the queries that the wallets perform as a result of staying in sync,
 * without submitting/receiving any transactions.
 *
 * ## Methodology
 * - Each wallet is just a set of queries performed on a number of addresses, it is not an actual SDK wallet.
 * - Each wallet consists of a number of addresses (`hdWalletParams.activeAddrCount`). A value of 1 indicates
 *   a single address wallet, while a value >1 is an HD wallet.
 * - The maximum transaction history per address can be configured using `hdWalletParams.maxTxHistory`.
 * - Addresses are real addresses from mainnet.
 * - Stage 1: a number of wallets (`MAX_VU`) are started progressively during a given time (`RAMP_UP_DURATION`).
 *   The purpose of this stage is to increase the load of idle wallets progressively.
 *   When each wallet starts, it will directly perform the queries normally done by an idle wallet.
 *   They will NOT do any initialization, address discovery, etc.
 * - Stage 2: wallets remain in idle state, performing the idle specific queries.
 *   The purpose of this stage is to sustain the maximum load for a period of time.
 *
 * ## Idle state definition
 * - Query the tip every 5 seconds (`POLL_INTERVAL`) for 4 times (`NUM_TIP_QUERIES`).
 * - Query the transactions for all wallet addresses, starting with a block from 1 epoch behind.
 * - Query the utxos for all wallet addresses.
 * - Wait another 5 seconds (`POLL_INTERVAL`).
 * - Repeat.
 *
 * Other queries normally done by the wallet, but which we are not doing in this test because they are done rarely (every epoch),
 * or when wallet is not idle (is active: sending/receiving transactions):
 * - era summaries, protocol params, genesis params
 * - delegation & rewards, assets metadata, handles
 *
 * ## Performance indicators
 * - http_req_duration
 * - http_req_failed
 */

// eslint-disable-next-line no-undef
const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;
/** URL of the JSON file containing the wallets */
const WALLET_ADDRESSES_URL =
  'https://raw.githubusercontent.com/input-output-hk/cardano-js-sdk/master/packages/e2e/test/dump/addresses/mainnet.json';

const MAX_VU = 50;

/** Time span during which the number of wallets doing idle queries increase in a linear fashion */
const RAMP_UP_DURATION = '100s';
/** Time span during which the total number of wallets doing idle queries is maintained */
const STEADY_STATE_DURATION = '150s';

const NUM_TIP_QUERIES = 4;
const POLL_INTERVAL = 5;

/** HD wallet params */
const hdWalletParams = {
  /** HD wallet size. The number of addresses with transaction history per wallet. They are queried at discover time. */
  activeAddrCount: 10,
  /** Use only addresses with a transaction history up to this value */
  maxTxHistory: 100
};

/** Repetitive endpoints */
const TIP_URL = 'network-info/ledger-tip';

export const options = {
  ext: {
    loadimpact: {
      apm: [],
      distribution: { 'amazon:de:frankfurt': { loadZone: 'amazon:de:frankfurt', percent: 100 } }
    }
  },
  scenarios: {
    Scenario_1: {
      exec: 'scenario_1',
      executor: 'ramping-vus',
      gracefulRampDown: '0s',
      gracefulStop: '0s',
      stages: [
        { duration: RAMP_UP_DURATION, target: MAX_VU },
        { duration: STEADY_STATE_DURATION, target: MAX_VU }
      ]
    }
  },
  thresholds: { http_req_duration: ['p(95)<200'], http_req_failed: ['rate<0.02'] }
};

/** equivalent to lodash.chunk */
const chunkArray = (array, chunkSize) => {
  const arrayCopy = [...array];
  const chunked = [];
  while (arrayCopy.length > 0) {
    chunked.push(arrayCopy.splice(0, chunkSize));
  }
  return chunked;
};

/** Util functions for sending the http post requests to cardano-sdk services */
const cardanoHttpPost = (url, body = {}) => {
  const opts = { headers: { 'content-type': 'application/json' } };
  return http.post(`${PROVIDER_SERVER_URL}/${url}`, JSON.stringify(body), opts);
};

const utxosByAddresses = (addresses) => {
  const addressChunks = chunkArray(addresses, 25);
  for (const chunk of addressChunks) {
    cardanoHttpPost('utxo/utxo-by-addresses', { addresses: chunk });
  }
};

/**
 *
 * @param addresses Bech32 cardano addresses: `Cardano.Address[]`
 * @param blockHeightOfLastTx query transactions done starting with this block height.
 */
const txsByAddress = (addresses, blockHeightOfLastTx) => {
  const pageSize = 25;
  const addressChunks = chunkArray(addresses, pageSize);
  for (const chunk of addressChunks) {
    let startAt = 0;
    let txCount = 0;

    do {
      const resp = cardanoHttpPost('chain-history/txs/by-addresses', {
        addresses: chunk,
        blockRange: { lowerBound: blockHeightOfLastTx },
        pagination: { limit: pageSize, startAt }
      });

      if (resp.status !== 200) {
        // No point in trying to get the other pages.
        // Should we log this? it will show up as if the restoration was quicker since this wallet did not fetch all the pages
        break;
      }

      const { pageResults } = JSON.parse(resp.body);
      startAt += pageSize;
      txCount = pageResults.length;
    } while (txCount === pageSize);
  }
};

/**
 * Grab the wallets json file to be used by the scenario.
 * Group the addresses per wallet (single address or HD wallets).
 */
export function setup() {
  console.log(
    `Ramp-up: ${RAMP_UP_DURATION}; Sustain: ${STEADY_STATE_DURATION}; Poll: ${POLL_INTERVAL}s; Block height change every: ${NUM_TIP_QUERIES}`
  );
  // This call will be part of the statistics. There is no way around it so far: https://github.com/grafana/k6/issues/1321
  const res = http.get(WALLET_ADDRESSES_URL);
  check(res, { 'get wallets': (r) => r.status >= 200 && r.status < 300 });

  const { body: resBodyWallets } = res;
  const walletsOrig = JSON.parse(resBodyWallets);
  const walletsOrigCount = walletsOrig ? walletsOrig.length : 0;
  check(walletsOrigCount, {
    'At least one wallet is required to run the test': (count) => count > 0
  });
  console.log(`Wallet addresses configuration file contains ${walletsOrigCount} addresses`);

  // Remove "big transaction history wallets"
  const filteredWallets = walletsOrig.filter(({ tx_count }) => tx_count < hdWalletParams.maxTxHistory);
  // Create chunks of `activeAddrCount` addresses per HD wallet
  const wallets = chunkArray(filteredWallets, hdWalletParams.activeAddrCount);

  const requestedAddrCount = MAX_VU * hdWalletParams.activeAddrCount;
  const availableAddrCount = filteredWallets.length;
  if (availableAddrCount < requestedAddrCount) {
    console.warn(
      `Requested wallet count * addresses per wallet: (${requestedAddrCount}), is greater than the available addresses: ${availableAddrCount}. Some addresses will be reused`
    );
  }

  const tipRes = cardanoHttpPost(TIP_URL);
  check(tipRes, { 'Initial tip query': (r) => r.status >= 200 && r.status < 300 });
  const { body } = tipRes;
  const { blockNo } = JSON.parse(body);

  // When querying transactions, assume the last transaction was done in the previous epoch
  const blocksPerEpoch = 20000;
  const blockHeightOfLastTx = blockNo - blocksPerEpoch;
  check(blockHeightOfLastTx, { 'Block height of last tx (tip - 1 epoch) is valid': (height) => height > 0 });

  return { blockHeightOfLastTx, wallets: wallets.slice(0, MAX_VU) };
}

/**
 * Each wallet consisting of hdWalletParams.activeAddrCount addresses is polling the tip, then queries:
 * - current utxo set for all addresses
 * - transaction history since last known transaction block height for all addresses
 */
// eslint-disable-next-line func-style
export function scenario_1({ wallets, blockHeightOfLastTx }) {
  // Get the wallet for the current virtual user
  // eslint-disable-next-line no-undef
  const vu = __VU;
  const wallet = wallets[vu % wallets.length]; // each wallet is a collection of addresses
  const addresses = wallet.map(({ address }) => address);
  for (let i = 0; i < NUM_TIP_QUERIES; i++) {
    cardanoHttpPost(TIP_URL);
    // No sleep after last query - fetch utxo and tx history immediately
    if (i + 1 < NUM_TIP_QUERIES) {
      sleep(POLL_INTERVAL);
    }
  }

  txsByAddress(addresses, blockHeightOfLastTx);
  utxosByAddresses(addresses);

  sleep(POLL_INTERVAL);
}
