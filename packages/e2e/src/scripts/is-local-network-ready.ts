/* eslint-disable no-console */
import { Pool } from 'pg';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/** Waits until the local network is ready or the wait time expires. */
(async () => {
  const { DB_SYNC_CONNECTION_STRING, LOCAL_NETWORK_READY_WAIT_TIME } = process.env;

  if (DB_SYNC_CONNECTION_STRING === undefined) {
    console.error('The DB_SYNC_CONNECTION_STRING env variable must be defined');
    return -1;
  }

  const start = Date.now() / 1000;
  const waitTime = LOCAL_NETWORK_READY_WAIT_TIME ? Number.parseInt(LOCAL_NETWORK_READY_WAIT_TIME, 10) : 1200;
  const db: Pool = new Pool({ connectionString: DB_SYNC_CONNECTION_STRING });
  let isReady = false;
  let currentElapsed = 0;

  while (!isReady && currentElapsed < waitTime) {
    try {
      console.log('Waiting...');
      const inputsResults = await db.query<{ no: number }>('SELECT no FROM epoch ORDER BY no DESC LIMIT 1');

      isReady = inputsResults.rows[0].no >= 3;
    } finally {
      currentElapsed = Date.now() / 1000 - start;
      await sleep(5000);
    }
  }

  if (currentElapsed > waitTime) {
    console.error('Wait time expired. The local test network was not started on time.');
    return -1;
  }

  console.log('Local network reached epoch 3');
})().catch(console.log);
