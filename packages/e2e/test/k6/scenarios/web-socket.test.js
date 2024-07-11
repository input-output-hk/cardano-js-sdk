// cSpell:ignore loadimpact

import { Counter, Trend } from 'k6/metrics';
import { check } from 'k6';
import ws from 'k6/ws';

// eslint-disable-next-line no-undef
const { TARGET_ENV, TARGET_NET, URL, WALLETS } = Object.assign({ WALLETS: '10000' }, __ENV);
const url = TARGET_ENV ? `wss://${TARGET_ENV}-${TARGET_NET}${TARGET_ENV === 'ops' ? '-1' : ''}.lw.iog.io/ws` : URL;

if (TARGET_ENV && !['dev', 'ops', 'staging', 'prod'].includes(TARGET_ENV))
  throw new Error(`Not valid TARGET_ENV: ${TARGET_ENV}`);
if (TARGET_NET && !['preview', 'preprod', 'sanchonet', 'mainnet'].includes(TARGET_NET))
  throw new Error(`Not valid TARGET_NET: ${TARGET_NET}`);
if (!(TARGET_ENV && TARGET_NET) && !URL) throw new Error('Please specify both TARGET_ENV and TARGET_NET or URL');

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
      gracefulStop: '120s',
      stages: [{ duration: '3s', target: Number.parseInt(WALLETS, 10) }],
      startVUs: 10
    }
  }
};

const operationalTrend = new Trend('_operational', true);
const unexpectedCloseCounter = new Counter('_unexpected_close');

export const run = () => {
  const begin = Date.now();

  const res = ws.connect(url, null, (socket) => {
    let closed = false;
    let firstMessage = true;

    socket.on('message', () => {
      if (firstMessage) {
        operationalTrend.add(Date.now() - begin);
        firstMessage = false;
      }
    });

    // Count unexpected close
    socket.on('close', () => {
      if (!closed) unexpectedCloseCounter.add(1);
    });

    // Heartbeat
    socket.setTimeout(() => socket.send('{}'), 30 * 1000);

    // End the test after 80"
    socket.setTimeout(() => {
      closed = true;
      socket.close();
    }, 80 * 1000);
  });

  check(res, { 'status is 101': (r) => r && r.status === 101 });
};

export default run;
