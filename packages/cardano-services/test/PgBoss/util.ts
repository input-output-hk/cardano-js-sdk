import {
  BlockEntity,
  CurrentPoolMetricsEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  StakePoolEntity,
  createDataSource
} from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { logger } from '@cardano-sdk/util-dev';

export const blockId = 'test_block';
export const poolId = 'test_pool' as Cardano.PoolId;

export const initHandlerTest = async () => {
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
  const entities = [
    BlockEntity,
    CurrentPoolMetricsEntity,
    PoolMetadataEntity,
    PoolRegistrationEntity,
    PoolRetirementEntity,
    StakePoolEntity
  ];

  const dataSource = createDataSource({
    connectionConfig,
    devOptions: { dropSchema: true, synchronize: true },
    entities,
    logger
  });

  await db.query('CREATE EXTENSION IF NOT EXISTS pgcrypto');
  await dataSource.initialize();

  const blockRepos = dataSource.getRepository(BlockEntity);
  const poolRepos = dataSource.getRepository(StakePoolEntity);
  const block = { hash: blockId, height: 23, slot: 42 };
  const stakePool = { id: poolId, status: 'active' };

  await blockRepos.insert(block);
  await poolRepos.insert(stakePool);

  return { block, dataSource, stakePool };
};
