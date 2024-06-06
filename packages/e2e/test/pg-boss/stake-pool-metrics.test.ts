import { Pool } from 'pg';
import { STAKE_POOL_METRICS_UPDATE } from '@cardano-sdk/projection-typeorm';
import { getEnv } from '../../src/index.js';

const selectRowsCount = async (db: Pool, table: string) => {
  const query = `SELECT COUNT(*) FROM ${table}`;
  const { rows } = await db.query(query);

  return rows;
};

describe('stake-pool-metrics', () => {
  const key = 'STAKE_POOL_CONNECTION_STRING';
  const connectionString = getEnv([key])[key];
  const db = new Pool({ connectionString });

  it('populates current_pool_metrics table', async () => {
    let jobState: string[] | undefined;

    // Wait until at least one job completed
    while (!jobState?.filter((_) => _ === 'completed').length) {
      // If it is not the first iteration, wait for a while
      if (jobState) await new Promise((resolve) => setTimeout(resolve, 5000));

      try {
        const query = 'SELECT state FROM pgboss.job WHERE name = $1';
        const { rows } = await db.query<{ state: string }>(query, [STAKE_POOL_METRICS_UPDATE]);

        jobState = rows.map(({ state }) => state);
      } catch (error) {
        const allowedErrors = ['database "projection" does not exist', 'relation "pgboss.job" does not exist'];

        // In case the projection service has not yet created the database or the schema, simulate an empty result to wait
        if (error instanceof Error && allowedErrors.includes(error.message)) jobState = [];
        else throw error;
      }
    }

    const metricsRows = await selectRowsCount(db, 'current_pool_metrics');
    const poolsRows = await selectRowsCount(db, 'stake_pool');

    expect(metricsRows).toEqual(poolsRows);
  });
});
