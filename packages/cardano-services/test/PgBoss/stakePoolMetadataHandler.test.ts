import {
  BlockEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  StakePoolEntity,
  createDataSource
} from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { DataSource } from 'typeorm';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { Pool } from 'pg';
import { isUpdateOutdated, savePoolMetadata } from '../../src/PgBoss/stakePoolMetadataHandler';
import { logger } from '@cardano-sdk/util-dev';

describe('stakePoolHandler', () => {
  const blockId = 'test_block';
  const poolId = 'test_pool' as Cardano.PoolId;
  const rewardAccount = 'test_addr';
  const vrf = 'test_vfr';

  let dataSource: DataSource;

  beforeAll(async () => {
    const connectionConfig = {
      database: process.env.POSTGRES_DB_STAKE_POOL!,
      host: process.env.POSTGRES_HOST_DB_SYNC!,
      password: process.env.POSTGRES_PASSWORD_DB_SYNC!,
      port: Number.parseInt(process.env.POSTGRES_PORT_DB_SYNC!, 10),
      // used by: new Pool()
      user: process.env.POSTGRES_USER_DB_SYNC!,
      // used by: createDataSource()
      username: process.env.POSTGRES_USER_DB_SYNC!
    };
    const db = new Pool(connectionConfig);
    const entities = [BlockEntity, PoolMetadataEntity, PoolRegistrationEntity, PoolRetirementEntity, StakePoolEntity];

    dataSource = createDataSource({ connectionConfig, devOptions: { synchronize: true }, entities, logger });

    await db.query('CREATE EXTENSION IF NOT EXISTS pgcrypto');
    await dataSource.initialize();

    const blockRepos = dataSource.getRepository(BlockEntity);
    const poolRepos = dataSource.getRepository(StakePoolEntity);
    const registrationRepos = dataSource.getRepository(PoolRegistrationEntity);
    const block = { hash: blockId, height: 23, slot: 42 };
    const stakePool = { id: poolId, status: 'active' };
    const registration1 = {
      block,
      cost: 0,
      id: '23',
      margin: {},
      marginPercent: 1,
      owners: [],
      pledge: 500_000,
      relays: [],
      rewardAccount,
      stakePool,
      vrf
    };
    const registration2 = {
      ...registration1,
      id: '42',
      pledge: 1_000_000
    };

    await blockRepos.insert(block);
    await poolRepos.insert(stakePool);
    await registrationRepos.insert(registration1);
    await registrationRepos.insert(registration2);
  });

  describe('isUpdateOutdated', () => {
    it('returns true if there is a newer pool update', async () => {
      expect(await isUpdateOutdated(dataSource, poolId, '23')).toBe(true);
    });

    it('returns false if there are no newer pool updates', async () => {
      expect(await isUpdateOutdated(dataSource, poolId, '42')).toBe(false);
    });
  });

  describe('savePoolMetadata', () => {
    const description = 'test pool description';
    const ext = null;
    const homepage = 'https://test.com';
    const name = 'test name';
    const ticker = 'TEST';

    const hash = 'test_pool_hash' as Hash32ByteBase16;
    const metadata = { description, homepage, name, ticker } as Cardano.StakePoolMetadata;

    it('inserts and updates the record', async () => {
      const metadataRepos = dataSource.getRepository(PoolMetadataEntity);
      const poolRegistrationId = '42';
      const poolUpdate = { id: poolRegistrationId as unknown as bigint };

      // No records before insert
      expect(await metadataRepos.find({ where: { poolUpdate } })).toEqual([]);

      // Insert
      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });

      // One record was inserted
      const insertResult = await metadataRepos.find({ where: { poolUpdate } });
      expect(insertResult).toEqual([{ description, ext, hash, homepage, id: insertResult[0].id, name, ticker }]);

      // Update
      metadata.name = 'updated';
      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });

      // One record updated and no records inserted
      const updateResult = await metadataRepos.find({ where: { poolUpdate } });
      expect(updateResult).toEqual([
        { description, ext, hash, homepage, id: insertResult[0].id, name: 'updated', ticker }
      ]);
    });

    it('does nothing if registration record does not exist', async () => {
      const metadataRepos = dataSource.getRepository(PoolMetadataEntity);
      const poolRegistrationId = '43';
      const poolUpdate = { id: poolRegistrationId as unknown as bigint };

      // No records before insert attempt
      expect(await metadataRepos.find({ where: { poolUpdate } })).toEqual([]);

      // Failing insert attempt
      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });

      // No records was inserted
      expect(await metadataRepos.find({ where: { poolUpdate } })).toEqual([]);
    });
  });
});
