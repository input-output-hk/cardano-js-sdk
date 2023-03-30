import { BlockDataEntity, BlockEntity, StakeKeyEntity, pgBossSchemaExists } from '../src';
import { EntityMetadataNotFoundError } from 'typeorm';
import { Projections } from '@cardano-sdk/projection';
import { initializeDataSource } from './util';
import pick from 'lodash/pick';

describe('createDataSource', () => {
  describe('with test configuration', () => {
    it('creates a TypeORM DataSource object with schema for "block" and "block_data" by default', async () => {
      const dataSource = await initializeDataSource();
      dataSource.getMetadata(BlockEntity);
      dataSource.getMetadata(BlockDataEntity);
      expect(() => dataSource.getMetadata(StakeKeyEntity)).toThrowError(EntityMetadataNotFoundError);
      await dataSource.destroy();
    });
  });

  describe('pg-boss schema', () => {
    it('initialize() creates and drops pg-boss schema', async () => {
      const dataSourceWithBoss = await initializeDataSource(
        pick(Projections.allProjections, ['stakePools', 'stakePoolMetadata'])
      );
      const queryRunnerWithBoss = dataSourceWithBoss.createQueryRunner();
      expect(await pgBossSchemaExists(queryRunnerWithBoss)).toBe(true);
      await queryRunnerWithBoss.release();

      const dataSourceWithoutBoss = await initializeDataSource();
      const queryRunnerWithoutBoss = dataSourceWithoutBoss.createQueryRunner();
      expect(await pgBossSchemaExists(queryRunnerWithoutBoss)).toBe(false);
      await queryRunnerWithBoss.release();
    });
  });
});
