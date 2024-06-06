import { Pool } from 'pg';
import { STAKE_POOL_METADATA_QUEUE } from '@cardano-sdk/projection-typeorm';
import { getEnv } from '../../src/index.js';

const expectedPoolMetadata = [
  {
    description: 'This is the stake pool 1 description.',
    homepage: 'https://stakepool1.com',
    name: 'stake pool - 1',
    ticker: 'SP1'
  },
  {
    description: 'This is the stake pool 10 description.',
    homepage: 'https://stakepool10.com',
    name: 'Stake Pool - 10',
    ticker: 'SP10'
  },
  {
    description: 'This is the stake pool 11 description.',
    homepage: 'https://stakepool11.com',
    name: 'Stake Pool - 10 + 1',
    ticker: 'SP11'
  },
  {
    description: 'This is the stake pool 3 description.',
    homepage: 'https://stakepool3.com',
    name: 'Stake Pool - 3',
    ticker: 'SP3'
  },
  {
    description: 'This is the stake pool 4 description.',
    homepage: 'https://stakepool4.com',
    name: 'Same Name',
    ticker: 'SP4'
  },
  {
    description: 'This is the stake pool 5 description.',
    homepage: 'https://stakepool5.com',
    name: 'Same Name',
    ticker: 'SP5'
  },
  {
    description: 'This is the stake pool 6 description.',
    homepage: 'https://stakepool6.com',
    name: 'Stake Pool - 6',
    ticker: 'SP6a7'
  },
  {
    description: 'This is the stake pool 7 description.',
    homepage: 'https://stakepool7.com',
    name: '',
    ticker: 'SP6a7'
  }
];

describe('stake-pool-metadata', () => {
  const key = 'STAKE_POOL_CONNECTION_STRING';
  const connectionString = getEnv([key])[key];
  const db = new Pool({ connectionString });

  it('populates pool_metadata table', async () => {
    let jobState: string[] | undefined;

    // Wait until all the jobs are completed
    while (jobState?.filter((_) => _ === 'completed').length !== expectedPoolMetadata.length) {
      // If it is not the first iteration, wait for a while
      if (jobState) await new Promise((resolve) => setTimeout(resolve, 5000));

      try {
        const query = 'SELECT state FROM pgboss.job WHERE name = $1';
        const { rows } = await db.query<{ state: string }>(query, [STAKE_POOL_METADATA_QUEUE]);

        jobState = rows.map(({ state }) => state);
      } catch (error) {
        const allowedErrors = ['database "projection" does not exist', 'relation "pgboss.job" does not exist'];

        // In case the projection service has not yet created the database or the schema, simulate an empty result to wait
        if (error instanceof Error && allowedErrors.includes(error.message)) jobState = [];
        else throw error;
      }
    }

    // Jobs number should be equal to pools number
    expect(jobState.length).toBe(expectedPoolMetadata.length);

    const query = 'SELECT description, homepage, name, ticker FROM pool_metadata ORDER BY ticker, description';
    const { rows } = await db.query(query);

    expect(rows).toEqual(expectedPoolMetadata);
  });
});
