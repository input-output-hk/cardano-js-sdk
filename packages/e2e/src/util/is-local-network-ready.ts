/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-floating-promises */
import * as Process from 'process';
// This disable may not be require once https://github.com/import-js/eslint-plugin-import/pull/2543 is released.
// eslint-disable-next-line import/no-extraneous-dependencies
import { Pool, QueryResult } from 'pg';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Waits until the local network is ready or the wait time expires.
 */
(async () => {
  if (Process.env.DB_SYNC_CONNECTION_STRING === undefined) {
    console.error('The DB_SYNC_CONNECTION_STRING env variable must be defined');
    return -1;
  }

  const start = Date.now() / 1000;
  const waitTime = Process.env.LOCAL_NETWORK_READY_WAIT_TIME ? Process.env.LOCAL_NETWORK_READY_WAIT_TIME : 1200;
  const db: Pool = new Pool({ connectionString: Process.env.DB_SYNC_CONNECTION_STRING });
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
})();
