/* eslint-disable no-console */
/* eslint-disable func-style */
import { Counter, Trend } from 'k6/metrics';
import { check, sleep } from 'k6';
import http from 'k6/http';

/**
 * Script overall description:
 *  One wallet == one VU
 *  Configure RUN_MODE to have the test run with empty wallets (onboarding) or wallets with history (restoring)
 *  Configure MAX_VU: number of wallets to be synced (e.g. 100 wallets)
 *  Setup RAMP_UP_DURATION: ramp-up time to synced these wallets (e.g. 30s)
 *    - During this time, wallets start evenly distributed (e.g. ~3 wallets every second)
 *  Each wallet performs as many iterations as possible
 *    - 1st iteration: restoration steps .
 *    - Subsequent iterations will only query the tip
 *  ITERATION_SLEEP: Every iteration has a sleep of to simulate Lace tip polling interval
 *  During the STEADY_STATE_DURATION:
 *    - Synced wallets do tip queries.
 *    - Wallets not synced yet will wait for restoration to complete, then will also start tip queries
 *  No ramp-down is needed. We can simply stop the test as there is no point in sending fewer and fewer tip queries during ramp-down.
 *  wallet_sync: is a custom trend metric measuring the trend of wallet sync calls.
 *  wallet_sync_count: is a custom count metric measuring the number of wallets that were successfully synced.
 */

const RunMode = {
  Onboard: 'Onboard',
  Restore: 'Restore'
};
/** Determines run mode: Restore or Onboard */
const RUN_MODE = RunMode.Onboard;

/**
 * True: Keep spinning on the restoring part
 * False: Once restored, just loop over ledger tip
 */
const SPIN_ON_NEW_WALLETS = true;

// eslint-disable-next-line no-undef
const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

/** URL of the JSON file containing the wallets */
const WALLET_ADDRESSES_URL =
  RUN_MODE === RunMode.Restore
    ? 'https://raw.githubusercontent.com/input-output-hk/cardano-js-sdk/master/packages/e2e/test/dump/addresses/mainnet.json'
    : 'https://raw.githubusercontent.com/input-output-hk/cardano-js-sdk/master/packages/e2e/test/dump/addresses/no-history-mainnet.json';

/** URL of the JSON file containing the stake pool addresses */
const POOL_ADDRESSES_URL =
  'https://raw.githubusercontent.com/input-output-hk/cardano-js-sdk/master/packages/e2e/test/dump/pool_addresses/mainnet.json';

/**
 * Define the maximum number of virtual users to simulate
 * The mainnet.json file contains wallets in chunks of 100, each chunk having the required distribution
 * For this reason, it's a good practice to configure MAX_VUs in multiples of 100 in order to maintain the desired distribution
 */
const MAX_VU = 1;

/** Time span during which all virtual users are started in a linear fashion */
const RAMP_UP_DURATION = '10s';
/** Time span during which synced wallets do tip queries */
const STEADY_STATE_DURATION = '1m';

/** Time to sleep between iterations. Simulates polling tip to keep wallet in sync */
const ITERATION_SLEEP = 5;

/** Custom trend statistic to measure trend to sync wallets */
const walletSyncTrend = new Trend('wallet_sync', true);
/** Custom count statistic to measure how many wallets were successfully syncd */
const walletSyncCount = new Counter('wallet_sync_count');

/** Repetitive entpoints */
const TIP_URL = 'network-info/ledger-tip';

/** Grab the wallets json file to be used by the scenario */
export function setup() {
  console.log(`Running in ${RUN_MODE} mode`);
  const res = http.batch([WALLET_ADDRESSES_URL, POOL_ADDRESSES_URL]);
  check(res, { 'get wallets and pools files': (r) => r.every(({ status }) => status >= 200 && status < 300) });

  const [{ body: resBodyWallets }, { body: resBodyPools }] = res;
  const wallets = JSON.parse(resBodyWallets);
  const walletCount = wallets ? wallets.length : 0;
  check(walletCount, {
    'At least one wallet is required to run the test': (count) => count > 0
  });
  console.log(`Wallet addresses configuration file contains ${walletCount} wallets`);
  if (walletCount < MAX_VU) {
    console.warn(
      `Requested VU count: (${MAX_VU}), is greater than the available walled addresses: ${walletCount}. Some addresses will be reused`
    );
  }

  const poolAddresses = JSON.parse(resBodyPools);
  check(poolAddresses, {
    'At least one stake pool address is required to run the test': (p) => p && p.length > 0
  });
  return { poolAddresses, wallets: wallets.slice(0, MAX_VU) };
}

/** Keeps track of wallets that were successfully syncd to avoid restoring twice */
const syncedWallets = new Set();

export const options = {
  ext: {
    loadimpact: {
      apm: [],
      distribution: { 'amazon:us:portland': { loadZone: 'amazon:us:portland', percent: 100 } }
    }
  },
  scenarios: {
    SyncDifferentSizeWallets: {
      executor: 'ramping-vus',
      gracefulRampDown: '0s',
      gracefulStop: '0s',
      stages: [
        { duration: RAMP_UP_DURATION, target: MAX_VU },
        { duration: STEADY_STATE_DURATION, target: MAX_VU }
      ],
      startVUs: 1
    }
  },
  thresholds: {
    // All wallets should have syncd
    // Use https://k6.io/docs/using-k6/thresholds/ to set more thresholds. E.g.:
    // wallet_sync: ['p(95)<5000'], // 95% of wallets should sync in under 5 seconds
    wallet_sync: [{ delayAbortEval: '5s', threshold: 'p(95) < 30000' }],

    wallet_sync_count: [`count >= ${MAX_VU}`] // We get a nice graph if we enable thresholds. See this stat on a graph
  }
};

/** Util functions for sending the http post requests to cardano-sdk services */
const cardanoHttpPost = (url, body = {}) => {
  const opts = { headers: { 'content-type': 'application/json' } };
  return http.post(`${PROVIDER_SERVER_URL}/${url}`, JSON.stringify(body), opts);
};
const txsByAddress = (address) => {
  let startAt = 0;
  const pageSize = 25;
  let txCount = 0;
  do {
    const resp = cardanoHttpPost('chain-history/txs/by-addresses', {
      addresses: [address],
      blockRange: { lowerBound: { __type: 'undefined' } },
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
};
const utxosByAddresses = (address) => cardanoHttpPost('utxo/utxo-by-addresses', { addresses: [address] });
const rewardsAccBalance = (rewardAccount) => cardanoHttpPost('rewards/account-balance', { rewardAccount });
const stakePoolSearch = (poolAddress) =>
  cardanoHttpPost('stake-pool/search', {
    filters: { identifier: { values: [{ id: poolAddress }] } },
    pagination: { limit: 1, startAt: 0 }
  });

/** Simulation of requests performed by a wallet while restoring */
const syncWallet = ({ wallet, poolAddress }) => {
  const startTime = Date.now();
  const { address, stake_address: rewardAccount } = wallet;
  cardanoHttpPost('network-info/era-summaries');
  cardanoHttpPost(TIP_URL);
  txsByAddress(address);
  utxosByAddresses(address);
  cardanoHttpPost('network-info/era-summaries');
  cardanoHttpPost('network-info/genesis-parameters');
  cardanoHttpPost('network-info/protocol-parameters');
  rewardsAccBalance(rewardAccount);
  cardanoHttpPost(TIP_URL);
  cardanoHttpPost('network-info/lovelace-supply');
  cardanoHttpPost('network-info/stake');
  if (RUN_MODE === RunMode.Restore) {
    stakePoolSearch(poolAddress);
  }
  cardanoHttpPost('stake-pool/stats');

  syncedWallets.add(address);
  walletSyncTrend.add(Date.now() - startTime);
  walletSyncCount.add(1);
};

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

/**
 * Simulate keeping wallet in sync
 * For now, just polling the tip
 */
const emulateIdleClient = () => cardanoHttpPost(TIP_URL);

export default function ({ wallets, poolAddresses }) {
  // Pick a new wallet or reuse the same one?
  // eslint-disable-next-line no-undef
  const walletIdx = SPIN_ON_NEW_WALLETS ? getRandomInt(wallets.length) : __VU;

  // Get the wallet for the current virtual user
  const wallet = wallets[walletIdx % wallets.length];
  const poolAddress = poolAddresses[walletIdx % poolAddresses.length];

  if (SPIN_ON_NEW_WALLETS || !syncedWallets.has(wallet.address)) {
    syncWallet({ poolAddress, wallet });
  } else {
    emulateIdleClient();
    sleep(ITERATION_SLEEP);
  }
}
