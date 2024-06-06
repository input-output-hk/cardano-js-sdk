import { BlockDataEntity, BlockEntity, StakeKeyEntity, pgBossSchemaExists } from '../src/index.js';
import { EntityMetadataNotFoundError } from 'typeorm';
import { initializeDataSource } from './util.js';

describe('createDataSource', () => {
  describe('with test configuration', () => {
    it('creates a TypeORM DataSource object with schema for specified entities', async () => {
      const dataSource = await initializeDataSource({
        entities: [BlockEntity, BlockDataEntity]
      });
      dataSource.getMetadata(BlockEntity);
      dataSource.getMetadata(BlockDataEntity);
      expect(() => dataSource.getMetadata(StakeKeyEntity)).toThrowError(EntityMetadataNotFoundError);
      await dataSource.destroy();
    });
  });

  describe('pg-boss schema', () => {
    it('initialize() creates and drops pg-boss schema when pgBoss extension is enabled', async () => {
      const dataSourceWithBoss = await initializeDataSource({
        entities: [BlockEntity],
        extensions: {
          pgBoss: true
        }
      });
      const queryRunnerWithBoss = dataSourceWithBoss.createQueryRunner();
      expect(await pgBossSchemaExists(queryRunnerWithBoss)).toBe(true);
      await queryRunnerWithBoss.release();

      const dataSourceWithoutBoss = await initializeDataSource({ entities: [] });
      const queryRunnerWithoutBoss = dataSourceWithoutBoss.createQueryRunner();
      expect(await pgBossSchemaExists(queryRunnerWithoutBoss)).toBe(false);
      await queryRunnerWithBoss.release();
    });
  });
});
