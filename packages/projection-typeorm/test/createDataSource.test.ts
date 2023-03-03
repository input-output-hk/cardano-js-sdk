import { BlockDataEntity, BlockEntity, StakeKeyEntity } from '../src';
import { EntityMetadataNotFoundError } from 'typeorm';
import { initializeDataSource } from './connection';

describe('createDataSource', () => {
  describe('with test configuration', () => {
    it('creates a typeorm DataSource object with schema for "block" and "block_data" by default', async () => {
      const dataSource = await initializeDataSource();
      dataSource.getMetadata(BlockEntity);
      dataSource.getMetadata(BlockDataEntity);
      expect(() => dataSource.getMetadata(StakeKeyEntity)).toThrowError(EntityMetadataNotFoundError);
      await dataSource.destroy();
    });
  });
});
