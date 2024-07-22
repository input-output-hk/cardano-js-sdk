// cSpell:ignore loadimpact

import * as k6Utils from '../../../../util-dev/dist/cjs/k6-utils.js';
import { Counter, Trend } from 'k6/metrics';
import { SharedArray } from 'k6/data';
import { check } from 'k6';
import ws from 'k6/ws';

const { HD_ACTIVE_ADDR_COUNT, HD_MAX_TX_HISTORY, TARGET_NET, WALLETS } = Object.assign(
  { HD_ACTIVE_ADDR_COUNT: '10', HD_MAX_TX_HISTORY: '100', TARGET_NET: 'mainnet', WALLETS: '100' },
  // eslint-disable-next-line no-undef
  __ENV
);

// eslint-disable-next-line no-undef
const dut = k6Utils.getDut(__ENV, { networks: ['mainnet', 'preprod'] });
const url = `wss://${dut}/ws`;

const activeAddrCount = Number.parseInt(HD_ACTIVE_ADDR_COUNT, 10);
const maxTxHistory = Number.parseInt(HD_MAX_TX_HISTORY, 10);
const numWallets = Number.parseInt(WALLETS, 10);

export const options = {
  ext: {
    loadimpact: {
      apm: [],
      distribution: { 'amazon:us:portland': { loadZone: 'amazon:us:portland', percent: 100 } }
    }
  },
  scenarios: {
    connections: {
      executor: 'ramping-vus',
      gracefulRampDown: '0s',
      gracefulStop: '10m',
      stages: [{ duration: '3s', target: numWallets }],
      startVUs: 1
    }
  }
};

/** Wallet addresses extracted from the JSON dump file */
const fileName = `../../dump/addresses/${TARGET_NET}.json`;
// eslint-disable-next-line no-undef
const walletsOrig = new SharedArray('walletsData', () => JSON.parse(open(fileName)));

export const setup = () => {
  check(
    undefined,
    Object.fromEntries(
      [`Number of wallets: ${numWallets}`, `Max transactions per wallet: ${maxTxHistory}`].map((_) => [_, () => true])
    )
  );

  // Remove "big transaction history wallets"
  const filteredWallets = walletsOrig.filter(({ tx_count }) => tx_count < maxTxHistory);
  // Create chunks of `activeAddrCount` addresses per HD wallet
  const wallets = k6Utils.chunkArray(filteredWallets, activeAddrCount);

  return { wallets: wallets.slice(0, numWallets) };
};

const operationalTrend = new Trend('_operational', true);
const syncTrend = new Trend('_sync', true);
const syncCount = new Counter('_sync_count');
const transactionsTrend = new Trend('_transactions_per_wallet');
const unexpectedCloseCounter = new Counter('_unexpected_close');

const getDummyAddr = (addr, idx, suffix = 'mh') => {
  const last3Chars = addr.slice(-3);
  const updateChars = last3Chars !== `${suffix}${idx}` ? `${suffix}${idx}` : `${idx}${suffix}`;
  return addr.slice(0, -3) + updateChars;
};

export const run = ({ wallets }) => {
  const begin = Date.now();
  // eslint-disable-next-line no-undef
  const vu = __VU;
  const wallet = wallets[vu % wallets.length]; // each wallet is a collection of addresses

  const res = ws.connect(url, null, (socket) => {
    let closed = false;
    let requestId = 0;
    let transactionsCount = 0;

    const nextAddress = () => {
      // Simplified address discovery with 50 fake addresses
      if (++requestId > wallet.length + 50) {
        transactionsTrend.add(transactionsCount);
        syncTrend.add(Date.now() - begin);
        syncCount.add(1);

        return socket.setTimeout(() => {
          closed = true;
          socket.close();
        }, 1000);
      }

      const address =
        requestId <= wallet.length
          ? wallet[requestId - 1].address
          : getDummyAddr(wallet[0].address, requestId - wallet.length);

      socket.send(JSON.stringify({ requestId, txsByAddresses: { addresses: [address], lower: 0 } }));
    };

    socket.on('message', (message) => {
      const { clientId, responseTo, transactions } = JSON.parse(message);

      if (clientId) operationalTrend.add(Date.now() - begin);
      if (clientId || responseTo) nextAddress();
      if (transactions) transactionsCount += transactions.length;
    });

    // Count unexpected close
    socket.on('close', () => {
      if (!closed) unexpectedCloseCounter.add(1);
    });

    // Heartbeat
    const heartbeat = () => {
      socket.send('{}');
      socket.setTimeout(heartbeat, 30 * 1000);
    };
    heartbeat();
  });

  check(res, { 'status is 101': (r) => r && r.status === 101 });
};

export default run;
