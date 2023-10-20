/* eslint-disable no-console */
import { Pool, QueryResult } from 'pg';

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
      const inputsResults: QueryResult<{ no: number }> = await db.query(
        'select epoch.no from epoch order by epoch.no DESC limit 1'
      );

      isReady = inputsResults.rows[0].no >= 4; // One more than the local network healthcheck
    } catch {
      // continue
    } finally {
      currentElapsed = Date.now() / 1000 - start;
      await sleep(5000);
    }
  }

  if (currentElapsed > waitTime) {
    console.error('Wait time expired. The local test network was not started on time.');
    return -1;
  }

  console.log('Local network ready!');
})().catch(console.log);
