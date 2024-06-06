import { PoolDelistedEntity } from '@cardano-sdk/projection-typeorm';
import { createSmashStakePoolDelistedService } from '../../src/StakePool/HttpStakePoolMetadata/SmashStakePoolDelistedService.js';
import { initHandlerTest } from './util.js';
import { logger } from '@cardano-sdk/util-dev';
import { stakePoolBatchDelistHandlerFactory } from '../../src/PgBoss/stakePoolBatchDelistHandler.js';
import type { DataSource } from 'typeorm';
import type { Pool } from 'pg';
import type { WorkerHandlerFactoryOptions } from '../../src/PgBoss/index.js';

jest.mock('../../src/StakePool/HttpStakePoolMetadata/SmashStakePoolDelistedService');

describe('stakePoolBatchDelistHandler', () => {
  let dataSource: DataSource;
  let db: Pool;

  beforeAll(async () => {
    const testData = await initHandlerTest();

    ({ dataSource, db } = testData);
  });

  afterAll(() => Promise.all([db.end(), dataSource.destroy()]));

  it('contain latest delisted pools only', async () => {
    // Padded by spaces because pool id length is fixed to 56 chars
    const expected = ['pool1', 'pool2', 'pool3'].map((p) => p.padEnd(56, ' '));
    const old = ['pool3', 'pool4', 'pool5'].map((p) => p.padEnd(56, ' '));

    const repo = dataSource.getRepository(PoolDelistedEntity);

    await repo.save(
      old.map((stakePoolId) =>
        repo.create({
          stakePoolId
        })
      )
    );

    (createSmashStakePoolDelistedService as jest.Mock).mockReturnValue({
      getDelistedStakePoolIds: () => Promise.resolve(expected)
    });
    const options = { dataSource, logger, smashUrl: 'mocked' } as unknown as WorkerHandlerFactoryOptions;

    const handler = stakePoolBatchDelistHandlerFactory(options);
    await handler(null);

    const records = await repo.find();
    const read = records.map((d) => d.stakePoolId);

    expect(read).toEqual(expected);
  });
});
