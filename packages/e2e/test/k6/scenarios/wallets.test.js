/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable func-style */
import { Counter, Trend } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { apiVersion } from '../../../../cardano-services-client/src/version.ts';
import { check, sleep } from 'k6';
import http from 'k6/http';

/**
 * #Script overall description:
 *  - One wallet == one VU
 *  - One wallet == 1 address for `RunMode.Onboard` and `RunMode.Restore`
 *  - One wallet == n addresses for `RunMode.RestoreHD` mode
 *  - Configure RUN_MODE to have the test run with empty wallets (onboarding), wallets with history (restoring) or HD wallets with history
 *    and discovery phase.
 *  - SDK `PersonalWallet` does HD discovery for every wallet, to determine the active addresses, so it will be done even for single address wallets.
 *    To simulate this use `RunMode.RestoreHD` with `hdWalletParams.activeAddrCount: 1`.
 *  - Configure MAX_VU: number of wallets to be synced (e.g. 100 wallets)
 *  - Setup RAMP_UP_DURATION: ramp-up time to synced these wallets (e.g. 30s)
 *    - During this time, wallets start evenly distributed (e.g. ~3 wallets every second)
 *  - Each wallet performs as many iterations as possible
 *    - 1st iteration: restoration steps.
 *    - Subsequent iterations will only query the tip
 *  - ITERATION_SLEEP: Every iteration has a sleep of to simulate Lace tip polling interval
 *  - During the STEADY_STATE_DURATION:
 *    - Synced wallets do tip queries.
 *    - Wallets not synced yet will wait for restoration to complete, then will also start tip queries
 *  - No ramp-down is needed. We can simply stop the test as there is no point in sending fewer and fewer tip queries during ramp-down.
 *  - wallet_sync: is a custom trend metric measuring the trend of wallet sync calls.
 *  - wallet_sync_count: is a custom count metric measuring the number of wallets that were successfully synced.
 */

const RunMode = {
  Onboard: 'Onboard',
  Restore: 'Restore',
  RestoreHD: 'RestoreHD'
};
/** Determines run mode: Restore or Onboard */
const RUN_MODE = __ENV.RUN_MODE || RunMode.Restore;

// eslint-disable-next-line no-undef
const PROVIDER_SERVER_URL = __ENV.PROVIDER_SERVER_URL;

/** Wallet addresses extracted from the JSON dump file */
const walletsOrig = new SharedArray('walletsData', () => {
  const network = __ENV.TARGET_ENV === 'dev-mainnet' ? 'mainnet' : 'preprod';
  const fileName = RUN_MODE === RunMode.Onboard ? `no-history-${network}.json` : `${network}.json`;
  console.log(`Reading wallet addresses from ${fileName}`);
  return JSON.parse(open(`../../dump/addresses/${fileName}`));
});

/** Stake pool addresses from the JSON dump file */
const poolAddresses = new SharedArray('poolsData', () =>
  // There is no dump of preprod pools, but it is ok. Pool address is used only in "Restore" mode
  // and it is used to do a stake pool search call, so any pool will do
  JSON.parse(open('../../dump/pool_addresses/mainnet.json'))
);

/**
 * Define the maximum number of virtual users to simulate
 * The mainnet.json file contains wallet addresses in chunks of 100, each chunk having the required distribution
 * For this reason, it's a good practice to configure MAX_VUs in multiples of 100 in order to maintain the desired distribution.
 * In `RunMode.RestoreHD`, each VU will have multiple addresses.
 */
const MAX_VU = __ENV.MAX_VU || 1;

/** Time span during which all virtual users are started in a linear fashion */
const RAMP_UP_DURATION = __ENV.RAMP_UP_DURATION || '1s';
/** Time span during which synced wallets do tip queries */
const STEADY_STATE_DURATION = __ENV.STEADY_STATE_DURATION || '2s';

/** Time to sleep between iterations. Simulates polling tip to keep wallet in sync */
const ITERATION_SLEEP = 5;

/** HD wallet discovery. Used when RunMode is `RestoreHD` */
const hdWalletParams = {
  /** HD wallet size. The number of addresses with transaction history per wallet. They are queried at discover time. */
  activeAddrCount: __ENV.HD_ACTIVE_ADDR_COUNT || 1,
  /** Use only addresses with a transaction history up to this value */
  maxTxHistory: __ENV.HD_MAX_TX_HISTORY || 1,
  /** number of payment addresses to search for. It will search both internal and external address, thus multiplied by 2 */
  paymentAddrSearchGap: 20 * 2,
  /** number of stake keys to search for. It will search both internal and external address, thus multiplied by 2 */
  stakeAddrSearchGap: 5 * 2
};

/** Custom trend statistic to measure trend to sync wallets */
const walletSyncTrend = new Trend('wallet_sync', true);
/** Custom count statistic to measure how many wallets were successfully syncd */
const walletSyncCount = new Counter('wallet_sync_count');

/** Repetitive endpoints */
const TIP_URL = 'network-info/ledger-tip';

/** equivalent to lodash.chunk */
const chunkArray = (array, chunkSize) => {
  const arrayCopy = [...array];
  const chunked = [];
  while (arrayCopy.length > 0) {
    chunked.push(arrayCopy.splice(0, chunkSize));
  }
  return chunked;
};

/** Grab the wallets json file to be used by the scenario. Group the addresses per wallet (single address or HD wallets). */
export function setup() {
  console.log(`Running in ${RUN_MODE} mode`);
  console.log(`Ramp-up: ${RAMP_UP_DURATION}; Sustain: ${STEADY_STATE_DURATION}; Iteration sleep: ${ITERATION_SLEEP}s`);

  if (RUN_MODE === RunMode.RestoreHD) {
    console.log('HD wallet params are:', hdWalletParams);
  }

  const walletsOrigCount = walletsOrig ? walletsOrig.length : 0;
  check(walletsOrigCount, {
    'At least one wallet is required to run the test': (count) => count > 0
  });
  console.log(`Wallet addresses configuration file contains ${walletsOrigCount} addresses`);

  // One wallet, one address
  let wallets = chunkArray(walletsOrig, 1);
  if (RUN_MODE === RunMode.RestoreHD) {
    // One wallet, multiple addresses
    // Remove "big transaction history wallets"
    const filteredWallets = walletsOrig.filter(({ tx_count }) => tx_count < hdWalletParams.maxTxHistory);
    // Create chunks of `activeAddrCount` addresses per HD wallet
    wallets = chunkArray(filteredWallets, hdWalletParams.activeAddrCount);
  }

  const requestedAddrCount = RUN_MODE === RunMode.RestoreHD ? MAX_VU * hdWalletParams.activeAddrCount : MAX_VU;
  const availableAddrCount = wallets.length;

  if (availableAddrCount < requestedAddrCount) {
    console.warn(
      `Requested wallet count * addresses per wallet: ${requestedAddrCount}, is greater than the available addresses: ${availableAddrCount}. Some addresses will be reused`
    );
  }

  check(poolAddresses, {
    'At least one stake pool address is required to run the test': (p) => p && p.length > 0
  });
  return { poolAddresses, wallets: wallets.slice(0, MAX_VU) };
}

/** Keeps track of wallets that were successfully synced to avoid restoring twice */
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
const cardanoHttpPost = (url, apiVer, body = {}) => {
  const opts = { headers: { 'content-type': 'application/json' } };
  return http.post(`${PROVIDER_SERVER_URL}/v${apiVer}/${url}`, JSON.stringify(body), opts);
};

/**
 *
 * @param addresses Bech32 cardano addresses: `Cardano.Address[]`
 * @param takeOne  true: query only the first page; false: query until no more pages
 * @param pageSize Use as request page size. Also, bundle this many addresses on each request.
 */
const txsByAddress = (addresses, takeOne = false, pageSize = 25) => {
  const addressChunks = chunkArray(addresses, pageSize);
  for (const chunk of addressChunks) {
    let startAt = 0;
    let txCount = 0;

    do {
      const resp = cardanoHttpPost('chain-history/txs/by-addresses', apiVersion.chainHistory, {
        addresses: chunk,
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
    } while (txCount === pageSize && !takeOne);
  }
};

const utxosByAddresses = (addresses) => {
  const addressChunks = chunkArray(addresses, 25);
  for (const chunk of addressChunks) {
    cardanoHttpPost('utxo/utxo-by-addresses', apiVersion.utxo, { addresses: chunk });
  }
};

const rewardsAccBalance = (rewardAccount) =>
  cardanoHttpPost('rewards/account-balance', apiVersion.rewards, { rewardAccount });
const stakePoolSearch = (poolAddress) =>
  cardanoHttpPost('stake-pool/search', apiVersion.stakePool, {
    filters: { identifier: { values: [{ id: poolAddress }] } },
    pagination: { limit: 1, startAt: 0 }
  });

/**
 * Changes the last 3 chars. Checksum will be broken but I assume it is not verified
 * Avoiding to import keyagent here to generate actual addresses as it would be difficult to do it
 * in K6 cloud.
 */
const getDummyAddr = (addr, idx, suffix = 'mh') => {
  const last3Chars = addr.slice(-3);
  const updateChars = last3Chars !== `${suffix}${idx}` ? `${suffix}${idx}` : `${idx}${suffix}`;
  return addr.slice(0, -3) + updateChars;
};

/** Simulate http requests normally done in discovery mode. `wallet` MUST have at least 2 elements */
const walletDiscovery = (wallet) => {
  check(wallet, {
    'At least one address is required to run HD wallet discovery mode': (walletArray) =>
      walletArray && walletArray.length > 0
  });

  console.debug(`Start walletDiscovery for ${wallet.length} addresses`);

  // Discover stake keys derived at index > 0 on the first payment key
  // We don't expect to find anything here so we'll use dummy addresses
  console.debug('Discover stake keys on payment #0');
  for (let i = 0; i < hdWalletParams.stakeAddrSearchGap; i++) {
    const addr = getDummyAddr(wallet[0].address, i);
    txsByAddress([addr], true, 1);
  }

  // Discover active payment addresses
  console.debug('Discover payment addresses #1+');
  for (const { address } of wallet) {
    // Even if txByAddresses accepts multiple addresses, discovery does it one by one
    txsByAddress([address], true, 1);
  }

  // Discover calls in payment address gap
  console.debug('Discover in search gap');
  for (let i = 0; i < hdWalletParams.paymentAddrSearchGap; i++) {
    const addr = getDummyAddr(wallet[0].address, i, 'hm');
    txsByAddress([addr], true, 1);
  }
};

/** Simulation of requests performed by a wallet while restoring */
const syncWallet = ({ wallet, poolAddress }) => {
  const startTime = Date.now();
  const addresses = wallet.map(({ address }) => address);

  if (RUN_MODE === RunMode.RestoreHD) {
    walletDiscovery(wallet);
  }

  cardanoHttpPost('network-info/era-summaries', apiVersion.networkInfo);
  cardanoHttpPost(TIP_URL, apiVersion.networkInfo);
  txsByAddress(addresses);
  utxosByAddresses(addresses);
  cardanoHttpPost('network-info/era-summaries', apiVersion.networkInfo);
  cardanoHttpPost('network-info/genesis-parameters', apiVersion.networkInfo);
  cardanoHttpPost('network-info/protocol-parameters', apiVersion.networkInfo);
  // Test restoring HD wallets with a single stake key
  rewardsAccBalance(wallet[0].stake_address);
  cardanoHttpPost(TIP_URL, apiVersion.networkInfo);
  cardanoHttpPost('network-info/lovelace-supply', apiVersion.networkInfo);
  cardanoHttpPost('network-info/stake', apiVersion.networkInfo);
  if (RUN_MODE === RunMode.Restore) {
    stakePoolSearch(poolAddress);
  }
  cardanoHttpPost('stake-pool/stats', apiVersion.stakePool);

  // Consider the wallet synced by tracking its first address
  syncedWallets.add(addresses[0]);
  walletSyncTrend.add(Date.now() - startTime);
  walletSyncCount.add(1);
};

/** Simulate keeping wallet in sync For now, just polling the tip */
const emulateIdleClient = () => cardanoHttpPost(TIP_URL, apiVersion.networkInfo);

/**
 * K6 default VU action function
 *
 * wallets: {address: Cardano.Address, stake_address: Cardano.RewardAccount, tx_count: number}[][]
 * poolAddresses: Cardano.PoolId[]
 */
// eslint-disable-next-line @typescript-eslint/no-shadow
export default function ({ wallets, poolAddresses }) {
  // Get the wallet for the current virtual user
  // eslint-disable-next-line no-undef
  const vu = __VU;
  const wallet = wallets[vu % wallets.length]; // each wallet is a collection of addresses
  const poolAddress = poolAddresses[vu % poolAddresses.length];

  syncedWallets.has(wallet[0].address) ? emulateIdleClient() : syncWallet({ poolAddress, wallet });
  sleep(ITERATION_SLEEP);
}
